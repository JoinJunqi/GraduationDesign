<template>
  <div class="appointment-sidebar-container">
    <!-- Toggle Button -->
    <div class="sidebar-toggle" @click="visible = !visible" :class="{ 'is-open': visible }">
      <el-icon><Calendar /></el-icon>
      <span class="toggle-text">我的日程</span>
    </div>

    <!-- Sidebar Content -->
    <div class="sidebar-content" :class="{ 'is-visible': visible }">
      <div class="sidebar-header">
        <span class="title">预约日程</span>
        <el-icon class="close-btn" @click="visible = false"><Close /></el-icon>
      </div>

      <div class="sidebar-body" v-loading="loading">
        <div class="appointment-list">
          
          <!-- Section 1: Latest Expired -->
          <div v-if="latestExpired" class="section-container">
            <div class="section-title">
              <el-icon><Finished /></el-icon> 最新的已过期预约
            </div>
            <div class="appointment-item status-expired">
              <div class="item-header">
                <span class="doctor-name">{{ latestExpired.doctorName }}</span>
                <el-tag size="small" type="danger">{{ latestExpired.status }}</el-tag>
              </div>
              <div class="item-info">
                <p><el-icon><Clock /></el-icon> {{ parseTime(latestExpired.workDate, '{y}-{m}-{d}') }} {{ latestExpired.appointmentTime }}</p>
                <p><el-icon><Location /></el-icon> {{ latestExpired.deptName || '门诊部' }}</p>
              </div>
              <div class="expired-wrapper">
                <div class="expired-tip">该预约已过期，请重新取号排队</div>
              </div>
            </div>
          </div>

          <!-- Section 2: Pending Appointments -->
          <div class="section-container">
            <div class="section-title">
              <el-icon><Timer /></el-icon> 待就诊预约
            </div>
            <template v-if="pendingList.length > 0">
              <div v-for="item in pendingList" :key="item.id" class="appointment-item status-pending">
                <div class="item-header">
                  <span class="doctor-name">{{ item.doctorName }}</span>
                  <el-tag size="small" type="warning">{{ item.status }}</el-tag>
                </div>
                <div class="item-info">
                  <p><el-icon><Clock /></el-icon> {{ parseTime(item.workDate, '{y}-{m}-{d}') }} {{ item.appointmentTime }}</p>
                  <p><el-icon><Location /></el-icon> {{ item.deptName || '门诊部' }}</p>
                </div>
                <div v-if="item.countdown" class="countdown-wrapper">
                  <div class="countdown-timer">
                    倒计时: <span class="timer-value">{{ item.countdown }}</span>
                  </div>
                  <div class="countdown-tip">请提前五分钟到达诊室前等待，过号需重新排队</div>
                </div>
              </div>
            </template>
            <div v-else class="empty-section-text">无</div>
          </div>

          <!-- Section 3: Other Expired Appointments (Today) -->
          <div v-if="otherExpiredList.length > 0" class="section-container">
            <div class="section-title">
              <el-icon><CircleClose /></el-icon> 已过期预约
            </div>
            <div v-for="item in otherExpiredList" :key="item.id" class="appointment-item status-expired">
              <div class="item-header">
                <span class="doctor-name">{{ item.doctorName }}</span>
                <el-tag size="small" type="danger">{{ item.status }}</el-tag>
              </div>
              <div class="item-info">
                <p><el-icon><Clock /></el-icon> {{ parseTime(item.workDate, '{y}-{m}-{d}') }} {{ item.appointmentTime }}</p>
                <p><el-icon><Location /></el-icon> {{ item.deptName || '门诊部' }}</p>
              </div>
              <div class="expired-wrapper">
                <div class="expired-tip">该预约已过期，请重新取号排队</div>
              </div>
            </div>
          </div>

        </div>
      </div>

      <!-- Footer Reminder -->
      <div class="sidebar-footer">
        <div class="cancel-reminder">
          <el-icon><Warning /></el-icon>
          <span>温馨提示：如无法按时就诊，请及时取消预约，避免占用医疗资源。</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { listAppointment } from "@/api/hospital/appointment.js";
import { parseTime } from "@/utils/ruoyi";
import { ElNotification } from 'element-plus';
import { 
  Calendar, 
  Close, 
  Finished, 
  Timer, 
  CircleClose, 
  Clock, 
  Location, 
  Warning, 
  Memo 
} from '@element-plus/icons-vue';

const visible = ref(false);
const loading = ref(false);
const appointments = ref([]);
const timer = ref(null);
const reminderInterval = ref(null);

