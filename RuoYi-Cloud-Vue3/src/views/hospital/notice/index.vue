<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="标题" prop="title">
        <el-input
          v-model="queryParams.title"
          placeholder="请输入通知标题"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="类型" prop="noticeType">
        <el-select v-model="queryParams.noticeType" placeholder="通知类型" clearable>
          <el-option label="系统公告" value="系统公告" />
          <el-option label="医院动态" value="医院动态" />
          <el-option label="停诊通知" value="停诊通知" />
          <el-option label="政策法规" value="政策法规" />
          <el-option label="温馨提示" value="温馨提示" />
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
          v-hasPermi="['hospital:notice:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['hospital:notice:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['hospital:notice:remove']"
        >删除</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="noticeList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="ID" align="center" prop="id" width="60" />
      <el-table-column label="标题" align="center" prop="title" :show-overflow-tooltip="true" />
      <el-table-column label="类型" align="center" prop="noticeType" width="100">
        <template #default="scope">
          <el-tag :type="getNoticeTypeTag(scope.row.noticeType)">{{ scope.row.noticeType }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="受众" align="center" prop="targetAudience" width="80" />
      <el-table-column label="优先级" align="center" prop="priority" width="80">
        <template #default="scope">
          <el-tag :type="getPriorityTag(scope.row.priority)">{{ scope.row.priority }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="发布时间" align="center" prop="publishTime" width="160">
        <template #default="scope">
          <span>{{ parseTime(scope.row.publishTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" prop="isActive" width="80">
        <template #default="scope">
          <el-tag :type="scope.row.isActive === 1 ? 'success' : 'info'">
            {{ scope.row.isActive === 1 ? '有效' : '无效' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="置顶" align="center" prop="isTop" width="60">
        <template #default="scope">
          <el-tag :type="scope.row.isTop === 1 ? 'warning' : 'info'">
            {{ scope.row.isTop === 1 ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="阅读量" align="center" prop="viewCount" width="70" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['hospital:notice:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['hospital:notice:remove']">删除</el-button>
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

    <!-- 添加或修改通知对话框 -->
    <el-dialog :title="title" v-model="open" width="780px" append-to-body>
      <el-form ref="noticeRef" :model="form" :rules="rules" label-width="80px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="通知标题" prop="title">
              <el-input v-model="form.title" placeholder="请输入通知标题" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="通知类型" prop="noticeType">
              <el-select v-model="form.noticeType" placeholder="请选择类型" style="width: 100%">
                <el-option label="系统公告" value="系统公告" />
                <el-option label="医院动态" value="医院动态" />
                <el-option label="停诊通知" value="停诊通知" />
                <el-option label="政策法规" value="政策法规" />
                <el-option label="温馨提示" value="温馨提示" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="目标受众" prop="targetAudience">
              <el-select v-model="form.targetAudience" placeholder="请选择受众" style="width: 100%">
                <el-option label="全部" value="全部" />
                <el-option label="患者" value="患者" />
                <el-option label="医生" value="医生" />
                <el-option label="管理员" value="管理员" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="优先级" prop="priority">
              <el-radio-group v-model="form.priority">
                <el-radio label="普通">普通</el-radio>
                <el-radio label="重要">重要</el-radio>
                <el-radio label="紧急">紧急</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="是否置顶">
              <el-radio-group v-model="form.isTop">
                <el-radio :label="1">是</el-radio>
                <el-radio :label="0">否</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="发布时间" prop="publishTime">
              <el-date-picker
                v-model="form.publishTime"
                type="datetime"
                value-format="YYYY-MM-DD HH:mm:ss"
                placeholder="选择发布时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="过期时间" prop="expireTime">
              <el-date-picker
                v-model="form.expireTime"
                type="datetime"
                value-format="YYYY-MM-DD HH:mm:ss"
                placeholder="选择过期时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="是否有效">
              <el-radio-group v-model="form.isActive">
                <el-radio :label="1">是</el-radio>
                <el-radio :label="0">否</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="内容" prop="content">
              <el-input v-model="form.content" type="textarea" :rows="6" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
        </el-row>
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

<script setup name="HospitalNotice">
import { listNotice, getNotice, delNotice, addNotice, updateNotice } from "@/api/hospital/notice";
import useUserStore from "@/store/modules/user";

const { proxy } = getCurrentInstance();
const userStore = useUserStore();

const noticeList = ref([]);
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
    title: null,
    noticeType: null
  },
  rules: {
    title: [{ required: true, message: "标题不能为空", trigger: "blur" }],
    noticeType: [{ required: true, message: "类型不能为空", trigger: "change" }],
    content: [{ required: true, message: "内容不能为空", trigger: "blur" }],
    publishTime: [{ required: true, message: "发布时间不能为空", trigger: "blur" }]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询通知列表 */
function getList() {
  loading.value = true;
  listNotice(queryParams.value).then(response => {
    noticeList.value = response.rows;
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
    title: null,
    content: null,
    noticeType: "系统公告",
    targetAudience: "全部",
    priority: "普通",
    publishTime: proxy.parseTime(new Date()),
    expireTime: null,
    isTop: 0,
    isActive: 1,
    publisherId: userStore.userId
  };
  proxy.resetForm("noticeRef");
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
  reset();
  open.value = true;
  title.value = "添加通知";
}

/** 修改按钮操作 */
function handleUpdate(row) {
  reset();
  const id = row.id || ids.value;
  getNotice(id).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改通知";
  });
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["noticeRef"].validate(valid => {
    if (valid) {
      if (form.value.id != null) {
        updateNotice(form.value).then(response => {
          proxy.$modal.msgSuccess("修改成功");
          open.value = false;
          getList();
        });
      } else {
        addNotice(form.value).then(response => {
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
  const noticeIds = row.id || ids.value;
  proxy.$modal.confirm('是否确认删除通知编号为"' + noticeIds + '"的数据项？').then(function() {
    return delNotice(noticeIds);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

/** 获取通知类型标签 */
function getNoticeTypeTag(type) {
  const map = {
    '系统公告': 'primary',
    '医院动态': 'success',
    '停诊通知': 'danger',
    '政策法规': 'warning',
    '温馨提示': 'info'
  };
  return map[type] || 'info';
}

/** 获取优先级标签 */
function getPriorityTag(priority) {
  const map = {
    '普通': 'info',
    '重要': 'warning',
    '紧急': 'danger'
  };
  return map[priority] || 'info';
}

getList();
</script>
