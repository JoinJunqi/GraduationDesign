import request from '@/utils/request'

// 查询病历列表
export function listRecord(query) {
  return request({
    url: '/ruoyi-hospital-record/record/list',
    method: 'get',
    params: query
  })
}

// 查询病历详细
export function getRecord(id, appointmentId) {
  return request({
    url: '/ruoyi-hospital-record/record/' + id,
    method: 'get',
    params: appointmentId ? { appointmentId } : undefined
  })
}

// 新增病历
export function addRecord(data) {
  return request({
    url: '/ruoyi-hospital-record/record',
    method: 'post',
    data: data
  })
}

// 修改病历
export function updateRecord(data) {
  return request({
    url: '/ruoyi-hospital-record/record',
    method: 'put',
    data: data
  })
}

// 删除病历
export function delRecord(ids) {
  return request({
    url: '/ruoyi-hospital-record/record/' + ids,
    method: 'delete'
  })
}