/** 计算属性：最新的已过期预约 (当日) */
const latestExpired = computed(() => {
  const today = parseTime(new Date(), '{y}-{m}-{d}');
  const todayExpired = appointments.value.filter(item => 
    item.status === '已过期' && parseTime(item.workDate, '{y}-{m}-{d}') === today
  );
  return todayExpired.length > 0 ? todayExpired[0] : null;
});

/** 计算属性：待就诊预约 */
const pendingList = computed(() => {
  return appointments.value.filter(item => item.status === '待就诊');
});

/** 计算属性：其他已过期预约 (当日) */
const otherExpiredList = computed(() => {
  const today = parseTime(new Date(), '{y}-{m}-{d}');
  const todayExpired = appointments.value.filter(item => 
    item.status === '已过期' && parseTime(item.workDate, '{y}-{m}-{d}') === today
  );
  return todayExpired.length > 1 ? todayExpired.slice(1) : [];
});

/** 获取预约列表 */
function getAppointments() {
  loading.value = true;
  const query = {
    pageNum: 1,
    pageSize: 100,
    orderByColumn: 'bookedAt',
    isAsc: 'desc'
  };
  
  listAppointment(query).then(response => {
    const allRows = response.rows || [];
    const today = parseTime(new Date(), '{y}-{m}-{d}');
    
    // 过滤出：1. 待就诊 2. 当日的已过期
    appointments.value = allRows
      .filter(item => {
        const isPending = item.status === '待就诊';
        const isTodayExpired = item.status === '已过期' && parseTime(item.workDate, '{y}-{m}-{d}') === today;
        return isPending || isTodayExpired;
      })
      .map(item => ({
        ...item,
        countdown: null
      }));
      
    updateCountdowns();
    loading.value = false;
  }).catch(() => {
    loading.value = false;
  });
}

/** 获取状态对应的样式 */
function getStatusClass(status) {
  return {
    'status-pending': status === '待就诊',
    'status-completed': status === '已完成',
    'status-cancelled': status === '已取消',
    'status-expired': status === '已过期'
  };
}

/** 获取标签类型 */
function getTagType(status) {
  if (status === '待就诊') return 'warning';
  if (status === '已完成') return 'success';
  if (status === '已取消') return 'info';
  if (status === '已过期') return 'danger';
  return '';
}

/** 更新倒计时和弹窗逻辑 */
function updateCountdowns() {
  const now = new Date();
  
  appointments.value.forEach(item => {
    if (item.status !== '待就诊') return;

    // 组合就诊时间
    const workDateStr = parseTime(item.workDate, '{y}-{m}-{d}');
    const appointmentDateTime = new Date(`${workDateStr} ${item.appointmentTime}`);
    
    const diffMs = appointmentDateTime.getTime() - now.getTime();
    const diffMinutes = Math.floor(diffMs / (1000 * 60));
    const diffSecondsTotal = Math.floor(diffMs / 1000);

    // 1. 倒计时逻辑 (30分钟内)
    if (diffSecondsTotal > 0 && diffMinutes < 30) {
      const minutes = Math.floor(diffSecondsTotal / 60);
      const seconds = diffSecondsTotal % 60;
      item.countdown = `${minutes}:${seconds.toString().padStart(2, '0')}`;
    } else {
      item.countdown = null;
    }

    // 2. 弹窗提醒逻辑 (5小时内，每30分钟提醒一次)
    if (diffMinutes > 0 && diffMinutes <= 300) { // 300分钟 = 5小时
      const lastRemindKey = `remind_${item.id}`;
      const lastRemindTimeStr = sessionStorage.getItem(lastRemindKey);
      const lastRemindTime = lastRemindTimeStr ? new Date(lastRemindTimeStr) : null;
      
      // 如果从未提醒过，或者距离上次提醒超过30分钟
      if (!lastRemindTime || (now.getTime() - lastRemindTime.getTime()) >= 30 * 60 * 1000) {
        showReminder(item);
        sessionStorage.setItem(lastRemindKey, now.toISOString());
      }
    }
  });
}

/** 显示弹窗提醒 */
function showReminder(item) {
  ElNotification({
    title: '就诊提醒',
    message: `您预约的 ${item.doctorName} 医生将在 ${item.appointmentTime} 开始就诊，请注意时间。`,
    type: 'warning',
    duration: 5000,
    position: 'bottom-right'
  });
}

/** 启动定时器 */
function startTimers() {
  // 每秒更新一次倒计时
  timer.value = setInterval(() => {
    updateCountdowns();
  }, 1000);

  // 每5分钟重新拉取一次列表，保证数据同步
  reminderInterval.value = setInterval(() => {
    getAppointments();
  }, 300000);
}

