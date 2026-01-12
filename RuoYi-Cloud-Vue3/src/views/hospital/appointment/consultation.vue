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
            </div>
          </template>
          <div class="history-placeholder">
            <el-empty description="暂无历史就诊记录" :image-size="100" />
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup name="Consultation">
import { ref, reactive, onMounted, getCurrentInstance } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { getAppointment } from "@/api/hospital/appointment";
import { addRecord, updateRecord } from "@/api/hospital/record";
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
  }).catch(() => {
    loading.value = false;
  });
}

/** 仅保存病历 */
function submitForm() {
  proxy.$refs["recordRef"].validate(valid => {
    if (valid) {
      const saveAction = form.value.id != null ? updateRecord(form.value) : addRecord(form.value);
      saveAction.then(response => {
        proxy.$modal.msgSuccess("保存成功");
        if (!form.value.id && response.data) {
          form.value.id = response.data.id;
        }
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
</style>
