import request from '@/utils/request'

// 查询有效通知列表
export function listNotice(query) {
  return request({
    url: '/ruoyi-hospital-department/notice/list',
    method: 'get',
    params: query
  })
}

// 查询供首页展示的有效通知列表
export function listActiveNotice(query) {
  return request({
    url: '/ruoyi-hospital-department/notice/activeList',
    method: 'get',
    params: query
  })
}

// 获取通知详细信息
export function getNotice(id) {
  return request({
    url: '/ruoyi-hospital-department/notice/' + id,
    method: 'get'
  })
}

// 新增通知
export function addNotice(data) {
  return request({
    url: '/ruoyi-hospital-department/notice',
    method: 'post',
    data: data
  })
}

// 修改通知
export function updateNotice(data) {
  return request({
    url: '/ruoyi-hospital-department/notice',
    method: 'put',
    data: data
  })
}

// 删除通知
export function delNotice(id) {
  return request({
    url: '/ruoyi-hospital-department/notice/' + id,
    method: 'delete'
  })
}
