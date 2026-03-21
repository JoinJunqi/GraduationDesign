<template>
  <div class="app-container consultation-container">
    <el-row :gutter="20">
      <!-- 左侧：患者信息与诊断 -->
      <el-col :span="16">
        <el-card class="box-card patient-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><User /></el-icon> 患者就诊信息</span>
              <el-tag type="success" effect="dark">{{ appointment.status }}</el-tag>
            </div>
          </template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="患者姓名">
              <span class="info-value">{{ appointment.patientName }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="预约科室">
              <span class="info-value">{{ appointment.deptName }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="就诊医生">
              <span class="info-value">{{ appointment.doctorName }}</span>
              <span v-if="appointment.title" class="doctor-title" style="margin-left: 10px; color: #999; font-size: 13px;">{{ appointment.title }}</span>
            </el-descriptions-item>
            <el-descriptions-item label="出诊日期">
              {{ appointment.workDate }}
            </el-descriptions-item>
            <el-descriptions-item label="班次">
              {{ appointment.timeSlot }}
            </el-descriptions-item>
            <el-descriptions-item label="预约时间">
              {{ appointment.appointmentTime }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <el-card class="box-card form-card" shadow="hover" style="margin-top: 20px;">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><EditPen /></el-icon> 病历书写</span>
            </div>
          </template>
          <el-form ref="recordRef" :model="form" :rules="rules" label-width="100px" label-position="top">
            <el-form-item label="诊断结果" prop="diagnosis">
              <el-input
                v-model="form.diagnosis"
                type="textarea"
                :rows="4"
                placeholder="请详细描述患者的症状及初步诊断结果..."
              />
            </el-form-item>
            <el-form-item label="处方信息" prop="prescription">
              <el-input
                v-model="form.prescription"
                type="textarea"
                :rows="6"
                placeholder="请输入药名、剂量、用法等处方信息..."
              />
            </el-form-item>
            <el-form-item label="医嘱备注" prop="notes">
              <el-input
                v-model="form.notes"
                type="textarea"
                :rows="3"
                placeholder="请输入给患者的特别注意事项或医嘱..."
              />
            </el-form-item>
          </el-form>
          <div class="form-actions">
            <el-button type="primary" size="large" icon="DocumentChecked" @click="submitForm">仅保存病历</el-button>
            <el-button type="success" size="large" icon="CircleCheck" @click="handleFinishConsultation">就诊完成</el-button>
            <el-button size="large" icon="Back" @click="handleBack">返回列表</el-button>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧：快速操作/提示 -->
      <el-col :span="8">
        <el-card class="box-card tips-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><InfoFilled /></el-icon> 就诊提示</span>
            </div>
          </template>
          <div class="tips-content">
            <p><el-icon class="tip-icon"><CaretRight /></el-icon> 请仔细核对患者身份信息。</p>
            <p><el-icon class="tip-icon"><CaretRight /></el-icon> 诊断结果需清晰明了，便于后续查询。</p>
            <p><el-icon class="tip-icon"><CaretRight /></el-icon> 处方信息请务必确认剂量与频次。</p>
            <p><el-icon class="tip-icon"><CaretRight /></el-icon> 点击“就诊完成”后，系统将自动将预约状态更新为“已完成”。</p>
          </div>
        </el-card>

        <el-card class="box-card history-card" shadow="hover" style="margin-top: 20px;">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><Clock /></el-icon> 就诊历史记录</span>
              <el-tag v-if="historyTotal > 0" type="info" effect="plain">{{ historyTotal }}</el-tag>
            </div>
          </template>
          <el-skeleton :loading="historyLoading" animated>
            <template #template>
              <div class="history-skeleton">
                <el-skeleton-item variant="text" style="width: 65%" />
                <el-skeleton-item variant="text" style="width: 90%" />
                <el-skeleton-item variant="text" style="width: 80%" />
                <el-skeleton-item variant="text" style="width: 70%" />
              </div>
            </template>
            <template #default>
              <div v-if="historyRecords.length === 0" class="history-empty">
                <el-empty description="暂无历史就诊记录" :image-size="100" />
              </div>
              <div v-else class="history-list">
                <el-scrollbar max-height="520px">
                  <el-timeline>
                    <el-timeline-item
                      v-for="item in historyRecords"
                      :key="item.id"
                      :timestamp="parseTime(item.visitTime)"
                      type="primary"
                      placement="top"
                    >
                      <div class="history-item">
                        <div class="history-item-title">
                          <span>{{ item.deptName || '-' }}</span>
                          <span class="split">·</span>
                          <span>{{ item.doctorName || '-' }}</span>
                          <span v-if="item.title" class="split">·</span>
                          <span v-if="item.title">{{ item.title }}</span>
                        </div>
                        <div class="history-item-content">
                          <div class="history-item-row">
                            <span class="label">诊断</span>
                            <span class="value">{{ item.diagnosis || '-' }}</span>
                          </div>
                        </div>
                        <div class="history-item-actions">
                          <el-button link type="primary" @click="openHistoryDetail(item)">详情</el-button>
                          <el-button link type="primary" @click="appendHistoryToNotes(item)">引用到医嘱</el-button>
                        </div>
                      </div>
                    </el-timeline-item>
                  </el-timeline>
                </el-scrollbar>
                <div class="history-pagination" v-if="historyTotal > historyPageSize">
                  <pagination
                    :total="historyTotal"
                    v-model:page="historyPageNum"
                    v-model:limit="historyPageSize"
                    @pagination="loadHistory"
                    layout="prev, pager, next"
                    :pager-count="5"
                  />
                </div>
              </div>
            </template>
          </el-skeleton>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog title="历史病历详情" v-model="historyDetailOpen" width="650px" append-to-body>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="就诊时间">{{ parseTime(historyDetail.visitTime) }}</el-descriptions-item>
        <el-descriptions-item label="就诊科室">{{ historyDetail.deptName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="就诊医生">{{ historyDetail.doctorName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="职称">{{ historyDetail.title || '-' }}</el-descriptions-item>
        <el-descriptions-item label="诊断结果">{{ historyDetail.diagnosis || '-' }}</el-descriptions-item>
        <el-descriptions-item label="处方信息">{{ historyDetail.prescription || '-' }}</el-descriptions-item>
        <el-descriptions-item label="医嘱备注">{{ historyDetail.notes || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="historyDetailOpen = false">关 闭</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Consultation">
import { ref, reactive, onMounted, getCurrentInstance } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { getAppointment } from "@/api/hospital/appointment";
import { addRecord, updateRecord, listRecord } from "@/api/hospital/record";
import { parseTime } from "@/utils/ruoyi";
import useUserStore from "@/store/modules/user";
// 导入图标组件
import { User, EditPen, InfoFilled, CaretRight, Clock, DocumentChecked, CircleCheck, Back } from '@element-plus/icons-vue';

const { proxy } = getCurrentInstance();
const route = useRoute();
const router = useRouter();
const userStore = useUserStore();

const appointmentId = ref(route.query.appointmentId);
const appointment = ref({});
const loading = ref(false);

const historyLoading = ref(false);
const historyRecords = ref([]);
const historyTotal = ref(0);
const historyPageNum = ref(1);
const historyPageSize = ref(6);
const historyDetailOpen = ref(false);
const historyDetail = ref({});

const form = ref({
  id: null,
  appointmentId: null,
  patientId: null,
  doctorId: null,
  diagnosis: '',
  prescription: '',
  notes: '',
  visitTime: parseTime(new Date())
});

const rules = {
  diagnosis: [{ required: true, message: "诊断结果不能为空", trigger: "blur" }],
  prescription: [{ required: true, message: "处方信息不能为空", trigger: "blur" }]
};

/** 获取预约详情 */
function getDetail() {
  if (!appointmentId.value) return;
  loading.value = true;
  getAppointment(appointmentId.value).then(response => {
    appointment.value = response.data;
    form.value.appointmentId = appointment.value.id;
    form.value.patientId = appointment.value.patientId;
    form.value.doctorId = userStore.id;
    loading.value = false;
    loadHistory();
  }).catch(() => {
    loading.value = false;
  });
}

function loadHistory() {
  if (!appointmentId.value) return;
  historyLoading.value = true;
  const query = {
    pageNum: historyPageNum.value,
    pageSize: historyPageSize.value,
    appointmentId: appointmentId.value,
    orderByColumn: 'visitTime',
    isAsc: 'descending',
    params: {
      includeDeleted: 'false'
    }
  };
  listRecord(query).then(res => {
    historyRecords.value = res.rows || [];
    historyTotal.value = res.total || 0;
    historyLoading.value = false;

    if (!form.value.id) {
      const current = historyRecords.value.find(r => String(r.appointmentId) === String(appointmentId.value));
      if (current) {
        form.value.id = current.id;
        form.value.diagnosis = current.diagnosis || '';
        form.value.prescription = current.prescription || '';
        form.value.notes = current.notes || '';
        form.value.visitTime = current.visitTime || form.value.visitTime;
      }
    }
  }).catch(() => {
    historyLoading.value = false;
  });
}

function openHistoryDetail(item) {
  historyDetail.value = item || {};
  historyDetailOpen.value = true;
}

function appendHistoryToNotes(item) {
  if (!item) return;
  const header = `【既往就诊】${parseTime(item.visitTime)} ${item.deptName || ''} ${item.doctorName || ''}`.trim();
  const content = [
    header,
    item.diagnosis ? `诊断：${item.diagnosis}` : null,
    item.prescription ? `处方：${item.prescription}` : null,
    item.notes ? `医嘱：${item.notes}` : null
  ].filter(Boolean).join('\n');
  form.value.notes = [form.value.notes, content].filter(Boolean).join('\n\n');
}

/** 仅保存病历 */
function submitForm() {
  proxy.$refs["recordRef"].validate(valid => {
    if (valid) {
      const saveAction = form.value.id != null ? updateRecord(form.value) : addRecord(form.value);
      saveAction.then(response => {
        proxy.$modal.msgSuccess("保存成功");
        loadHistory();
      });
    }
  });
}

/** 就诊完成 */
function handleFinishConsultation() {
  proxy.$refs["recordRef"].validate(valid => {
    if (valid) {
      proxy.$modal.confirm('确认完成就诊并保存病历吗？').then(() => {
        // 后端 MedicalRecordServiceImpl 已优化，addRecord 会同步更新预约状态为已完成
        const saveAction = form.value.id != null ? updateRecord(form.value) : addRecord(form.value);
        return saveAction;
      }).then(() => {
        proxy.$modal.msgSuccess("就诊已完成");
        handleBack();
      }).catch(() => {});
    }
  });
}

/** 返回列表 */
function handleBack() {
  router.push({ path: '/hospital/appointment' });
}

onMounted(() => {
  getDetail();
});
</script>

<style lang="scss" scoped>
.consultation-container {
  background-color: #f5f7fa;
  min-height: calc(100vh - 84px);
  padding: 20px;

  .box-card {
    border-radius: 8px;
    border: none;
    
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .header-title {
        font-size: 18px;
        font-weight: bold;
        display: flex;
        align-items: center;
        
        .el-icon {
          margin-right: 8px;
          color: #409eff;
        }
      }
    }
  }

  .patient-card {
    .info-value {
      font-weight: bold;
      color: #303133;
    }
  }

  .form-card {
    .form-actions {
      margin-top: 30px;
      display: flex;
      justify-content: center;
      gap: 20px;
    }
  }

  .tips-card {
    .tips-content {
      padding: 10px;
      p {
        color: #606266;
        font-size: 14px;
        line-height: 2;
        display: flex;
        align-items: center;
        margin: 8px 0;
        
        .tip-icon {
          color: #e6a23c;
          margin-right: 8px;
        }
      }
    }
  }

  .history-card {
    .history-placeholder {
      padding: 20px 0;
    }
  }
}

:deep(.el-descriptions__label) {
  width: 100px;
  background-color: #f9fafc;
}

:deep(.el-form-item__label) {
  font-weight: bold;
  font-size: 15px;
}

  .history-card {
    .history-skeleton {
      padding: 8px 0;
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .history-item {
      padding: 10px 12px;
      border: 1px solid #ebeef5;
      border-radius: 8px;
      background: #fff;
    }

    .history-item-title {
      font-weight: 600;
      color: #303133;
      margin-bottom: 8px;
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      align-items: center;
    }

    .split {
      color: #c0c4cc;
    }

    .history-item-content {
      color: #606266;
      font-size: 13px;
    }

    .history-item-row {
      display: flex;
      gap: 10px;
      line-height: 1.6;
      margin-bottom: 4px;
    }

    .label {
      width: 38px;
      color: #909399;
      flex: 0 0 auto;
    }

    .value {
      flex: 1 1 auto;
      overflow: hidden;
      text-overflow: ellipsis;
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
    }

    .history-item-actions {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      margin-top: 8px;
    }

    .history-pagination {
      margin-top: 12px;
      display: flex;
      justify-content: center;
    }
  }
</style>
