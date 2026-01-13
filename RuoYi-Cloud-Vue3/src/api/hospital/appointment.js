import request from '@/utils/request'

// 查询预约列表
export function listAppointment(query) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/list',
    method: 'get',
    params: query
  })
}

// 查询预约详细
export function getAppointment(id) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/' + id,
    method: 'get'
  })
}

// 新增预约 (挂号)
export function addAppointment(data) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/create',
    method: 'post',
    data: data
  })
}

// 修改预约
export function updateAppointment(data) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment',
    method: 'put',
    data: data
  })
}

// 取消预约
export function cancelAppointment(id) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/cancel/' + id,
    method: 'post'
  })
}

// 发起取消申请
export function requestCancel(id) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/request-cancel/' + id,
    method: 'post'
  })
}

// 撤销取消申请
export function cancelRequest(id) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/cancel-request/' + id,
    method: 'post'
  })
}

// 删除预约
export function delAppointment(id) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/' + id,
    method: 'delete'
  })
}

// 恢复预约
export function recoverAppointment(id) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/recover/' + id,
    method: 'put'
  })
}

// 更新预约状态
export function updateAppointmentStatus(id, status) {
  return request({
    url: '/ruoyi-hospital-appointment/appointment/status',
    method: 'put',
    params: { id, status }
  })
}
