<template>
  <div class="app-container home">
    <!-- 顶部欢迎和日期 -->
    <el-row :gutter="20" class="welcome-section">
      <el-col :span="24">
        <el-card shadow="hover" class="welcome-card">
          <div class="welcome-content">
            <div class="user-info">
              <h2>您好，{{ userStore.nickName }}！欢迎来到医院预约挂号系统</h2>
              <p class="current-date">今天是：{{ currentDate }}</p>
            </div>
            <div class="weather-placeholder">
              <el-icon><Sunny /></el-icon> 祝您身体健康，心情愉快！
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 功能快捷入口 -->
    <el-row :gutter="20" class="function-section">
      <el-col :span="6" v-for="item in functionList" :key="item.title">
        <el-card shadow="hover" class="function-card" @click="handleJump(item.path)">
          <div class="function-item">
            <el-icon :size="40" :color="item.color">
              <component :is="item.icon" />
            </el-icon>
            <span class="function-title">{{ item.title }}</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="main-content-section">
      <!-- 左侧：医院通知 -->
      <el-col :span="16">
        <el-card shadow="hover" class="notice-card">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><Notification /></el-icon> 医院通知</span>
            </div>
          </template>
          <el-scrollbar height="400px">
            <div v-for="notice in noticeList" :key="notice.id" class="notice-item" @click="viewNotice(notice)">
              <div class="notice-main">
                <el-tag :type="getNoticeTag(notice.priority)" size="small" class="notice-tag">
                  {{ notice.noticeType }}
                </el-tag>
                <span class="notice-title" :class="{ 'is-top': notice.isTop }">{{ notice.title }}</span>
              </div>
              <span class="notice-time">{{ parseTime(notice.publishTime, '{y}-{m}-{d}') }}</span>
            </div>
            <el-empty v-if="noticeList.length === 0" description="暂无通知" />
          </el-scrollbar>
        </el-card>

        <!-- 下方：科室介绍 -->
        <el-card shadow="hover" class="dept-card" style="margin-top: 20px;">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><OfficeBuilding /></el-icon> 科室概览</span>
            </div>
          </template>
          <el-row :gutter="20">
            <el-col :span="8" v-for="dept in deptList" :key="dept.id" class="dept-col">
              <el-card shadow="hover" class="dept-inner-card">
                <div class="dept-info">
                  <div class="dept-icon">
                    <el-icon :size="30" color="#409EFF"><Guide /></el-icon>
                  </div>
                  <div class="dept-text">
                    <h4 class="dept-name">{{ dept.name }}</h4>
                    <p class="dept-overview">{{ dept.overview || '暂无概述' }}</p>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>
          <el-empty v-if="deptList.length === 0" description="暂无科室信息" />
        </el-card>
      </el-col>

      <!-- 右侧：侧边辅助信息 (可以放一些健康贴士或医院地图等) -->
      <el-col :span="8">
        <el-card shadow="hover" class="side-card">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><Help /></el-icon> 就诊指南</span>
            </div>
          </template>
          <div class="guide-steps">
            <el-steps direction="vertical" :active="1">
              <el-step title="在线预约" description="选择科室与医生，预约就诊时间" />
              <el-step title="到院取号" description="就诊当日凭预约码到院取号" />
              <el-step title="科室就诊" description="在指定诊室等待叫号就诊" />
              <el-step title="缴费取药" description="就诊后在线或窗口缴费并取药" />
            </el-steps>
          </div>
        </el-card>

        <el-card shadow="hover" class="side-card" style="margin-top: 20px;">
          <template #header>
            <div class="card-header">
              <span class="header-title"><el-icon><Phone /></el-icon> 联系我们</span>
            </div>
          </template>
          <div class="contact-info">
            <p><strong>咨询电话：</strong>010-12345678</p>
            <p><strong>急救电话：</strong>010-87654321</p>
            <p><strong>医院地址：</strong>XX市XX区XX路123号</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 通知详情对话框 -->
    <el-dialog v-model="noticeVisible" :title="currentNotice.title" width="600px">
      <div class="notice-detail">
        <div class="notice-meta">
          <span>类型：{{ currentNotice.noticeType }}</span>
          <span>时间：{{ parseTime(currentNotice.publishTime) }}</span>
        </div>
        <div class="notice-content" v-html="currentNotice.content"></div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup name="Index">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import useUserStore from '@/store/modules/user'
import { parseTime } from '@/utils/ruoyi'
import { listDepartmentWithIntro } from '@/api/hospital/department'
import { listNotice, getNotice } from '@/api/hospital/notice'

const userStore = useUserStore()
const router = useRouter()

