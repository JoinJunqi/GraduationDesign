<template>
  <div class="navbar">
    <hamburger id="hamburger-container" :is-active="appStore.sidebar.opened" class="hamburger-container" @toggleClick="toggleSideBar" />
    <breadcrumb v-if="!settingsStore.topNav" id="breadcrumb-container" class="breadcrumb-container" />
    <top-nav v-if="settingsStore.topNav" id="topmenu-container" class="topmenu-container" />

    <div class="right-menu">
      <template v-if="appStore.device !== 'mobile'">
        <header-search id="header-search" class="right-menu-item" />

        <screenfull id="screenfull" class="right-menu-item hover-effect" />
      </template>

      <el-tooltip content="亮色/暗色" placement="bottom">
        <div
          class="right-menu-item hover-effect theme-switch-wrapper"
          v-if="userStore.loginType !== 'guest'"
          @click="toggleTheme"
        >
          <el-icon>
            <Moon v-if="settingsStore.isDark" />
            <Sunny v-else />
          </el-icon>
        </div>
      </el-tooltip>

      <el-dropdown @command="handleCommand" class="avatar-container right-menu-item hover-effect" trigger="hover" v-if="userStore.loginType !== 'guest'">
        <div class="avatar-wrapper">
          <img :src="userStore.avatar" class="user-avatar" />
          <span class="user-nickname"> {{ userStore.nickName }} </span>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <router-link to="/user/profile">
              <el-dropdown-item>个人中心</el-dropdown-item>
            </router-link>
            <el-dropdown-item command="setLayout" v-if="settingsStore.showSettings">
                <span>布局设置</span>
              </el-dropdown-item>
            <el-dropdown-item divided command="logout">
              <span>退出登录</span>
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
      
      <!-- 访客显示 -->
      <div class="right-menu-item hover-effect" v-else @click="goToLogin">
        <span style="font-size: 14px; color: #606266;">未登录 (点击登录)</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ElMessageBox, ElNotification } from 'element-plus'
import Breadcrumb from '@/components/Breadcrumb'
import TopNav from '@/components/TopNav'
import Hamburger from '@/components/Hamburger'
import Screenfull from '@/components/Screenfull'
import HeaderSearch from '@/components/HeaderSearch'
import useAppStore from '@/store/modules/app'
import useUserStore from '@/store/modules/user'
import useSettingsStore from '@/store/modules/settings'
import { onMounted, onUnmounted, ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Moon, Sunny } from '@element-plus/icons-vue'
import { listAppointment } from "@/api/hospital/appointment.js"
import { listAudit } from "@/api/hospital/audit"

const appStore = useAppStore()
const userStore = useUserStore()
const settingsStore = useSettingsStore()
const router = useRouter()

let pollingTimer = null
const isDoctor = computed(() => userStore.loginType === 'doctor')
const isPatient = computed(() => userStore.loginType === 'patient')
const isAdmin = computed(() => userStore.loginType === 'admin' || userStore.roles.includes('admin'))

const appointmentInited = ref(false)
const auditInited = ref(false)
const appointmentSnapshot = ref(new Map())
const pendingAuditSnapshot = ref(new Set())

function goAppointmentList(query = {}) {
  router.push({
    path: '/hospital/appointment',
    query: {
      ...query,
      _t: Date.now()
    }
  })
}

function goAuditList() {
  router.push({
    path: '/hospital/audit',
    query: { _t: Date.now() }
  })
}

function notifyStatusChange(prev, curr) {
  if (!prev || !curr || prev.status === curr.status) return

  if (curr.status === '已取消') {
    const approvedByAdmin = prev.status === '取消审核中'
    const message = isPatient.value
      ? (approvedByAdmin
        ? `管理员已同意您的取消申请，预约（${curr.appointmentTime}）已取消。`
        : `您的预约（${curr.appointmentTime}）已被管理员取消，请重新选择其他号源。`)
      : (approvedByAdmin
        ? `管理员已同意取消申请，预约（${curr.patientName} ${curr.appointmentTime}）已取消。`
        : `管理员已取消预约（${curr.patientName} ${curr.appointmentTime}），请关注后续排班。`)
    const notification = ElNotification({
      title: '预约状态变更',
      message,
      type: 'warning',
      duration: 12000,
      onClick: () => {
        goAppointmentList({ newId: curr.id })
        notification.close()
      }
    })
    return
  }

  if (prev.status === '取消审核中' && curr.status === '待就诊') {
    const notification = ElNotification({
      title: '取消申请结果',
      message: `您的预约取消申请未通过，预约已恢复为待就诊。`,
      type: 'info',
      duration: 12000,
      onClick: () => {
        goAppointmentList({ newId: curr.id })
        notification.close()
      }
    })
  }
}

