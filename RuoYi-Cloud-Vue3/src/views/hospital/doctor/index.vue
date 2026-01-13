<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="医生姓名" prop="name">
        <el-autocomplete
          v-model="queryParams.name"
          :fetch-suggestions="querySearchDoctor"
          clearable
          placeholder="请输入医生姓名"
          @select="handleQuery"
          @keyup.enter="handleQuery"
        >
          <template #default="{ item }">
            <div class="doctor-suggestion">
              <span class="name">{{ item.name }}</span>
              <span class="dept" style="margin-left: 10px; color: #999; font-size: 12px;">{{ item.deptName }}</span>
              <span class="title" style="margin-left: 10px; color: #999; font-size: 12px;">{{ item.title }}</span>
            </div>
          </template>
        </el-autocomplete>
      </el-form-item>
      <el-form-item label="登录账号" prop="username">
        <el-input
          v-model="queryParams.username"
          placeholder="请输入登录账号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="医生筛选" prop="deptId">
        <el-select
          v-model="queryParams.deptId"
          placeholder="选择科室"
          clearable
          @change="handleQueryDeptChange"
          style="width: 130px; margin-right: 5px;"
        >
          <el-option
            v-for="item in departmentOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          />
        </el-select>
        <el-select
          v-model="queryParams.id"
          placeholder="选择医生"
          clearable
          :disabled="!queryParams.deptId"
          @change="handleQuery"
          style="width: 130px;"
        >
          <el-option
            v-for="item in queryDoctorOptions"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          >
            <span>{{ item.name }}</span>
            <span style="float: right; color: #8492a6; font-size: 12px; margin-left: 10px;">{{ item.title }}</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item label="状态" prop="isActive">
        <el-select
          v-model="queryParams.isActive"
          placeholder="状态"
          clearable
          style="width: 100px"
          @change="handleQuery"
        >
          <el-option label="在职" :value="1" />
          <el-option label="离职" :value="0" />
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
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="DeleteFilled"
          @click="handleRecycle"
          v-hasPermi="['hospital:doctor:remove']"
        >回收站</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="doctorList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="姓名" align="center" prop="name" sortable="custom" />
      <el-table-column label="科室" align="center" prop="deptName" />
      <el-table-column label="职称" align="center" prop="title" />
      <el-table-column label="账号" align="center" prop="username" sortable="custom" />
      <el-table-column label="状态" align="center" prop="isActive" sortable="custom">
        <template #default="scope">
          <el-switch
            v-model="scope.row.isActive"
            :active-value="true"
            :inactive-value="false"
            @change="handleStatusChange(scope.row)"
          ></el-switch>
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
import { listDoctor, delDoctor, resetDoctorPwd, updateDoctor } from "@/api/hospital/doctor.js";
import { listDepartment } from "@/api/hospital/department";
import { getCurrentInstance, ref, reactive, toRefs, onMounted } from "vue";
import { useRouter } from "vue-router";

const { proxy } = getCurrentInstance();
const router = useRouter();

const doctorList = ref([]);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const total = ref(0);
const departmentOptions = ref([]);
const queryDoctorOptions = ref([]);

const data = reactive({
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    id: null,
    username: null,
    deptId: null,
    isActive: null,
    orderByColumn: "id",
    isAsc: "descending",
    params: {
      includeDeleted: "false"
    }
  }
});

const { queryParams } = toRefs(data);

/** 医生状态修改 */
function handleStatusChange(row) {
  let text = row.isActive ? "启用" : "停用";
  proxy.$modal.confirm('确认要"' + text + '""' + row.name + '"医生吗？').then(function () {
    return updateDoctor({ id: row.id, isActive: row.isActive });
  }).then(() => {
    proxy.$modal.msgSuccess(text + "成功");
  }).catch(function () {
    row.isActive = !row.isActive;
  });
}

/** 查询科室列表 */
function getDepartmentList() {
  listDepartment().then(response => {
    departmentOptions.value = response.rows;
  });
}

/** 科室变动时更新医生列表 */
function handleQueryDeptChange(deptId) {
  queryParams.value.id = null;
  queryDoctorOptions.value = [];
  if (deptId) {
    listDoctor({ deptId: deptId }).then(response => {
      queryDoctorOptions.value = response.rows;
    });
  }
  handleQuery();
}

/** 医生姓名输入建议 */
function querySearchDoctor(queryString, cb) {
  if (queryString) {
    listDoctor({ name: queryString }).then(response => {
      const results = response.rows.map(item => {
        return {
          value: item.name,
          name: item.name,
          deptName: item.deptName,
          title: item.title
        };
      });
      cb(results);
    });
  } else {
    cb([]);
  }
}

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
  queryParams.value.pageNum = 1;
  getList();
}

/** 重置按钮操作 */
function resetQuery() {
  queryDoctorOptions.value = [];
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
  router.push("/hospital/doctor-detail/add");
}

/** 修改按钮操作 */
function handleUpdate(row) {
  const id = row.id || ids.value;
  router.push("/hospital/doctor-detail/edit/" + id);
}

/** 删除按钮操作 */
function handleDelete(row) {
  const doctorIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除医生编号为"' + doctorIds + '"的数据项？').then(function () {
    return delDoctor(doctorIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

/** 回收站按钮操作 */
function handleRecycle() {
  router.push("/hospital/recycle/doctor");
}

/** 重置密码按钮操作 */
function handleResetPwd(row) {
  proxy.$prompt('请输入"' + row.name + '"的新密码', "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    closeOnClickModal: false,
    inputPattern: /^.{5,20}$/,
    inputErrorMessage: "用户密码长度必须介于 5 和 20 之间",
  }).then(({ value }) => {
    resetDoctorPwd(row.id, value).then(response => {
      proxy.$modal.msgSuccess("修改成功，新密码是：" + value);
    });
  }).catch(() => { });
}

onMounted(() => {
  getList();
  getDepartmentList();
});
</script>
