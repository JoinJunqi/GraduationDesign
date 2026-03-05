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
      <div class="mb20 filter-container">
        <div class="top-row">
          <el-button icon="Back" @click="activeStep = 0">返回重选科室</el-button>
          <span class="ml20">当前科室：<el-tag>{{ selectedDept.name }}</el-tag></span>
        </div>
        
        <div class="date-filter mt10">
          <span class="filter-tip">选择日期查看当前有排班的医生：</span>
          <el-date-picker
            v-model="doctorFilterDate"
            type="date"
            placeholder="选择日期筛选"
            value-format="YYYY-MM-DD"
            :disabled-date="disabledDate"
            @change="handleDoctorDateChange"
          />
        </div>
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
        <el-empty v-if="doctorList.length === 0" description="该日期下暂无医生排班" />
      </el-row>
    </div>

    <!-- Step 3: Select Schedule -->
    <div v-if="activeStep === 2">
      <div class="mb20 filter-container">
        <div class="top-row">
          <el-button icon="Back" @click="activeStep = 1">返回重选医生</el-button>
          <span class="ml20">当前医生：<el-tag type="success">{{ selectedDoctor.name }}</el-tag></span>
        </div>
        
        <div class="date-filter mt10">
          <span class="filter-tip">选择日期筛选排班：</span>
          <el-date-picker
            v-model="scheduleFilterDate"
            type="date"
            placeholder="显示所有排班"
            value-format="YYYY-MM-DD"
            :disabled-date="disabledDate"
            @change="handleScheduleDateChange"
            clearable
          />
        </div>
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
            <el-tag v-else-if="scope.row.status === 3" type="warning">待审核</el-tag>
            <el-tag v-else-if="scope.row.status === 4" type="danger">已驳回</el-tag>
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
            <el-tooltip
              class="box-item"
              effect="dark"
              :content="getScheduleTooltip(scope.row)"
              placement="top"
              :disabled="!isScheduleExpired(scope.row)"
            >
              <div style="display: inline-block;">
                <el-button
                  type="primary"
                  :disabled="scope.row.availableSlots <= 0 || isScheduleExpired(scope.row)"
                  @click="handleSelectSchedule(scope.row)"
                >立即预约</el-button>
              </div>
            </el-tooltip>
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
              :content="getTooltipContent(time)"
              placement="top"
              :disabled="!isSlotDisabled(time)"
            >
              <el-button 
                :type="selectedTime === time ? 'primary' : 'default'" 
                class="time-slot-btn"
                :disabled="isSlotDisabled(time)"
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
const allDoctorList = ref([]); // 缓存所有医生
const scheduleList = ref([]);
const allScheduleList = ref([]); // 缓存所有排班

const selectedDept = ref({});
const selectedDoctor = ref({});
const selectedSchedule = ref({});
const selectedTime = ref("");
const availableTimeSlots = ref([]);
const bookedTimeSlots = ref([]);

const doctorFilterDate = ref("");
const scheduleFilterDate = ref("");

/** 禁用过去日期 */
function disabledDate(time) {
  return time.getTime() < Date.now() - 8.64e7; // 禁用今天之前的日期
}

/** 生成时间段 */
function generateTimeSlots(schedule) {
  const slotType = schedule.timeSlot;
  const totalCapacity = schedule.totalCapacity;
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
  
  // 计算已过期的号源数量
  let expiredCount = 0;
  if (schedule.workDate) {
    const dateStr = parseTime(schedule.workDate, '{y}-{m}-{d}');
    const now = new Date();
    
    for (const time of baseSlots) {
      const dateTimeStr = `${dateStr} ${time}`;
      const slotTime = new Date(dateTimeStr.replace(/-/g, '/'));
      if (now > slotTime) {
        expiredCount++;
      }
    }
  }

  // 根据总号源数限制时段数量 (加上已过期的数量，确保剩余可用号源数等于 totalCapacity)
  // 注意：不能超过 baseSlots 总长度
  const limit = Math.min(baseSlots.length, totalCapacity + expiredCount);
  
  return baseSlots.slice(0, limit);
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
  doctorFilterDate.value = ""; // 重置筛选日期
  getDoctorList(dept.id);
}

/** 加载医生列表 */
function getDoctorList(deptId) {
  console.log('Fetching doctors for dept:', deptId);
  loading.value = true;
  listDoctorByDept(deptId).then(response => {
    console.log('Doctor list response:', response);
    const list = response.rows || response.data || (Array.isArray(response) ? response : []);
    allDoctorList.value = list; // 缓存完整列表
    doctorList.value = list;    // 默认显示所有
    loading.value = false;
  }).catch(err => {
    console.error('Failed to fetch doctors:', err);
    loading.value = false;
  });
}

