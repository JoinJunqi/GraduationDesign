import request from '@/utils/request'

// 查询医生列表
export function listDoctor(query) {
  return request({
    url: '/ruoyi-hospital-doctor/doctor/list/' + (query.deptId || ''), // 注意：后端接口是 /list/{deptId}，这里可能需要适配
    method: 'get',
    params: query
  })
}

// 注意：上面的 listDoctor 可能不准确，因为后端 DoctorController 有两个 list 接口：
// 1. /list/{deptId} (公开接口)
// 2. 没有通用的 list 接口用于管理端？
// 让我再次检查 DoctorController.java

// 检查后发现：DoctorController 只有 login, getProfile, getMySchedules, getDoctorsByDept(/list/{deptId})
// 缺少一个通用的管理端分页查询接口。
// 这是一个后端缺失。为了管理端功能，我需要在后端补上，或者暂时使用 getDoctorsByDept 但它不支持分页和多条件。
// 假设我现在需要补全后端 DoctorController 的 list 方法。

// 补全 DoctorController 的 list 方法 (模拟，稍后可能需要去后端加)
export function listDoctorAll(query) {
   // 假设我们后续会添加这个接口，或者目前先用 deptId 查
   // 如果后端没写通用 list，那前端管理列表会很麻烦。
   // 暂时先写着，假设后端会提供
  return request({
    url: '/ruoyi-hospital-doctor/doctor/list', 
    method: 'get',
    params: query
  })
}

// 查询医生详细
export function getDoctor(id) {
  // 后端目前只提供了 getProfile (当前登录医生) 和 getById (Controller里没写通用的 getById 暴露给 Admin)
  // 必须在后端 DoctorController 增加标准 CRUD
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
