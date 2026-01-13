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
        DepartmentIntro intro = new DepartmentIntro();
        intro.setIsDeleted(1);
        intro.setDeletedAt(new Date());
        return update(intro, new LambdaQueryWrapper<DepartmentIntro>().in(DepartmentIntro::getDeptId, Arrays.asList(deptIds)));
    }
}
