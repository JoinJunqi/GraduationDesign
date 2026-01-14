package com.ruoyi.department.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.constant.UserConstants;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.department.domain.DepartmentIntro;
import com.ruoyi.department.service.IDepartmentIntroService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;

/**
 * 科室说明Controller
 */
@RestController
@RequestMapping("/department/intro")
public class DepartmentIntroController extends BaseController {
    @Autowired
    private IDepartmentIntroService departmentIntroService;

    /**
     * 根据科室ID获取科室说明
     */
    @GetMapping("/{deptId}")
    public ResultVO<DepartmentIntro> getInfo(@PathVariable("deptId") Long deptId) {
        DepartmentIntro intro = departmentIntroService.getOne(new LambdaQueryWrapper<DepartmentIntro>()
                .eq(DepartmentIntro::getDeptId, deptId));
        return ResultVO.success(intro);
    }

    /**
     * 新增或修改科室说明
     */
    @PostMapping
    public ResultVO<Boolean> save(@RequestBody DepartmentIntro departmentIntro) {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_DEPT);
        if (departmentIntro.getId() != null) {
            return ResultVO.success(departmentIntroService.updateById(departmentIntro));
        } else {
            return ResultVO.success(departmentIntroService.save(departmentIntro));
        }
    }
}
