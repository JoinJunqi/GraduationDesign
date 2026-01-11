package com.ruoyi.department.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
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
     * 查询有效通知列表
     */
    @GetMapping("/list")
    public TableDataInfo list() {
        startPage();
        startOrderBy();
        List<HospitalNotice> list = hospitalNoticeService.selectActiveNoticeList();
        return getDataTable(list);
    }

    /**
     * 获取通知详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<HospitalNotice> getInfo(@PathVariable("id") Long id) {
        HospitalNotice notice = hospitalNoticeService.getById(id);
        if (notice != null) {
            notice.setViewCount(notice.getViewCount() + 1);
            hospitalNoticeService.updateById(notice);
        }
        return ResultVO.success(notice);
    }
}
