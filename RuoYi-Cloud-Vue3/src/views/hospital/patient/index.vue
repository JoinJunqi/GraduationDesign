<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="姓名" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入患者姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="登录账号" prop="username">
        <el-input
          v-model="queryParams.username"
          placeholder="请输入登录账号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="手机号" prop="phone">
        <el-input
          v-model="queryParams.phone"
          placeholder="请输入手机号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="isActive">
        <el-select
          v-model="queryParams.isActive"
          placeholder="状态"
          clearable
          style="width: 100px"
          @change="handleQuery"
        >
          <el-option label="启用" :value="1" />
          <el-option label="停用" :value="0" />
        </el-select>
      </el-form-item>
      <el-form-item label="显示已删除" prop="includeDeleted">
        <el-switch
          v-model="queryParams.params.includeDeleted"
          active-value="true"
          inactive-value="false"
          @change="handleQuery"
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
          v-hasPermi="['hospital:patient:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['hospital:patient:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['hospital:patient:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="patientList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" sortable="custom" />
      <el-table-column label="姓名" align="center" prop="name" sortable="custom" />
      <el-table-column label="登录账号" align="center" prop="username" sortable="custom" />
      <el-table-column label="手机号" align="center" prop="phone" />
      <el-table-column label="身份证号" align="center" prop="idCard" />
      <el-table-column label="状态" align="center" prop="isActive" sortable="custom">
        <template #default="scope">
          <el-switch
            v-if="scope.row.isDeleted !== 1"
            v-model="scope.row.isActive"
            :active-value="1"
            :inactive-value="0"
            @change="handleStatusChange(scope.row)"
          ></el-switch>
          <el-tag v-else type="danger">已删除</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="删除时间" align="center" prop="deletedAt" width="180" v-if="queryParams.params.includeDeleted === 'true'">
        <template #default="scope">
          <span v-if="scope.row.isDeleted === 1">{{ parseTime(scope.row.deletedAt) }}</span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createdAt" width="180" sortable="custom">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createdAt) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <template v-if="scope.row.isDeleted !== 1">
            <el-button link type="primary" icon="Key" @click="handleResetPwd(scope.row)" v-hasPermi="['hospital:patient:edit']">重置密码</el-button>
            <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:patient:edit']">修改</el-button>
            <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['hospital:patient:remove']">删除</el-button>
          </template>
          <el-tag v-else type="info">无可用操作</el-tag>
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

<script setup name="Patient">
import { listPatient, getPatient, delPatient, addPatient, updatePatient, resetPatientPwd } from "@/api/hospital/patient";
import { getCurrentInstance, ref, reactive, toRefs, onMounted } from "vue";
import { useRouter } from "vue-router";

const { proxy } = getCurrentInstance();
const { parseTime } = proxy;
const router = useRouter();

const patientList = ref([]);
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
    phone: null,
    username: null,
    isActive: null,
    orderByColumn: "id",
    isAsc: "descending",
    params: {
      includeDeleted: "false"
    }
  }
});

const { queryParams } = toRefs(data);

/** 查询患者列表 */
function getList() {
  loading.value = true;
  listPatient(queryParams.value).then(response => {
    patientList.value = response.rows;
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
  queryParams.value.pageNum = 1;
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
  router.push("/hospital/patient-detail/add");
}

/** 修改按钮操作 */
function handleUpdate(row) {
  const id = row.id || ids.value;
  router.push("/hospital/patient-detail/edit/" + id);
}

/** 删除按钮操作 */
function handleDelete(row) {
  const patientIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除患者编号为"' + patientIds + '"的数据项？').then(function () {
    return delPatient(patientIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => { });
}

/** 状态修改 */
function handleStatusChange(row) {
  let text = row.isActive === 1 ? "启用" : "停用";
  proxy.$modal.confirm('确认要"' + text + '""' + row.name + '"吗？').then(function () {
    return updatePatient({ id: row.id, isActive: row.isActive });
  }).then(() => {
    proxy.$modal.msgSuccess(text + "成功");
  }).catch(function () {
    row.isActive = row.isActive === 1 ? 0 : 1;
  });
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
    resetPatientPwd(row.id, value).then(response => {
      proxy.$modal.msgSuccess("修改成功，新密码为：" + value);
    });
  }).catch(() => { });
}

onMounted(() => {
  getList();
});
</script>
