<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="医生姓名" prop="doctorName" v-if="!isDoctor">
        <el-input
          v-model="queryParams.doctorName"
          placeholder="请输入医生姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="出诊日期" prop="workDate">
        <el-date-picker
          v-model="queryParams.workDate"
          type="date"
          placeholder="选择日期"
          value-format="YYYY-MM-DD"
          clearable
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
          v-hasPermi="['hospital:schedule:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['hospital:schedule:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['hospital:schedule:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="scheduleList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" sortable="custom" />
      <el-table-column label="科室" align="center" prop="deptName" />
      <el-table-column label="医生" align="center" prop="doctorName" sortable="custom" />
      <el-table-column label="出诊日期" align="center" prop="workDate" width="120" sortable="custom">
        <template #default="scope">
          <span>{{ parseTime(scope.row.workDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="班次" align="center" prop="timeSlot" sortable="custom" />
      <el-table-column label="总号源" align="center" prop="totalCapacity" sortable="custom" />
      <el-table-column label="剩余号源" align="center" prop="availableSlots" sortable="custom" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:schedule:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['hospital:schedule:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />
    
    <!-- 添加或修改排班对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="scheduleRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="医生" prop="doctorName">
          <el-input v-model="form.doctorName" placeholder="医生姓名" :disabled="true" v-if="isDoctor" />
          <el-input v-model="form.doctorId" placeholder="请输入医生ID" v-else />
        </el-form-item>
        <el-form-item label="出诊日期" prop="workDate">
          <el-date-picker
            v-model="form.workDate"
            type="date"
            placeholder="选择出诊日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="班次" prop="timeSlot">
          <el-select v-model="form.timeSlot" placeholder="请选择班次">
            <el-option label="上午" value="上午" />
            <el-option label="下午" value="下午" />
            <el-option label="全天" value="全天" />
          </el-select>
        </el-form-item>
        <el-form-item label="总号源" prop="totalCapacity">
          <el-input-number v-model="form.totalCapacity" :min="1" />
        </el-form-item>
        <el-form-item label="剩余号源" prop="availableSlots">
          <el-input-number v-model="form.availableSlots" :min="0" />
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

<script setup name="Schedule">
import { ref, reactive, toRefs, computed, getCurrentInstance } from 'vue';
import { listSchedule, getSchedule, delSchedule, addSchedule, updateSchedule } from "@/api/hospital/schedule";
import useUserStore from "@/store/modules/user";

const userStore = useUserStore();
const { proxy } = getCurrentInstance();

const isDoctor = computed(() => userStore.roles.includes('doctor'));
const currentDoctorName = computed(() => userStore.nickName);
const currentDoctorId = computed(() => userStore.id);

const scheduleList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const title = ref("");
const total = ref(0);

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    doctorName: null,
    workDate: null,
    orderByColumn: "workDate",
    isAsc: "descending"
  },
  rules: {
    doctorId: [
      { required: true, message: "医生ID不能为空", trigger: "blur" }
    ],
    doctorName: [
      { required: true, message: "医生姓名不能为空", trigger: "blur" }
    ],
    workDate: [
      { required: true, message: "出诊日期不能为空", trigger: "blur" }
    ],
    timeSlot: [
      { required: true, message: "班次不能为空", trigger: "change" }
    ],
    totalCapacity: [
      { required: true, message: "总号源数不能为空", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 排序触发事件 */
function handleSortChange(column) {
  queryParams.value.orderByColumn = column.prop;
  queryParams.value.isAsc = column.order;
  getList();
}

/** 查询排班列表 */
function getList() {
  loading.value = true;
  listSchedule(queryParams.value).then(response => {
    scheduleList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

/** 取消按钮 */
function cancel() {
  open.value = false;
  reset();
}

/** 表单重置 */
function reset() {
  form.value = {
    id: null,
    doctorId: isDoctor.value ? currentDoctorId.value : null,
    doctorName: isDoctor.value ? currentDoctorName.value : null,
    workDate: null,
    timeSlot: null,
    totalCapacity: 20,
    availableSlots: 20
  };
  proxy.resetForm("scheduleRef");
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
  title.value = "添加排班";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const id = row.id || ids.value;
  getSchedule(id).then(response => {
    form.value = response.data;
    if (isDoctor.value && !form.value.doctorName) {
      form.value.doctorName = currentDoctorName.value;
    }
    open.value = true;
    title.value = "修改排班";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["scheduleRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateSchedule(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        addSchedule(form.value).then(response => {
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
  const scheduleIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除排班编号为"' + scheduleIds + '"的数据项？').then(function() {
    return delSchedule(scheduleIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

getList();
</script>
