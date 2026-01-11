import request from '@/utils/request'

// 查询有效通知列表
export function listNotice() {
  return request({
    url: '/ruoyi-hospital-department/notice/list',
    method: 'get'
  })
}

// 获取通知详细信息
export function getNotice(id) {
  return request({
    url: '/ruoyi-hospital-department/notice/' + id,
    method: 'get'
  })
}