onMounted(() => {
  getAppointments();
  startTimers();
});

onUnmounted(() => {
  if (timer.value) clearInterval(timer.value);
  if (reminderInterval.value) clearInterval(reminderInterval.value);
});
</script>

<style scoped lang="scss">
.appointment-sidebar-container {
  position: fixed;
  right: 0;
  top: 100px;
  z-index: 2000;
  display: flex;
  align-items: flex-start;
}

.sidebar-toggle {
  background-color: #409eff;
  color: white;
  padding: 12px 8px;
  border-radius: 8px 0 0 8px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.15);
  transition: all 0.3s;
  
  &:hover {
    background-color: #66b1ff;
  }
  
  &.is-open {
    transform: translateX(-300px);
  }

  .toggle-text {
    writing-mode: vertical-lr;
    margin-top: 5px;
    font-size: 14px;
    letter-spacing: 2px;
  }
}

.sidebar-content {
  width: 300px;
  height: calc(100vh - 150px);
  background: white;
  box-shadow: -2px 0 12px rgba(0, 0, 0, 0.1);
  position: fixed;
  right: -300px;
  top: 100px;
  transition: right 0.3s;
  display: flex;
  flex-direction: column;
  border-radius: 8px 0 0 8px;
  overflow: hidden;

  &.is-visible {
    right: 0;
  }
}

.sidebar-header {
  padding: 15px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #f8f9fa;

  .title {
    font-weight: bold;
    color: #303133;
  }

  .close-btn {
    cursor: pointer;
    color: #909399;
    &:hover {
      color: #f56c6c;
    }
  }
}

.sidebar-body {
  flex: 1;
  overflow-y: auto;
  padding: 15px;

  .section-container {
    margin-bottom: 25px;

    .section-title {
        font-size: 14px;
        font-weight: bold;
        color: #606266;
        margin-bottom: 12px;
        display: flex;
        align-items: center;
        gap: 6px;
        padding-left: 4px;
        border-left: 3px solid #409eff;
        
        .el-icon {
          font-size: 16px;
        }
      }

      .empty-section-text {
        padding: 10px 15px;
        font-size: 13px;
        color: #909399;
        background: #f8f9fa;
        border-radius: 4px;
        text-align: center;
        border: 1px dashed #e4e7ed;
      }
    }
  }

.appointment-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.appointment-item {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 15px;
  background: #fff;
  transition: all 0.3s;

  &:hover {
    box-shadow: 0 2px 12px 0 rgba(0,0,0,.1);
  }

  &.status-pending {
    border-left: 4px solid #e6a23c;
  }

  &.status-expired {
    border-left: 4px solid #f56c6c;
    background-color: #fef0f0;
  }

  .item-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;

    .doctor-name {
      font-weight: bold;
      font-size: 15px;
    }
  }

  .item-info {
    font-size: 13px;
    color: #606266;
    p {
      margin: 4px 0;
      display: flex;
      align-items: center;
      gap: 5px;
    }
  }
}

.countdown-wrapper {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px dashed #ebeef5;
  
  .countdown-timer {
    color: #f56c6c;
    font-weight: bold;
    font-size: 14px;
    margin-bottom: 4px;
    
    .timer-value {
      font-family: monospace;
      font-size: 16px;
    }
  }

  .countdown-tip {
    font-size: 11px;
    color: #909399;
    line-height: 1.4;
  }
}

.expired-wrapper {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px dashed #fcd3d3;
  
  .expired-tip {
    font-size: 12px;
    color: #f56c6c;
    font-weight: bold;
    display: flex;
    align-items: center;
    gap: 4px;
    &::before {
      content: '●';
      font-size: 10px;
    }
  }
}

.sidebar-footer {
  padding: 15px;
  border-top: 1px solid #f0f0f0;
  background: #fffbe6;
  
  .cancel-reminder {
    font-size: 12px;
    color: #856404;
    display: flex;
    align-items: flex-start;
    gap: 8px;
    line-height: 1.6;
    
    .el-icon {
      margin-top: 2px;
      font-size: 14px;
    }
  }
}

/* 滚动条美化 */
.sidebar-body::-webkit-scrollbar {
  width: 6px;
}
.sidebar-body::-webkit-scrollbar-thumb {
  background: #e5e5e5;
  border-radius: 3px;
}
.sidebar-body::-webkit-scrollbar-track {
  background: transparent;
}
</style>
