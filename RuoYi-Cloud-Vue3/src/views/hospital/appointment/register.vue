<template>
  <div class="app-container">
    <el-card shadow="never" class="mb20">
      <el-steps :active="activeStep" finish-status="success" align-center>
        <el-step title="选择科室" />
        <el-step title="选择医生" />
        <el-step title="选择排班" />
        <el-step title="确认预约" />
      </el-steps>
    </el-card>

    <!-- Step 1: Select Department -->
    <div v-if="activeStep === 0" v-loading="loading">
      <el-row :gutter="20" v-if="departmentList.length > 0">
        <el-col v-for="dept in departmentList" :key="dept.id" :xs="24" :sm="12" :md="8" :lg="6" class="mb20">
          <el-card hover shadow="hover" class="dept-card" @click="handleSelectDept(dept)">
            <div class="dept-info">
              <el-icon class="dept-icon"><OfficeBuilding /></el-icon>
              <div class="dept-name">{{ dept.name }}</div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      <el-empty v-else :description="loading ? '正在加载科室...' : '暂无科室数据，请联系管理员添加'" />
    </div>

    <!-- Step 2: Select Doctor -->
    <div v-if="activeStep === 1">
      <div class="mb20">
        <el-button icon="Back" @click="activeStep = 0">返回重选科室</el-button>
        <span class="ml20">当前科室：<el-tag>{{ selectedDept.name }}</el-tag></span>
      </div>
      <el-row :gutter="20">
        <el-col v-for="doctor in doctorList" :key="doctor.id" :xs="24" :sm="12" :md="8" :lg="6" class="mb20">
          <el-card hover shadow="hover" class="doctor-card" @click="handleSelectDoctor(doctor)">
            <div class="doctor-header">
              <el-avatar :size="60" icon="UserFilled" />
              <div class="doctor-meta">
                <div class="doctor-name">{{ doctor.name }}</div>
                <div class="doctor-title">{{ doctor.title || '普通医生' }}</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-empty v-if="doctorList.length === 0" description="该科室暂无医生出诊" />
      </el-row>
    </div>

    <!-- Step 3: Select Schedule -->
    <div v-if="activeStep === 2">
      <div class="mb20">
        <el-button icon="Back" @click="activeStep = 1">返回重选医生</el-button>
        <span class="ml20">当前医生：<el-tag type="success">{{ selectedDoctor.name }}</el-tag></span>
      </div>
      <el-table :data="scheduleList" border stripe v-loading="loading">
        <el-table-column label="就诊日期" align="center" prop="workDate">
          <template #default="scope">
            <span>{{ parseTime(scope.row.workDate, '{y}-{m}-{d}') }}</span>
          </template>
        </el-table-column>
        <el-table-column label="班次" align="center" prop="timeSlot">
          <template #default="scope">
            <el-tag :type="scope.row.timeSlot === '上午' ? 'primary' : 'warning'">{{ scope.row.timeSlot }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="剩余号源" align="center" prop="availableSlots">
          <template #default="scope">
            <el-tag :type="scope.row.availableSlots > 0 ? 'success' : 'danger'">
              {{ scope.row.availableSlots }} / {{ scope.row.totalCapacity }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="center">
          <template #default="scope">
            <el-button
              type="primary"
              :disabled="scope.row.availableSlots <= 0"
              @click="handleSelectSchedule(scope.row)"
            >立即预约</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="scheduleList.length === 0" description="该医生暂无排班计划" />
    </div>

    <!-- Step 4: Confirm -->
    <div v-if="activeStep === 3">
      <el-card class="confirm-card">
        <template #header>
          <div class="card-header">
            <span>预约信息确认</span>
          </div>
        </template>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="就诊科室">{{ selectedDept.name }}</el-descriptions-item>
          <el-descriptions-item label="主治医生">{{ selectedDoctor.name }} ({{ selectedDoctor.title }})</el-descriptions-item>
          <el-descriptions-item label="就诊日期">{{ parseTime(selectedSchedule.workDate, '{y}-{m}-{d}') }}</el-descriptions-item>
          <el-descriptions-item label="就诊班次">
             <el-tag>{{ selectedSchedule.timeSlot }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <div class="mt20 text-center">
          <el-button @click="activeStep = 2">返回修改</el-button>
          <el-button type="success" size="large" @click="confirmAppointment" :loading="submitting">确认提交预约</el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup name="AppointmentRegister">
import { ref, onMounted, getCurrentInstance } from 'vue';
import { useRouter } from 'vue-router';
import { listDepartment } from "@/api/hospital/department";
import { listDoctorByDept } from "@/api/hospital/doctor";
import { listSchedule } from "@/api/hospital/schedule";
import { addAppointment } from "@/api/hospital/appointment";
import { parseTime } from "@/utils/ruoyi";
import { ElMessage } from 'element-plus';

const { proxy } = getCurrentInstance();
const router = useRouter();
const loading = ref(false);
const submitting = ref(false);
const activeStep = ref(0);

const departmentList = ref([]);
const doctorList = ref([]);
const scheduleList = ref([]);

const selectedDept = ref({});
const selectedDoctor = ref({});
const selectedSchedule = ref({});

/** 加载科室列表 */
function getDeptList() {
  console.log('Fetching department list...');
  loading.value = true;
  listDepartment().then(response => {
    console.log('Department list response:', response);
    departmentList.value = response.data || [];
    loading.value = false;
  }).catch(err => {
    console.error('Failed to fetch departments:', err);
    loading.value = false;
  });
}

/** 选择科室 */
function handleSelectDept(dept) {
  console.log('Selected department:', dept);
  selectedDept.value = dept;
  activeStep.value = 1;
  getDoctorList(dept.id);
}

/** 加载医生列表 */
function getDoctorList(deptId) {
  console.log('Fetching doctors for dept:', deptId);
  loading.value = true;
  listDoctorByDept(deptId).then(response => {
    console.log('Doctor list response:', response);
    doctorList.value = response.data || [];
    loading.value = false;
  }).catch(err => {
    console.error('Failed to fetch doctors:', err);
    loading.value = false;
  });
}

/** 选择医生 */
function handleSelectDoctor(doctor) {
  console.log('Selected doctor:', doctor);
  selectedDoctor.value = doctor;
  activeStep.value = 2;
  getScheduleList(doctor.id);
}

/** 加载排班列表 */
function getScheduleList(doctorId) {
  console.log('Fetching schedules for doctor:', doctorId);
  loading.value = true;
  const query = {
    doctorId: doctorId
  };
  listSchedule(query).then(response => {
    console.log('Schedule list response:', response);
    const rawList = response.data || [];
    const today = new Date().toISOString().split('T')[0];
    scheduleList.value = rawList.filter(s => s.workDate >= today);
    loading.value = false;
  }).catch(err => {
    console.error('Failed to fetch schedules:', err);
    loading.value = false;
  });
}

/** 选择排班 */
function handleSelectSchedule(schedule) {
  selectedSchedule.value = schedule;
  activeStep.value = 3;
}

/** 提交预约 */
function confirmAppointment() {
  if (!selectedSchedule.value.id) {
    proxy.$modal.msgError("请先选择一个排班");
    return;
  }
  
  submitting.value = true;
  console.log('Submitting appointment for schedule:', selectedSchedule.value.id);
  
  const data = {
    scheduleId: selectedSchedule.value.id
  };
  
  addAppointment(data).then(response => {
    console.log('Appointment success response:', response);
    proxy.$modal.msgSuccess("预约成功！");
    // 跳转到我的预约列表 (index.vue)
    router.push("/hospital/appointment");
  }).catch(err => {
    console.error('Appointment failed:', err);
    submitting.value = false;
    // 错误信息通常由 request.js 统一拦截弹出，这里做兜底
  });
}

onMounted(() => {
  console.log('AppointmentRegister component mounted');
  getDeptList();
});
</script>

<style scoped lang="scss">
.dept-card {
  cursor: pointer;
  text-align: center;
  transition: all 0.3s;
  &:hover {
    transform: translateY(-5px);
    border-color: #409eff;
  }
  .dept-info {
    padding: 20px 0;
    .dept-icon {
      font-size: 40px;
      color: #409eff;
      margin-bottom: 10px;
    }
    .dept-name {
      font-size: 18px;
      font-weight: bold;
    }
  }
}

.doctor-card {
  cursor: pointer;
  transition: all 0.3s;
  &:hover {
    transform: translateY(-5px);
    border-color: #67c23a;
  }
  .doctor-header {
    display: flex;
    align-items: center;
    .doctor-meta {
      margin-left: 15px;
      .doctor-name {
        font-size: 18px;
        font-weight: bold;
      }
      .doctor-title {
        font-size: 14px;
        color: #909399;
        margin-top: 5px;
      }
    }
  }
}

.confirm-card {
  max-width: 600px;
  margin: 0 auto;
}

.mb20 {
  margin-bottom: 20px;
}
.ml20 {
  margin-left: 20px;
}
.mt20 {
  margin-top: 20px;
}
.text-center {
  text-align: center;
}
</style>
