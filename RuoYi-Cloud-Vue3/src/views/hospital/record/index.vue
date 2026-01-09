<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="患者姓名" prop="patientName" v-if="!isPatient">
        <el-input
          v-model="queryParams.patientName"
          placeholder="请输入患者姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="医生姓名" prop="doctorName" v-if="!isDoctor">
        <el-input
          v-model="queryParams.doctorName"
          placeholder="请输入医生姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="诊断结果" prop="diagnosis">
        <el-input
          v-model="queryParams.diagnosis"
          placeholder="请输入诊断结果"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-if="!isDoctor"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="recordList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="编号" align="center" prop="id" width="80" />
      <el-table-column label="患者姓名" align="center" prop="patientName" v-if="!isPatient" />
      <el-table-column label="就诊医生" align="center" prop="doctorName" v-if="!isDoctor" />
      <el-table-column label="科室" align="center" prop="deptName" />
      <el-table-column label="诊断结果" align="center" prop="diagnosis" show-overflow-tooltip />
      <el-table-column label="就诊时间" align="center" prop="visitTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.visitTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleView(scope.row)">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-if="!isDoctor">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 添加或修改病历对话框 -->
    <el-dialog :title="title" v-model="open" width="600px" append-to-body>
      <el-form ref="recordRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="预约ID" prop="appointmentId">
          <el-input v-model="form.appointmentId" placeholder="请输入预约ID" :disabled="isDoctor || (isPatient && form.id)" />
        </el-form-item>
        <el-form-item label="医生ID" prop="doctorId">
          <el-input v-model="form.doctorId" placeholder="请输入医生ID" :disabled="isDoctor || (isPatient && form.id)" />
        </el-form-item>
        <el-form-item label="就诊时间" prop="visitTime">
          <el-date-picker clearable
            v-model="form.visitTime"
            type="datetime"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="请选择就诊时间"
            :disabled="isDoctor">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="诊断结果" prop="diagnosis">
          <el-input v-model="form.diagnosis" type="textarea" placeholder="请输入诊断结果" :disabled="isPatient" />
        </el-form-item>
        <el-form-item label="处方信息" prop="prescription">
          <el-input v-model="form.prescription" type="textarea" placeholder="请输入处方信息" :disabled="isPatient" />
        </el-form-item>
        <el-form-item label="医嘱备注" prop="notes">
          <el-input v-model="form.notes" type="textarea" placeholder="请输入医嘱备注" :disabled="isPatient" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 病历详情对话框 -->
    <el-dialog title="病历详情" v-model="openView" width="600px" append-to-body>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="患者姓名" v-if="!isPatient">{{ form.patientName }}</el-descriptions-item>
        <el-descriptions-item label="就诊医生" v-if="!isDoctor">{{ form.doctorName }}</el-descriptions-item>
        <el-descriptions-item label="所属科室">{{ form.deptName }}</el-descriptions-item>
        <el-descriptions-item label="就诊时间">{{ parseTime(form.visitTime) }}</el-descriptions-item>
        <el-descriptions-item label="诊断结果">{{ form.diagnosis }}</el-descriptions-item>
        <el-descriptions-item label="处方信息">{{ form.prescription }}</el-descriptions-item>
        <el-descriptions-item label="医嘱备注">{{ form.notes }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="openView = false">关 闭</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Record">
import { getCurrentInstance, computed, ref, reactive, toRefs, onMounted } from 'vue';
import { listRecord, getRecord, delRecord, addRecord, updateRecord } from "@/api/hospital/record";
import useUserStore from "@/store/modules/user";

console.log('Record index component setup started');

const { proxy } = getCurrentInstance();
const userStore = useUserStore();

const loginType = computed(() => userStore.loginType);
const isAdmin = computed(() => loginType.value === 'admin');
const isDoctor = computed(() => loginType.value === 'doctor');
const isPatient = computed(() => loginType.value === 'patient');

const recordList = ref([]);
const open = ref(false);
const openView = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    patientName: null,
    doctorName: null,
    diagnosis: null
  }
});

const { queryParams, form } = toRefs(data);

const rules = computed(() => ({
  appointmentId: [
    { required: true, message: "预约ID不能为空", trigger: "blur" }
  ],
  doctorId: [
    { required: true, message: "医生ID不能为空", trigger: "blur" }
  ],
  diagnosis: [
    { required: !isPatient.value, message: "诊断结果不能为空", trigger: "blur" }
  ],
  visitTime: [
    { required: true, message: "就诊时间不能为空", trigger: "blur" }
  ]
}));

/** 查询病历列表 */
function getList() {
  console.log('getList called with queryParams:', queryParams.value);
  loading.value = true;
  listRecord(queryParams.value).then(response => {
    console.log('listRecord response:', response);
    recordList.value = response.data;
    loading.value = false;
  }).catch(error => {
    console.error('listRecord error:', error);
    loading.value = false;
  });
}

// 取消按钮
function cancel() {
  open.value = false;
  reset();
}

// 表单重置
function reset() {
  form.value = {
    id: null,
    appointmentId: null,
    patientId: null,
    doctorId: null,
    diagnosis: null,
    prescription: null,
    notes: null,
    visitTime: null
  };
  proxy.resetForm("recordRef");
}

/** 搜索按钮操作 */
function handleQuery() {
  getList();
}

onMounted(() => {
  console.log('Record index component mounted');
  getList();
});

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef");
  handleQuery();
}

/** 多选框选中数据 */
function handleSelectionChange(selection) {
  ids.value = selection.map(item => item.id);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
}

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = "添加病历";
}

/** 查看详情操作 */
function handleView(row) {
  reset();
  const id = row.id || ids.value;
  getRecord(id).then(response => {
    form.value = response.data;
    openView.value = true;
  });
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const id = row.id || ids.value;
  getRecord(id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改病历";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["recordRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateRecord(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        addRecord(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          open.value = false;
          getList();
        });
      }
    }
  });
}

/** 删除按钮操作 */
function handleDelete(row) {
  const recordIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除病历编号为"' + recordIds + '"的数据项？').then(function() {
    return delRecord(recordIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

</script>
