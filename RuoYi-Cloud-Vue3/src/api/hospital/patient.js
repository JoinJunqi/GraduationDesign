import request from '@/utils/request'

// 查询患者列表
export function listPatient(query) {
  return request({
    url: '/ruoyi-hospital-patient/patient/list',
    method: 'get',
    params: query
  })
}

// 查询患者详细
export function getPatient(id) {
  return request({
    url: '/ruoyi-hospital-patient/patient/' + id,
    method: 'get'
  })
}

// 新增患者
export function addPatient(data) {
  return request({
    url: '/ruoyi-hospital-patient/patient',
    method: 'post',
    data: data
  })
}

// 修改患者
export function updatePatient(data) {
  return request({
    url: '/ruoyi-hospital-patient/patient',
    method: 'put',
    data: data
  })
}

// 删除患者
export function delPatient(id) {
  return request({
    url: '/ruoyi-hospital-patient/patient/' + id,
    method: 'delete'
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

// 获取患者个人信息
export function getPatientProfile() {
  return request({
    url: '/ruoyi-hospital-patient/patient/profile',
    method: 'get'
  })
}

// 修改患者个人信息
export function updatePatientProfile(data) {
  return request({
    url: '/ruoyi-hospital-patient/patient/profile',
    method: 'put',
    data: data
  })
}

// 修改患者密码
export function updatePatientPwd(oldPassword, newPassword) {
  const data = {
    oldPassword,
    newPassword
  }
  return request({
    url: '/ruoyi-hospital-patient/patient/profile/updatePwd',
    method: 'put',
    params: data
  })
}
