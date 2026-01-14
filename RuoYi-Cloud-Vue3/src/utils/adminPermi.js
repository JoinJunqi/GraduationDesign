import useUserStore from "@/store/modules/user";

/**
 * 校验管理员权限
 * @param {number} permission 权限位
 * @returns {boolean} 是否有权限
 */
export function hasAdminPermi(permission) {
  const userStore = useUserStore();
  
  // 如果不是管理员登录类型，返回false
  if (userStore.loginType !== 'admin') {
    return false;
  }

  // 超级管理员拥有所有权限
  if (userStore.adminLevel === 1) {
    return true;
  }

  // 普通管理员根据权限位判断
  return (userStore.adminPermissions & permission) === permission;
}

/**
 * 权限常量定义 (与后端 UserConstants 一致)
 */
export const AdminPermi = {
  DEPT: 1,      // 科室信息管理
  DOCTOR: 2,    // 医生管理
  PATIENT: 4,   // 患者管理
  SCHEDULE: 8,  // 排班管理
  BOOKING: 16,  // 预约管理
  RECORD: 32,   // 病历管理
  HOSPITAL: 64, // 医院信息管理
  AUDIT: 128    // 操作审核
};
