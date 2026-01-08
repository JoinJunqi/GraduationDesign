import request from '@/utils/request'

// 查询排班列表
export function listSchedule(query) {
  return request({
    url: '/ruoyi-hospital-schedule/schedule/list',
    method: 'get',
    params: query
  })
}

// 查询排班详细
export function getSchedule(id) {
  return request({
    url: '/ruoyi-hospital-schedule/schedule/' + id,
    method: 'get'
  })
}

// 新增排班
export function addSchedule(data) {
  return request({
    url: '/ruoyi-hospital-schedule/schedule',
    method: 'post',
    data: data
  })
}

// 修改排班
export function updateSchedule(data) {
  return request({
    url: '/ruoyi-hospital-schedule/schedule',
    method: 'put',
    data: data
  })
}

// 删除排班
export function delSchedule(id) {
  return request({
    url: '/ruoyi-hospital-schedule/schedule/' + id,
    method: 'delete'
  })
}
