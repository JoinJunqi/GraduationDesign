import request from '@/utils/request'

// 查询审核列表
export function listAudit(query) {
  return request({
    url: '/ruoyi-hospital-appointment/audit/list',
    method: 'get',
    params: query
  })
}

// 获取审核详细信息
export function getAudit(id) {
  return request({
    url: '/ruoyi-hospital-appointment/audit/' + id,
    method: 'get'
  })
}

// 提交审核申请
export function submitAudit(data) {
  return request({
    url: '/ruoyi-hospital-appointment/audit/submit',
    method: 'post',
    data: data
  })
}

// 处理审核
export function processAudit(data) {
  return request({
    url: '/ruoyi-hospital-appointment/audit/process',
    method: 'put',
    data: data
  })
}