function checkAppointmentNotifications() {
  if (!isDoctor.value && !isPatient.value) return

  const query = {
    pageNum: 1,
    pageSize: 50,
    orderByColumn: "bookedAt",
    isAsc: "descending"
  }

  listAppointment(query).then(response => {
    const rows = response.rows || []
    const nextMap = new Map(rows.map(item => [item.id, item]))

    if (!appointmentInited.value) {
      appointmentSnapshot.value = nextMap
      appointmentInited.value = true
      return
    }

    if (isDoctor.value) {
      const newAppointments = rows.filter(item => {
        return item.status === '待就诊' && !appointmentSnapshot.value.has(item.id)
      })

      newAppointments.slice(0, 3).forEach(item => {
        const notification = ElNotification({
          title: '新预约提醒',
          message: `患者 ${item.patientName} 提交了新的预约（${item.appointmentTime}）`,
          type: 'info',
          duration: 15000,
          onClick: () => {
            goAppointmentList({ newId: item.id })
            notification.close()
          }
        })
      })
    }

    rows.forEach(item => {
      const prev = appointmentSnapshot.value.get(item.id)
      notifyStatusChange(prev, item)
      if (prev && prev.timeChangeNotice !== item.timeChangeNotice && item.timeChangeNotice) {
        const notification = ElNotification({
          title: '就诊时段调整',
          message: item.timeChangeNotice,
          type: 'warning',
          duration: 12000,
          onClick: () => {
            goAppointmentList({ newId: item.id })
            notification.close()
          }
        })
      }
    })

    appointmentSnapshot.value = nextMap
  }).catch(() => {})
}

function checkAuditNotifications() {
  if (!isAdmin.value) return

  listAudit({
    pageNum: 1,
    pageSize: 20,
    auditStatus: 0,
    orderByColumn: 'createdAt',
    isAsc: 'descending'
  }).then(response => {
    const rows = response.rows || []
    const nextIds = new Set(rows.map(item => item.id))

    if (!auditInited.value) {
      pendingAuditSnapshot.value = nextIds
      auditInited.value = true
      return
    }

    const newAudits = rows.filter(item => !pendingAuditSnapshot.value.has(item.id))
    newAudits.slice(0, 3).forEach(item => {
      const roleText = item.requesterRole === 'doctor' ? '医生' : '患者'
      const notification = ElNotification({
        title: '新的审核申请',
        message: `${roleText}${item.requesterName}提交了预约取消审核申请。`,
        type: 'info',
        duration: 15000,
        onClick: () => {
          goAuditList()
          notification.close()
        }
      })
    })

    pendingAuditSnapshot.value = nextIds
  }).catch(() => {})
}

/** 检查跨端提醒 (轮询) */
function checkCrossRoleNotifications() {
  if (userStore.loginType === 'guest') return
  checkAppointmentNotifications()
  checkAuditNotifications()
}

onMounted(() => {
  if (userStore.loginType === 'guest') return
  checkCrossRoleNotifications()
  pollingTimer = setInterval(checkCrossRoleNotifications, 10000)
})

onUnmounted(() => {
  if (pollingTimer) {
    clearInterval(pollingTimer)
  }
})

function goToLogin() {
  ElMessageBox.confirm('当前为访客模式，是否前往登录？', '提示', {
    confirmButtonText: '去登录',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logOut().then(() => {
      const redirect = router.currentRoute.value.fullPath || '/index'
      router.push(`/login?redirect=${encodeURIComponent(redirect)}`)
    })
  }).catch(() => {})
}

function toggleSideBar() {
  appStore.toggleSideBar()
}

function toggleTheme() {
  settingsStore.toggleTheme()
}

function handleCommand(command) {
  switch (command) {
    case "setLayout":
      setLayout()
      break
    case "logout":
      logout()
      break
    default:
      break
  }
}

function logout() {
  ElMessageBox.confirm('确定注销并退出系统吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logOut().then(() => {
      location.href = '/login?logout=1'
    })
  }).catch(() => {})
}

const emits = defineEmits(['setLayout'])
function setLayout() {
  emits('setLayout')
}
</script>

<style lang='scss' scoped>
.navbar {
  height: 50px;
  overflow: hidden;
  position: relative;
  background: var(--navbar-bg);
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);

  .hamburger-container {
    line-height: 46px;
    height: 100%;
    float: left;
    cursor: pointer;
    transition: background 0.3s;
    -webkit-tap-highlight-color: transparent;

    &:hover {
      background: rgba(0, 0, 0, 0.025);
    }
  }

  .breadcrumb-container {
    float: left;
  }

  .topmenu-container {
    position: absolute;
    left: 50px;
  }

  .errLog-container {
    display: inline-block;
    vertical-align: top;
  }

  .right-menu {
    float: right;
    height: 100%;
    line-height: 50px;
    display: flex;

    &:focus {
      outline: none;
    }

    .right-menu-item {
      display: inline-block;
      padding: 0 8px;
      height: 100%;
      font-size: 18px;
      color: #5a5e66;
      vertical-align: text-bottom;

      &.hover-effect {
        cursor: pointer;
        transition: background 0.3s;

        &:hover {
          background: rgba(0, 0, 0, 0.025);
        }
      }

      &.theme-switch-wrapper {
        display: flex;
        align-items: center;

        svg {
          transition: transform 0.3s;
          
          &:hover {
            transform: scale(1.15);
          }
        }
      }
    }

    .avatar-container {
      margin-right: 0px;
      padding-right: 0px;

      .avatar-wrapper {
        margin-top: 10px;
        right: 8px;
        position: relative;

        .user-avatar {
          cursor: pointer;
          width: 30px;
          height: 30px;
          margin-right: 8px;
          border-radius: 50%;
        }

        .user-nickname{
          position: relative;
          left: 0px;
          bottom: 10px;
          font-size: 14px;
          font-weight: bold;
        }

        i {
          cursor: pointer;
          position: absolute;
          right: -20px;
          top: 25px;
          font-size: 12px;
        }
      }
    }
  }
}
</style>
