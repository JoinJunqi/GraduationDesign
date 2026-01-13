package com.ruoyi.department.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.department.domain.DepartmentIntro;

/**
 * 科室说明Service接口
 */
public interface IDepartmentIntroService extends IService<DepartmentIntro> {
    /**
     * 根据科室ID批量逻辑删除
     */
    boolean deleteByDeptIds(Long[] deptIds);
}
