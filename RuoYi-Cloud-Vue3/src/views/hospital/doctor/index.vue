<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="医生姓名" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入医生姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="所属科室" prop="deptId">
        <el-input
          v-model="queryParams.deptId"
          placeholder="请输入科室ID"
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
          v-hasPermi="['hospital:doctor:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['hospital:doctor:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['hospital:doctor:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="doctorList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" sortable="custom" />
      <el-table-column label="姓名" align="center" prop="name" sortable="custom" />
      <el-table-column label="科室" align="center" prop="deptName" />
      <el-table-column label="职称" align="center" prop="title" />
      <el-table-column label="账号" align="center" prop="username" sortable="custom" />
      <el-table-column label="状态" align="center" prop="isActive" sortable="custom">
        <template #default="scope">
          <el-tag :type="scope.row.isActive ? 'success' : 'danger'">
            {{ scope.row.isActive ? '在职' : '离职' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Key" @click="handleResetPwd(scope.row)" v-hasPermi="['hospital:doctor:edit']">重置密码</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:doctor:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['hospital:doctor:remove']">删除</el-button>
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
  </div>
</template>

<script setup name="Doctor">
import { listDoctor, delDoctor, resetDoctorPwd } from "@/api/hospital/doctor.js";

const { proxy } = getCurrentInstance();
const router = useRouter();

const doctorList = ref([]);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    deptId: null,
    orderByColumn: "id",
    isAsc: "ascending"
  }
});

const { queryParams } = toRefs(data);

/** 查询医生列表 */
function getList() {
  loading.value = true;
  listDoctor(queryParams.value).then(response => {
    doctorList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

/** 排序触发事件 */
function handleSortChange(column) {
  queryParams.value.orderByColumn = column.prop;
  queryParams.value.isAsc = column.order;
  getList();
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
  router.push("/hospital/doctor/add");
}

/** 修改按钮操作 */
function handleUpdate(row) {
  const id = row.id || ids.value;
  router.push("/hospital/doctor/edit/" + id);
}

/** 重置密码按钮操作 */
function handleResetPwd(row) {
  proxy.$prompt('请输入"' + row.name + '"的新密码', "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    closeOnClickModal: false,
    inputPattern: /^.{5,20}$/,
    inputErrorMessage: "密码长度需在 5 到 20 个字符之间",
  }).then(({ value }) => {
    resetDoctorPwd(row.id, value).then(response => {
      proxy.$modal.msgSuccess("修改成功，新密码为：" + value);
    });
  }).catch(() => {});
}

/** 删除按钮操作 */
function handleDelete(row) {
  const doctorIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除医生编号为"' + doctorIds + '"的数据项？').then(function() {
    return delDoctor(doctorIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

getList();
</script>
