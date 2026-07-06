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
          <el-tag v-else-if="scope.row.auditType === 'SCHEDULE_CHANGE'" type="info">排班调整</el-tag>
          <el-tag v-else type="info">{{ scope.row.auditType }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="预约信息" align="center" prop="appointmentInfo" min-width="180" />
      <el-table-column label="申请人" align="center" prop="requesterName">
        <template #default="scope">
          <span>{{ scope.row.requesterName }}</span>
          <el-tag
            size="small"
            effect="dark"
            :type="scope.row.requesterRole === 'doctor' ? 'success' : 'primary'"
            style="margin-left: 5px"
          >
            {{ scope.row.requesterRole === 'doctor' ? '医生' : '患者' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="申请原因" align="center" prop="requestReason" :show-overflow-tooltip="true" />
      <el-table-column label="提交时间" align="center" prop="createdAt" width="160" />
      <el-table-column label="审核处理人" align="center" prop="adminName">
        <template #default="scope">
          <span>{{ scope.row.adminName || '-' }}</span>
        </template>
      </el-table-column>
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

// 审核中心核心状态：列表、分页、弹窗开关与标题
const auditList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    // 默认按分页拉取，过滤条件按需传
    pageNum: 1,
    pageSize: 10,
    auditStatus: undefined,
    requesterRole: undefined
  },
  rules: {
    // 管理员必须明确给出“通过/驳回”与处理备注
    auditStatus: [{ required: true, message: "审核结果不能为空", trigger: "blur" }],
    auditRemark: [{ required: true, message: "审核备注不能为空", trigger: "blur" }]
  }
});

const { queryParams, form, rules } = toRefs(data);

/** 查询审核列表 */
function getList() {
  loading.value = true;
  // 审核列表展示医生/患者发起的取消或排班变更申请
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
  // 重置为“默认通过”，管理员可手动改为驳回
  form.value = {
    id: undefined,
    auditStatus: 1,
    auditRemark: undefined
  };
  proxy.resetForm("auditRef");
}

/** 搜索按钮操作 */
function handleQuery() {
  // 新条件检索要回到第一页，避免页码越界无数据
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
  // 处理模式：只需要带上本条申请的核心展示字段
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
    // 详情接口可能不返回列表上的冗余展示字段，这里从 row 回填
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
      // 审核提交后刷新列表，确保“待审核”数量和状态实时一致
      processAudit(form.value).then(response => {
        proxy.$modal.msgSuccess("处理成功");
        open.value = false;
        getList();
      });
    }
  });
}

function getStatusLabel(status) {
  // 审核状态码 -> 中文标签
  const labels = { 0: "待审核", 1: "已通过", 2: "已驳回" };
  return labels[status] || "未知";
}

function getStatusType(status) {
  // 审核状态码 -> Tag 颜色
  const types = { 0: "warning", 1: "success", 2: "danger" };
  return types[status] || "info";
}

// 页面初始化即拉取审核列表
getList();
</script>
