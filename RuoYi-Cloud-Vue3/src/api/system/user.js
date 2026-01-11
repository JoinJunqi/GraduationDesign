import request from '@/utils/request'
import { parseStrEmpty } from "@/utils/ruoyi";

// 查询用户列表
export function listUser(query) {
  return request({
    url: '/system/user/list',
    method: 'get',
    params: query
  })
}

// 查询用户详细
export function getUser(userId) {
  return request({
    url: '/system/user/' + parseStrEmpty(userId),
    method: 'get'
  })
}

// 新增用户
export function addUser(data) {
  return request({
    url: '/system/user',
    method: 'post',
    data: data
  })
}

// 修改用户
export function updateUser(data) {
  return request({
    url: '/system/user',
    method: 'put',
    data: data
  })
}

// 删除用户
export function delUser(userId) {
  return request({
    url: '/system/user/' + userId,
    method: 'delete'
  })
}

// 用户密码重置
export function resetUserPwd(userId, password) {
  const data = {
    userId,
    password
  }
  return request({
    url: '/system/user/resetPwd',
    method: 'put',
    data: data
  })
}

// 用户状态修改
export function changeUserStatus(userId, status) {
  const data = {
    userId,
    status
  }
  return request({
    url: '/system/user/changeStatus',
    method: 'put',
    data: data
  })
}

// 查询用户个人信息
export function getUserProfile() {
  const loginType = localStorage.getItem('loginType') || 'admin'
  let url = '/system/admin/profile'
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

// 修改用户个人信息
export function updateUserProfile(data) {
  const loginType = localStorage.getItem('loginType') || 'admin'
  let url = '/system/admin/profile'
  if (loginType === 'patient') {
    url = '/ruoyi-hospital-patient/patient/profile'
  } else if (loginType === 'doctor') {
    url = '/ruoyi-hospital-doctor/doctor/profile'
  }
  return request({
    url: url,
    method: 'put',
    data: data
  })
}

// 用户密码重置
export function updateUserPwd(oldPassword, newPassword) {
  const loginType = localStorage.getItem('loginType') || 'admin'
  let url = '/system/admin/profile/updatePwd'
  if (loginType === 'patient') {
    url = '/ruoyi-hospital-patient/patient/profile/updatePwd'
  } else if (loginType === 'doctor') {
    url = '/ruoyi-hospital-doctor/doctor/profile/updatePwd'
  }
  const data = {
    oldPassword,
    newPassword
  }
  return request({
    url: url,
    method: 'put',
    params: data
  })
}

// 用户头像上传
export function uploadAvatar(data) {
  const loginType = localStorage.getItem('loginType') || 'admin'
  let url = '/system/admin/profile/avatar'
  if (loginType === 'patient') {
    url = '/patient/profile/avatar'
  }
  return request({
    url: url,
    method: 'post',
    data: data
  })
}

// 查询授权角色
export function getAuthRole(userId) {
  return request({
    url: '/system/user/authRole/' + userId,
    method: 'get'
  })
}

// 保存授权角色
export function updateAuthRole(data) {
  return request({
    url: '/system/user/authRole',
    method: 'put',
    params: data
  })
}
