<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="账号" prop="userName">
        <el-input
          v-model="queryParams.userName"
          placeholder="请输入登录账号"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="姓名" prop="nickName">
        <el-input
          v-model="queryParams.nickName"
          placeholder="请输入管理员姓名"
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
          v-hasPermi="['hospital:admin:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['hospital:admin:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['hospital:admin:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="adminList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="userId" />
      <el-table-column label="登录账号" align="center" prop="userName" />
      <el-table-column label="姓名" align="center" prop="nickName" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'">
            {{ scope.row.status === '0' ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:admin:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['hospital:admin:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 添加或修改管理员对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="adminRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="登录账号" prop="userName">
          <el-input v-model="form.userName" placeholder="请输入登录账号" />
        </el-form-item>
        <el-form-item label="登录密码" prop="password" v-if="!form.userId">
          <el-input v-model="form.password" placeholder="请输入登录密码" type="password" show-password/>
        </el-form-item>
        <el-form-item label="姓名" prop="nickName">
          <el-input v-model="form.nickName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="0">启用</el-radio>
            <el-radio label="1">禁用</el-radio>
          </el-radio-group>
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

<script setup name="Admin">
import { listAdmin, getAdmin, delAdmin, addAdmin, updateAdmin } from "@/api/hospital/admin";

const { proxy } = getCurrentInstance();

const adminList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    userName: null,
    nickName: null
  },
  rules: {
    userName: [
      { required: true, message: "登录账号不能为空", trigger: "blur" }
    ],
    nickName: [
      { required: true, message: "姓名不能为空", trigger: "blur" }
    ],
    password: [
      { required: true, message: "密码不能为空", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询管理员列表 */
function getList() {
  loading.value = true;
  listAdmin(queryParams.value).then(response => {
    adminList.value = response.data;
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
    userId: null,
    userName: null,
    password: null,
    nickName: null,
    status: "0"
  };
  proxy.resetForm("adminRef");
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
  ids.value = selection.map(item => item.userId);
  single.value = selection.length != 1;
  multiple.value = !selection.length;
}

/** 新增按钮操作 */
function handleAdd() {
  reset();
  open.value = true;
  title.value = "添加管理员";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const userId = row.userId || ids.value;
  getAdmin(userId).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改管理员";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["adminRef"].validate(valid => {
    if (valid) {
      if (form.value.userId != null) {
        updateAdmin(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        addAdmin(form.value).then(response => {
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
  const userIds = row.userId || ids.value;
  proxy.$modal.confirm('是否确认删除管理员编号为"' + userIds + '"的数据项？').then(function() {
    return delAdmin(userIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

getList();
</script>
