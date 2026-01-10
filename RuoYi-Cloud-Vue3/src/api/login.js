import request from '@/utils/request'

// 登录方法
export function login(data) {
  return request({
    url: '/auth/login',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

// 患者登录
export function loginPatient(data) {
  return request({
    url: '/ruoyi-hospital-patient/patient/login',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

// 医生登录
export function loginDoctor(data) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor/login',
    headers: {
      isToken: false,
      repeatSubmit: false
    },
    method: 'post',
    data: data
  })
}

// 注册方法
export function register(data) {
  return request({
    url: '/auth/register',
    headers: {
      isToken: false
    },
    method: 'post',
    data: data
  })
}

// 患者注册
export function registerPatient(data) {
  return request({
    url: '/ruoyi-hospital-patient/patient/register',
    headers: {
      isToken: false
    },
    method: 'post',
    data: data
  })
}

// 刷新方法
export function refreshToken() {
  return request({
    url: '/auth/refresh',
    method: 'post'
  })
}

// 获取用户详细信息
export function getInfo() {
  const loginType = localStorage.getItem('loginType') || 'admin'
  let url = '/system/user/getInfo'
  if (loginType === 'patient') {
    url = '/ruoyi-hospital-patient/patient/profile'
  } else if (loginType === 'doctor') {
    url = '/ruoyi-hospital-doctor/doctor/profile'
  }
  return request({
    url: url,
    method: 'get'
  })
}

// 退出方法
export function logout() {
  return request({
    url: '/auth/logout',
    method: 'delete'
  })
}

// 获取验证码
export function getCodeImg() {
  return request({
    url: '/code',
    headers: {
      isToken: false
    },
    method: 'get',
    timeout: 20000
  })
}
