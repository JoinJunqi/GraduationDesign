<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="患者姓名" prop="patientName">
        <el-input
          v-model="queryParams.patientName"
          placeholder="请输入患者姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option label="待就诊" value="待就诊" />
          <el-option label="已取消" value="已取消" />
          <el-option label="已完成" value="已完成" />
        </el-select>
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
          @click="handleRegister"
          v-if="isPatient"
        >预约挂号</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-if="!isPatient"
          v-hasPermi="['hospital:appointment:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-if="!isPatient"
          v-hasPermi="['hospital:appointment:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="appointmentList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="患者姓名" align="center" prop="patientName" sortable />
      <el-table-column label="医生" align="center" prop="doctorName" />
      <el-table-column label="就诊日期" align="center" prop="workDate" sortable>
        <template #default="scope">
          <span>{{ parseTime(scope.row.workDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="班次" align="center" prop="timeSlot" />
      <el-table-column label="状态" align="center" prop="status" sortable>
        <template #default="scope">
          <el-tag :type="scope.row.status === '已完成' ? 'success' : (scope.row.status === '已取消' ? 'info' : 'warning')">
            {{ scope.row.status }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="预约时间" align="center" prop="bookedAt" width="180" sortable>
        <template #default="scope">
          <span>{{ parseTime(scope.row.bookedAt) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-if="!isPatient" v-hasPermi="['hospital:appointment:edit']">修改</el-button>
          <el-button link type="danger" icon="CircleClose" @click="handleCancel(scope.row)" v-if="scope.row.status === '待就诊'">取消预约</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-if="!isPatient" v-hasPermi="['hospital:appointment:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 添加或修改预约对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="appointmentRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="患者ID" prop="patientId">
          <el-input v-model="form.patientId" placeholder="请输入患者ID" />
        </el-form-item>
        <el-form-item label="排班ID" prop="scheduleId">
          <el-input v-model="form.scheduleId" placeholder="请输入排班ID" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态">
            <el-option label="待就诊" value="待就诊" />
            <el-option label="已取消" value="已取消" />
            <el-option label="已完成" value="已完成" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Appointment">
import { ref, reactive, toRefs, getCurrentInstance, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { listAppointment, getAppointment, delAppointment, addAppointment, updateAppointment, cancelAppointment } from "@/api/hospital/appointment.js";
import { parseTime } from "@/utils/ruoyi";
import useUserStore from "@/store/modules/user";

const { proxy } = getCurrentInstance();
const userStore = useUserStore();
const loginType = computed(() => userStore.loginType);
const isPatient = computed(() => loginType.value === 'patient');

const appointmentList = ref([]);
const open = ref(false);
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
    status: null
  },
  rules: {
    patientId: [
      { required: true, message: "患者ID不能为空", trigger: "blur" }
    ],
    scheduleId: [
      { required: true, message: "排班ID不能为空", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

const router = useRouter();

/** 跳转到挂号页面 */
function handleRegister() {
  router.push({ path: '/hospital/register' });
}

function getList() {
  loading.value = true;
  listAppointment(queryParams.value).then(response => {
    // 兼容多种返回格式
    if (response.rows !== undefined && response.total !== undefined) {
      // 标准 RuoYi 分页响应
      appointmentList.value = response.rows;
      total.value = response.total;
    } else if (response.data) {
      if (Array.isArray(response.data)) {
        appointmentList.value = response.data;
        total.value = response.data.length;
      } else if (response.data.rows) {
        appointmentList.value = response.data.rows;
        total.value = response.data.total;
      } else {
        appointmentList.value = [];
        total.value = 0;
      }
    } else if (Array.isArray(response)) {
      appointmentList.value = response;
      total.value = response.length;
    } else {
      appointmentList.value = [];
      total.value = 0;
    }
    loading.value = false;
  }).catch(error => {
    console.error("Failed to fetch appointments:", error);
    loading.value = false;
  });
}

onMounted(() => {
  getList();
});

/** 取消按钮 */
function cancel() {
  open.value = false;
  reset();
}

/** 表单重置 */
function reset() {
  form.value = {
    id: null,
    patientId: null,
    scheduleId: null,
    status: '待就诊'
  };
  proxy.resetForm("appointmentRef");
}

/** 搜索按钮操作 */
function handleQuery() {
  getList();
}

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
  title.value = "添加预约";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const id = row.id || ids.value;
  getAppointment(id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改预约";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["appointmentRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateAppointment(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        addAppointment(form.value).then(response => {
          proxy.$modal.msgSuccess("新增成功");
          open.value = false;
          getList();
        });
      }
    }
  });
}

/** 取消预约操作 */
function handleCancel(row) {
  const id = row.id;
  proxy.$modal.confirm('是否确认取消预约编号为"' + id + '"的预约？').then(function() {
    return cancelAppointment(id);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("取消成功");
  }).catch(() => {});
}

/** 删除按钮操作 */
function handleDelete(row) {
  const appointmentIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除预约编号为"' + appointmentIds + '"的数据项？').then(function() {
    return delAppointment(appointmentIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

getList();
</script>
