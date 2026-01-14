package com.ruoyi.department.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.constant.UserConstants;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.department.domain.HospitalNotice;
import com.ruoyi.department.service.IHospitalNoticeService;

/**
 * 医院通知Controller
 */
@RestController
@RequestMapping("/notice")
public class HospitalNoticeController extends BaseController {
    @Autowired
    private IHospitalNoticeService hospitalNoticeService;

    /**
     * 查询通知列表
     */
    @GetMapping("/list")
    public TableDataInfo list(HospitalNotice notice) {
        startPage();
        startOrderBy();
        List<HospitalNotice> list = hospitalNoticeService.selectNoticeList(notice);
        return getDataTable(list);
    }

    /**
     * 获取供首页展示的有效通知列表
     */
    @GetMapping("/activeList")
    public ResultVO<List<HospitalNotice>> activeList(@RequestParam(value = "targetAudience", required = false) String targetAudience) {
        return ResultVO.success(hospitalNoticeService.selectActiveNoticeList(targetAudience));
    }

    /**
     * 获取通知详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<HospitalNotice> getInfo(@PathVariable("id") Long id) {
        HospitalNotice notice = hospitalNoticeService.getById(id);
        if (notice != null) {
            // 只有查询单个通知时才增加查看次数
            notice.setViewCount(notice.getViewCount() + 1);
            hospitalNoticeService.updateById(notice);
        }
        return ResultVO.success(notice);
    }

    /**
     * 新增通知
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody HospitalNotice notice) {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_HOSPITAL);
        return ResultVO.success(hospitalNoticeService.save(notice));
    }

    /**
     * 修改通知
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody HospitalNotice notice) {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_HOSPITAL);
        return ResultVO.success(hospitalNoticeService.updateById(notice));
    }

    /**
     * 删除通知
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids) {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_HOSPITAL);
        return ResultVO.success(hospitalNoticeService.deleteNoticeByIds(ids));
    }
}
