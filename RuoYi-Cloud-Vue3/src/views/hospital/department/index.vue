<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="科室名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入科室名称"
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
          v-hasPermi="['hospital:department:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['hospital:department:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['hospital:department:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="departmentList" @selection-change="handleSelectionChange" @sort-change="handleSortChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" sortable="custom" />
      <el-table-column label="科室名称" align="center" prop="name" sortable="custom" />
      <el-table-column label="创建时间" align="center" prop="createdAt" width="180" sortable="custom">
        <template #default="scope">
          <span>{{ parseTime(scope.row.createdAt) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="InfoFilled" @click="handleIntro(scope.row)" v-hasPermi="['hospital:department:edit']">介绍</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:department:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['hospital:department:remove']">删除</el-button>
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
    
    <!-- 添加或修改科室对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="departmentRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="科室名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入科室名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 科室介绍对话框 -->
    <el-dialog :title="introTitle" v-model="introOpen" width="700px" append-to-body>
      <el-form ref="introRef" :model="introForm" label-width="80px">
        <el-form-item label="科室概述" prop="overview">
          <el-input v-model="introForm.overview" type="textarea" placeholder="请输入科室概述" />
        </el-form-item>
        <el-form-item label="详细介绍" prop="detailedIntro">
          <el-input v-model="introForm.detailedIntro" type="textarea" :rows="4" placeholder="请输入详细介绍" />
        </el-form-item>
        <el-form-item label="主要服务" prop="services">
          <el-input v-model="introForm.services" type="textarea" :rows="3" placeholder="请输入主要服务项目" />
        </el-form-item>
        <el-form-item label="科室特色" prop="features">
          <el-input v-model="introForm.features" type="textarea" :rows="3" placeholder="请输入科室特色" />
        </el-form-item>
        <el-form-item label="就诊须知" prop="notice">
          <el-input v-model="introForm.notice" type="textarea" :rows="3" placeholder="请输入就诊须知" />
        </el-form-item>
        <el-form-item label="是否启用">
          <el-radio-group v-model="introForm.isActive">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitIntroForm">确 定</el-button>
          <el-button @click="introOpen = false">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Department">
import { listDepartment, getDepartment, delDepartment, addDepartment, updateDepartment, getDepartmentIntro, saveDepartmentIntro } from "@/api/hospital/department";
import { getCurrentInstance, ref, reactive, toRefs, onMounted } from "vue";

const { proxy } = getCurrentInstance();
const { parseTime } = proxy;

const departmentList = ref([]);
const open = ref(false);
const introOpen = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const ids = ref([]);
const single = ref(true);
const multiple = ref(true);
const title = ref("");
const introTitle = ref("");
const total = ref(0);

const data = reactive({
  form: {},
  introForm: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    name: null,
    orderByColumn: "id",
    isAsc: "ascending"
  },
  rules: {
    name: [
      { required: true, message: "科室名称不能为空", trigger: "blur" }
    ]
  }
});

const { queryParams, form, introForm, rules } = toRefs(data);

/** 排序触发事件 */
function handleSortChange(column) {
  queryParams.value.orderByColumn = column.prop;
  queryParams.value.isAsc = column.order;
  getList();
}

/** 查询科室列表 */
function getList() {
  loading.value = true;
  listDepartment(queryParams.value).then(response => {
    departmentList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

/** 科室介绍按钮操作 */
function handleIntro(row) {
  const deptId = row.id;
  getDepartmentIntro(deptId).then(response => {
    if (response.data) {
      introForm.value = response.data;
    } else {
      introForm.value = {
        deptId: deptId,
        overview: '',
        detailedIntro: '',
        services: '',
        features: '',
        notice: '',
        isActive: 1
      };
    }
    introOpen.value = true;
    introTitle.value = `科室介绍 - ${row.name}`;
  });
}

/** 提交介绍表单 */
function submitIntroForm() {
  saveDepartmentIntro(introForm.value).then(response => {
    proxy.$modal.msgSuccess("保存成功");
    introOpen.value = false;
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
    name: null
  };
  proxy.resetForm("departmentRef");
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
  title.value = "添加科室";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const id = row.id || ids.value;
  getDepartment(id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改科室";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["departmentRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateDepartment(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        addDepartment(form.value).then(response => {
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
  const departmentIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除科室编号为"' + departmentIds + '"的数据项？').then(function() {
    return delDepartment(departmentIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

onMounted(() => {
  getList();
});
</script>
