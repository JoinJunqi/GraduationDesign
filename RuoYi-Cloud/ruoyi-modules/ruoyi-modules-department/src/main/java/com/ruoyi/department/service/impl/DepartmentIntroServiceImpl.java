package com.ruoyi.department.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.department.domain.DepartmentIntro;
import com.ruoyi.department.mapper.DepartmentIntroMapper;
import com.ruoyi.department.service.IDepartmentIntroService;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Date;

/**
 * 科室说明Service业务层处理
 */
@Service
public class DepartmentIntroServiceImpl extends ServiceImpl<DepartmentIntroMapper, DepartmentIntro> implements IDepartmentIntroService {
    @Override
    public boolean deleteByDeptIds(Long[] deptIds) {
        return update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<DepartmentIntro>()
                .set("is_deleted", 1)
                .set("deleted_at", new Date())
                .in("dept_id", Arrays.asList(deptIds)));
    }

    @Override
    public boolean recoverByDeptIds(Long[] deptIds) {
        return update(new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<DepartmentIntro>()
                .set("is_deleted", 0)
                .set("deleted_at", null)
                .in("dept_id", Arrays.asList(deptIds)));
    }
}