/** 医生日期筛选变更 */
function handleDoctorDateChange(date) {
  if (!date) {
    // 如果清空日期，显示所有医生
    doctorList.value = allDoctorList.value;
    return;
  }
  
  loading.value = true;
  // 查询该日期下有排班的医生
  const query = {
    deptId: selectedDept.value.id,
    workDate: date
  };
  
  listSchedule(query).then(response => {
    const schedules = response.rows || [];
    // 获取有排班的医生ID集合
    const doctorIds = new Set(schedules.map(s => s.doctorId));
    // 过滤医生列表
    doctorList.value = allDoctorList.value.filter(d => doctorIds.has(d.id));
    loading.value = false;
  }).catch(err => {
    console.error('Failed to filter doctors:', err);
    loading.value = false;
  });
}

/** 选择医生 */
function handleSelectDoctor(doctor) {
  console.log('Selected doctor:', doctor);
  selectedDoctor.value = doctor;
  activeStep.value = 2;
  scheduleFilterDate.value = ""; // 重置筛选日期
  // 如果在医生列表页已经选择了日期，自动带入到排班页
  if (doctorFilterDate.value) {
    scheduleFilterDate.value = doctorFilterDate.value;
  }
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
    // 仅过滤掉已取消的排班
    const validList = rawList.filter(s => s.status !== 2);
    allScheduleList.value = validList; // 缓存完整列表
    
    // 如果有预设的筛选日期，进行过滤
    if (scheduleFilterDate.value) {
      scheduleList.value = validList.filter(s => parseTime(s.workDate, '{y}-{m}-{d}') === scheduleFilterDate.value);
    } else {
      scheduleList.value = validList;
    }
    
    loading.value = false;
  }).catch(err => {
    console.error('Failed to fetch schedules:', err);
    loading.value = false;
  });
}

/** 排班日期筛选变更 */
function handleScheduleDateChange(date) {
  if (!date) {
    scheduleList.value = allScheduleList.value;
  } else {
    scheduleList.value = allScheduleList.value.filter(s => parseTime(s.workDate, '{y}-{m}-{d}') === date);
  }
}

/** 检查排班是否已过期 (超过当天17:30) */
function isScheduleExpired(schedule) {
  if (!schedule.workDate) return false;
  
  const todayStr = parseTime(new Date(), '{y}-{m}-{d}');
  const workDateStr = parseTime(schedule.workDate, '{y}-{m}-{d}');
  
  // 1. 如果是过去日期，肯定过期
  if (workDateStr < todayStr) return true;
  
  // 2. 如果是今天，检查时间是否超过 17:30
  if (workDateStr === todayStr) {
    const now = new Date();
    // 17:30 = 17 * 60 + 30 = 1050 分钟
    const deadline = 17 * 60 + 30;
    const current = now.getHours() * 60 + now.getMinutes();
    return current > deadline;
  }
  
  // 3. 未来日期，不过期
  return false;
}

/** 获取排班 Tooltip 内容 */
function getScheduleTooltip(schedule) {
  if (isScheduleExpired(schedule)) {
    return '已过当天预约时间';
  }
  return '';
}

/** 选择排班 */
function handleSelectSchedule(schedule) {
  selectedSchedule.value = schedule;
  availableTimeSlots.value = generateTimeSlots(schedule);
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

/** 检查时段是否已过期 */
function isTimeExpired(time) {
  if (!selectedSchedule.value.workDate) return false;
  // 获取日期字符串 YYYY-MM-DD
  const dateStr = parseTime(selectedSchedule.value.workDate, '{y}-{m}-{d}');
  // 组合成完整的时间字符串 YYYY-MM-DD HH:mm:ss
  const dateTimeStr = `${dateStr} ${time}`;
  // 转换为 Date 对象 (兼容 IOS 需替换 - 为 /)
  const slotTime = new Date(dateTimeStr.replace(/-/g, '/'));
  return new Date() > slotTime;
}

/** 检查时段是否不可用 */
function isSlotDisabled(time) {
  // 1. 已被预约
  if (bookedTimeSlots.value.includes(time)) return true;
  // 2. 号源已满
  if (selectedSchedule.value.availableSlots <= 0) return true;
  // 3. 排班状态异常
  if (selectedSchedule.value.status === 2) return true;
  // 4. 已过期
  if (isTimeExpired(time)) return true;
  
  return false;
}

/** 获取 Tooltip 内容 */
function getTooltipContent(time) {
  if (bookedTimeSlots.value.includes(time)) {
    return '该时段已被预约';
  }
  if (isTimeExpired(time)) {
    return '不可预约该时段';
  }
  if (selectedSchedule.value.availableSlots <= 0) {
    return '号源已满';
  }
  if (selectedSchedule.value.status === 2) {
    return '排班已取消';
  }
  return '不可预约';
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
.filter-container {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.top-row {
  display: flex;
  align-items: center;
}

.date-filter {
  /* margin-left: auto; */ /* 移除自动左边距，使其靠左对齐 */
  display: flex;
  align-items: center;
}

.mt10 {
  margin-top: 10px;
}

.filter-tip {
  font-size: 14px;
  color: #606266;
  margin-right: 10px;
}

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
