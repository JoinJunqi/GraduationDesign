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

    <el-table v-loading="loading" :data="adminList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="userId" sortable="custom" />
      <el-table-column label="登录账号" align="center" prop="userName" sortable="custom" />
      <el-table-column label="姓名" align="center" prop="nickName" sortable="custom" />
      <el-table-column label="等级" align="center" prop="adminLevel">
        <template #default="scope">
          <el-tag :type="scope.row.adminLevel === 1 ? 'danger' : 'info'">
            {{ scope.row.adminLevel === 1 ? '超级管理员' : '普通管理员' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="status" sortable="custom">
        <template #default="scope">
          <el-tag :type="scope.row.status === '0' ? 'success' : 'danger'">
            {{ scope.row.status === '0' ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180" sortable="custom">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button 
            v-if="scope.row.userId !== (currentUser?.userId || -1)"
            link 
            type="primary" 
            icon="Edit" 
            @click="handleUpdate(scope.row)" 
            v-hasPermi="['hospital:admin:edit']"
          >修改</el-button>
          <el-button 
            v-if="scope.row.userId !== (currentUser?.userId || -1)"
            link 
            type="primary" 
            icon="Delete" 
            @click="handleDelete(scope.row)" 
            v-hasPermi="['hospital:admin:remove']"
          >删除</el-button>
          <span v-else>--</span>
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
        <el-form-item label="管理员等级" prop="adminLevel">
          <el-radio-group v-model="form.adminLevel">
            <el-radio :label="0">普通管理员</el-radio>
            <el-radio :label="1">超级管理员</el-radio>
          </el-radio-group>
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
import { getCurrentInstance, ref, reactive, toRefs, onMounted, computed } from "vue";
import useUserStore from "@/store/modules/user";

const userStore = useUserStore();
const currentUser = computed(() => userStore.user);
const { proxy } = getCurrentInstance();
const { parseTime } = proxy;

const adminList = ref([]);
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
    userName: null,
    nickName: null,
    orderByColumn: "userId",
    isAsc: "ascending"
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
    ],
    adminLevel: [
      { required: true, message: "管理员等级不能为空", trigger: "change" }
    ],
    status: [
      { required: true, message: "状态不能为空", trigger: "change" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询管理员列表 */
function getList() {
  loading.value = true;
  listAdmin(queryParams.value).then(response => {
    adminList.value = response.rows;
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
    userId: null,
    userName: null,
    password: null,
    nickName: null,
    adminLevel: 0,
    status: "0"
  };
  proxy.resetForm("adminRef");
}

/** 排序触发事件 */
function handleSortChange(column) {
  const sortMap = {
    userId: 'id',
    userName: 'username',
    nickName: 'name',
    status: 'is_active',
    createTime: 'created_at'
  };
  queryParams.value.orderByColumn = sortMap[column.prop] || column.prop;
  // 将 el-table 的 ascending/descending 转换为后端识别的 asc/desc
  if (column.order === 'ascending') {
    queryParams.value.isAsc = 'asc';
  } else if (column.order === 'descending') {
    queryParams.value.isAsc = 'desc';
  } else {
    queryParams.value.isAsc = null;
  }
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

onMounted(() => {
  getList();
});
</script>
