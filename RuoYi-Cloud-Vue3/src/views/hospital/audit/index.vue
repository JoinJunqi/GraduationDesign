<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="审核状态" prop="auditStatus">
        <el-select v-model="queryParams.auditStatus" placeholder="请选择状态" clearable style="width: 200px">
          <el-option label="待审核" :value="0" />
          <el-option label="已通过" :value="1" />
          <el-option label="已驳回" :value="2" />
        </el-select>
      </el-form-item>
      <el-form-item label="申请角色" prop="requesterRole">
        <el-select v-model="queryParams.requesterRole" placeholder="请选择角色" clearable style="width: 200px">
          <el-option label="医生" value="doctor" />
          <el-option label="患者" value="patient" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-table v-loading="loading" :data="auditList">
      <el-table-column label="审核类型" align="center" prop="auditType">
        <template #default="scope">
          <el-tag v-if="scope.row.auditType === 'APPOINTMENT_CANCEL'" type="warning">预约取消</el-tag>
          <el-tag v-else type="info">{{ scope.row.auditType }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="预约信息" align="center" prop="appointmentInfo" min-width="180" />
      <el-table-column label="申请人" align="center" prop="requesterName">
        <template #default="scope">
          <span>{{ scope.row.requesterName }}</span>
          <el-tag size="small" :type="scope.row.requesterRole === 'doctor' ? 'success' : 'primary'" style="margin-left: 5px">
            {{ scope.row.requesterRole === 'doctor' ? '医生' : '患者' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="申请原因" align="center" prop="requestReason" :show-overflow-tooltip="true" />
      <el-table-column label="提交时间" align="center" prop="createdAt" width="160" />
      <el-table-column label="审核状态" align="center" prop="auditStatus">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.auditStatus)">
            {{ getStatusLabel(scope.row.auditStatus) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button
            v-if="scope.row.auditStatus === 0 && hasAdminPermi(AdminPermi.AUDIT)"
            link
            type="primary"
            icon="Check"
            @click="handleProcess(scope.row)"
            v-hasPermi="['appointment:audit:process']"
          >处理</el-button>
          <el-button
            link
            type="primary"
            icon="View"
            @click="handleView(scope.row)"
          >详情</el-button>
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

    <!-- 审核处理对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="auditRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="预约信息">
          <span>{{ form.appointmentInfo }}</span>
        </el-form-item>
        <el-form-item label="申请人">
          <span>{{ form.requesterName }}</span>
        </el-form-item>
        <el-form-item label="申请原因">
          <span>{{ form.requestReason }}</span>
        </el-form-item>
        <el-form-item label="审核结果" prop="auditStatus">
          <el-radio-group v-model="form.auditStatus">
            <el-radio :label="1">通过</el-radio>
            <el-radio :label="2">驳回</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核备注" prop="auditRemark">
          <el-input v-model="form.auditRemark" type="textarea" placeholder="请输入备注或驳回理由" />
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

<script setup name="Audit">
import { listAudit, processAudit, getAudit } from "@/api/hospital/audit";
import { hasAdminPermi, AdminPermi } from "@/utils/adminPermi";

const { proxy } = getCurrentInstance();

const auditList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    auditStatus: undefined,
    requesterRole: undefined
  },
  rules: {
    auditStatus: [{ required: true, message: "审核结果不能为空", trigger: "blur" }],
    auditRemark: [{ required: true, message: "审核备注不能为空", trigger: "blur" }]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询审核列表 */
function getList() {
  loading.value = true;
  listAudit(queryParams.value).then(response => {
    auditList.value = response.rows;
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
    id: undefined,
    auditStatus: 1,
    auditRemark: undefined
  };
  proxy.resetForm("auditRef");
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

/** 处理审核操作 */
function handleProcess(row) {
  reset();
  form.value = {
    id: row.id,
    appointmentInfo: row.appointmentInfo,
    requesterName: row.requesterName,
    requestReason: row.requestReason,
    auditStatus: 1
  };
  open.value = true;
  title.value = "审核处理";
}

/** 详情按钮操作 */
function handleView(row) {
  getAudit(row.id).then(response => {
    form.value = response.data;
    // 补全冗余字段用于展示
    form.value.requesterName = row.requesterName;
    form.value.appointmentInfo = row.appointmentInfo;
    open.value = true;
    title.value = "审核详情";
  });
}

/** 提交表单 */
function submitForm() {
  proxy.$refs["auditRef"].validate(valid => {
    if (valid) {
      processAudit(form.value).then(response => {
        proxy.$modal.msgSuccess("处理成功");
        open.value = false;
        getList();
      });
    }
  });
}

function getStatusLabel(status) {
  const labels = { 0: "待审核", 1: "已通过", 2: "已驳回" };
  return labels[status] || "未知";
}

function getStatusType(status) {
  const types = { 0: "warning", 1: "success", 2: "danger" };
  return types[status] || "info";
}

getList();
</script>
