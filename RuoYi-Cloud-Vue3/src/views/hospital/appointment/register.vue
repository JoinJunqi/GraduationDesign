<template>
  <div class="app-container">
    <el-card shadow="never" class="mb20">
      <el-steps :active="activeStep" finish-status="success" align-center>
        <el-step title="选择科室" />
        <el-step title="选择医生" />
        <el-step title="选择排班" />
        <el-step title="选择时段" />
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
        <el-table-column label="状态" align="center" prop="status">
          <template #default="scope">
            <el-tag v-if="scope.row.status === 0" type="success">正常</el-tag>
            <el-tag v-else-if="scope.row.status === 1" type="warning">有调整</el-tag>
            <el-tag v-else-if="scope.row.status === 2" type="danger">已取消</el-tag>
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

    <!-- Step 4: Select Time Slot -->
    <div v-if="activeStep === 3">
      <div class="mb20">
        <el-button icon="Back" @click="activeStep = 2">返回重选排班</el-button>
        <span class="ml20">就诊日期：<el-tag>{{ parseTime(selectedSchedule.workDate, '{y}-{m}-{d}') }}</el-tag></span>
        <span class="ml10">班次：<el-tag type="warning">{{ selectedSchedule.timeSlot }}</el-tag></span>
      </div>
      <el-card>
        <template #header>请选择具体就诊时间 (15分钟/号)</template>
        <el-row :gutter="10">
          <el-col v-for="time in availableTimeSlots" :key="time" :span="4" class="mb10">
            <el-tooltip
              class="box-item"
              effect="dark"
              :content="bookedTimeSlots.includes(time) ? '该时段已被预约' : '该时段已不可预约'"
              placement="top"
              :disabled="!bookedTimeSlots.includes(time) && selectedSchedule.availableSlots > 0 && selectedSchedule.status !== 2"
            >
              <el-button 
                :type="selectedTime === time ? 'primary' : 'default'" 
                class="time-slot-btn"
                :disabled="bookedTimeSlots.includes(time) || selectedSchedule.availableSlots <= 0 || selectedSchedule.status === 2"
                @click="handleSelectTime(time)"
              >
                {{ time }}
              </el-button>
            </el-tooltip>
          </el-col>
        </el-row>
        <div class="mt20 text-center">
          <el-button type="primary" size="large" :disabled="!selectedTime" @click="activeStep = 4">下一步</el-button>
        </div>
      </el-card>
    </div>

    <!-- Step 5: Confirm -->
    <div v-if="activeStep === 4">
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
          <el-descriptions-item label="就诊时间">
             <el-tag type="success" effect="dark">{{ selectedTime }}</el-tag>
          </el-descriptions-item>
        </el-descriptions>
        <div class="mt20 text-center">
          <el-button @click="activeStep = 3">返回修改</el-button>
          <el-button type="success" size="large" @click="confirmAppointment" :loading="submitting">确认提交预约</el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup name="AppointmentRegister">
import { ref, onMounted, getCurrentInstance } from 'vue';
import { useRouter } from 'vue-router';
import { listDepartment } from "@/api/hospital/department.js";
import { listDoctorByDept } from "@/api/hospital/doctor.js";
import { listSchedule } from "@/api/hospital/schedule.js";
import { addAppointment, listAppointment } from "@/api/hospital/appointment.js";
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
const selectedTime = ref("");
const availableTimeSlots = ref([]);
const bookedTimeSlots = ref([]);

/** 生成时间段 */
function generateTimeSlots(slotType, totalCapacity) {
  const slots = [];
  const baseSlots = [];
  if (slotType === '上午' || slotType === '全天') {
    // 8:00 - 11:30
    for (let h = 8; h <= 11; h++) {
      for (let m = 0; m < 60; m += 15) {
        if (h === 11 && m > 15) break; 
        baseSlots.push(`${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:00`);
      }
    }
  }
  if (slotType === '下午' || slotType === '全天') {
    // 14:00 - 17:30
    for (let h = 14; h <= 17; h++) {
      for (let m = 0; m < 60; m += 15) {
        if (h === 17 && m > 15) break;
        baseSlots.push(`${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:00`);
      }
    }
  }
  
  // 根据总号源数限制时段数量
  return baseSlots.slice(0, totalCapacity);
}

/** 加载科室列表 */
function getDeptList() {
  console.log('Fetching department list...');
  loading.value = true;
  listDepartment().then(response => {
    console.log('Department list response:', response);
    departmentList.value = response.rows || response.data || (Array.isArray(response) ? response : []);
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
    doctorList.value = response.rows || response.data || (Array.isArray(response) ? response : []);
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
    const rawList = response.rows || response.data || (Array.isArray(response) ? response : []);
    const today = new Date().toISOString().split('T')[0];
    // 过滤掉已取消的排班 (或者保留但显示已取消)
    scheduleList.value = rawList.filter(s => s.workDate >= today && s.status !== 2);
    loading.value = false;
  }).catch(err => {
    console.error('Failed to fetch schedules:', err);
    loading.value = false;
  });
}

/** 选择排班 */
function handleSelectSchedule(schedule) {
  selectedSchedule.value = schedule;
  availableTimeSlots.value = generateTimeSlots(schedule.timeSlot, schedule.totalCapacity);
  selectedTime.value = "";
  
  // 获取已预约的时段
  loading.value = true;
  listAppointment({ scheduleId: schedule.id }).then(response => {
    bookedTimeSlots.value = (response.rows || []).map(item => item.appointmentTime);
    activeStep.value = 3;
    loading.value = false;
  }).catch(() => {
    loading.value = false;
    activeStep.value = 3;
  });
}

/** 选择时间 */
function handleSelectTime(time) {
  selectedTime.value = time;
}

/** 提交预约 */
function confirmAppointment() {
  if (!selectedSchedule.value.id) {
    proxy.$modal.msgError("请先选择一个排班");
    return;
  }
  if (!selectedTime.value) {
    proxy.$modal.msgError("请选择就诊时段");
    return;
  }
  
  submitting.value = true;
  console.log('Submitting appointment for schedule:', selectedSchedule.value.id);
  
  const data = {
    scheduleId: selectedSchedule.value.id,
    appointmentTime: selectedTime.value
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
