import request from '@/utils/request'

// 查询病历列表
export function listRecord(query) {
  return request({
    url: '/record/record/list',
    method: 'get',
    params: query
  })
}

// 查询病历详细
export function getRecord(id) {
  return request({
    url: '/record/record/' + id,
    method: 'get'
  })
}

// 新增病历
export function addRecord(data) {
  return request({
    url: '/record/record',
    method: 'post',
    data: data
  })
}

// 修改病历
export function updateRecord(data) {
  return request({
    url: '/record/record',
    method: 'put',
    data: data
  })
}

// 删除病历
export function delRecord(ids) {
  return request({
    url: '/record/record/' + ids,
    method: 'delete'
  })
}