const currentDate = ref(parseTime(new Date(), '{y}年{m}月{d}日 星期{a}'))
const deptList = ref([])
const noticeList = ref([])
const noticeVisible = ref(false)
const currentNotice = ref({})

const loginType = userStore.loginType

const functionList = computed(() => {
  const allFunctions = [
    { title: '预约挂号', icon: 'Calendar', path: '/hospital/register', color: '#409EFF', roles: ['patient'] },
    { title: '我的预约', icon: 'List', path: '/hospital/appointment', color: '#67C23A', roles: ['patient', 'doctor'] },
    { title: '我的病历', icon: 'Form', path: '/hospital/record', color: '#E6A23C', roles: ['patient', 'doctor'] },
    { title: '个人中心', icon: 'User', path: '/user/profile', color: '#F56C6C', roles: ['admin', 'doctor', 'patient'] },
    { title: '科室管理', icon: 'OfficeBuilding', path: '/hospital/department', color: '#409EFF', roles: ['admin'] },
    { title: '医生管理', icon: 'UserFilled', path: '/hospital/doctor', color: '#67C23A', roles: ['admin'] },
    { title: '通知管理', icon: 'Message', path: '/hospital/notice', color: '#E6A23C', roles: ['admin'] }
  ]
  return allFunctions.filter(item => item.roles.includes(loginType))
})

onMounted(() => {
  getDeptList()
  getNoticeList()
})

function getDeptList() {
  listDepartmentWithIntro().then(res => {
    deptList.value = res.data
  })
}

function getNoticeList() {
  listNotice().then(res => {
    noticeList.value = res.data
  })
}

function handleJump(path) {
  router.push(path)
}

function viewNotice(notice) {
  getNotice(notice.id).then(res => {
    currentNotice.value = res.data
    noticeVisible.value = true
  })
}

function getNoticeTag(priority) {
  switch (priority) {
    case '紧急': return 'danger'
    case '重要': return 'warning'
    default: return 'info'
  }
}
</script>

<style scoped lang="scss">
.home {
  padding: 20px;
  background-color: #f5f7fa;

  .welcome-section {
    margin-bottom: 20px;
    .welcome-card {
      background: linear-gradient(135deg, #ffffff 0%, #e6f7ff 100%);
      .welcome-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        .user-info {
          h2 {
            margin: 0;
            color: #303133;
          }
          .current-date {
            margin: 10px 0 0;
            color: #606266;
            font-size: 16px;
          }
        }
        .weather-placeholder {
          color: #409EFF;
          font-size: 18px;
          display: flex;
          align-items: center;
          gap: 10px;
        }
      }
    }
  }

  .function-section {
    margin-bottom: 20px;
    .function-card {
      cursor: pointer;
      transition: all 0.3s;
      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      }
      .function-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 10px 0;
        .function-title {
          margin-top: 15px;
          font-size: 18px;
          font-weight: bold;
          color: #303133;
        }
      }
    }
  }

  .header-title {
    font-size: 18px;
    font-weight: bold;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .notice-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 10px;
    border-bottom: 1px solid #ebeef5;
    cursor: pointer;
    &:hover {
      background-color: #f9f9f9;
    }
    .notice-main {
      display: flex;
      align-items: center;
      gap: 10px;
      flex: 1;
      overflow: hidden;
      .notice-title {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        color: #303133;
        &.is-top {
          color: #f56c6c;
          font-weight: bold;
          &::before {
            content: "[置顶]";
            margin-right: 4px;
          }
        }
      }
    }
    .notice-time {
      color: #909399;
      font-size: 13px;
      margin-left: 10px;
    }
  }

  .dept-col {
    margin-bottom: 20px;
  }

  .dept-inner-card {
    height: 100%;
    .dept-info {
      display: flex;
      gap: 15px;
      .dept-text {
        flex: 1;
        overflow: hidden;
        .dept-name {
          margin: 0 0 8px;
          color: #303133;
        }
        .dept-overview {
          margin: 0;
          font-size: 13px;
          color: #606266;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
          overflow: hidden;
        }
      }
    }
  }

  .guide-steps {
    padding: 10px;
  }

  .contact-info {
    p {
      margin: 10px 0;
      color: #606266;
    }
  }

  .notice-detail {
    .notice-meta {
      display: flex;
      justify-content: space-between;
      color: #909399;
      margin-bottom: 20px;
      padding-bottom: 10px;
      border-bottom: 1px solid #ebeef5;
    }
    .notice-content {
      line-height: 1.8;
      color: #303133;
      white-space: pre-wrap;
    }
  }
}
</style>
