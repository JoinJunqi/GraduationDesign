import request from '@/utils/request'

// 查询医生列表
export function listDoctor(query) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor/list',
    method: 'get',
    params: query
  })
}

// 查询医生详细
export function getDoctor(id) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor/' + id,
    method: 'get'
  })
}

// 新增医生
export function addDoctor(data) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor',
    method: 'post',
    data: data
  })
}

// 修改医生
export function updateDoctor(data) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor',
    method: 'put',
    data: data
  })
}

// 删除医生
export function delDoctor(id) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor/' + id,
    method: 'delete'
  })
}

// 根据科室查询医生列表
export function listDoctorByDept(deptId) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor/list/' + deptId,
    method: 'get'
  })
}

// 修改医生个人信息
export function updateDoctorProfile(data) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor/profile',
    method: 'put',
    data: data
  })
}

// 修改医生密码
export function updateDoctorPwd(oldPassword, newPassword) {
  const data = {
    oldPassword,
    newPassword
  }
  return request({
    url: '/ruoyi-hospital-doctor/doctor/profile/updatePwd',
    method: 'put',
    params: data
  })
}
