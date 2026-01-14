package com.ruoyi.record.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.constant.UserConstants;
import com.ruoyi.common.security.utils.SecurityUtils;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.record.domain.MedicalRecord;
import com.ruoyi.record.service.IMedicalRecordService;

import com.ruoyi.common.core.web.page.TableDataInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 电子病历Controller
 */
@RestController
@RequestMapping
public class MedicalRecordController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(MedicalRecordController.class);

    @Autowired
    private IMedicalRecordService medicalRecordService;

    /**
     * 查询病历列表
     */
    @GetMapping({"/record/list", "/list"})
    public TableDataInfo list(MedicalRecord medicalRecord)
    {
        log.info("MedicalRecord list request received. Path: /record/list or /list, Params: {}", medicalRecord);
        startPage();
        startOrderBy();
        List<MedicalRecord> list = medicalRecordService.selectMedicalRecordList(medicalRecord);
        return getDataTable(list);
    }

    /**
     * 获取病历详细信息
     */
    @GetMapping(value = "/record/{id}")
    public ResultVO<MedicalRecord> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(medicalRecordService.getMedicalRecordById(id));
    }

    /**
     * 新增病历
     */
    @PostMapping("/record")
    public ResultVO<Boolean> add(@RequestBody MedicalRecord medicalRecord)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_RECORD);
        return ResultVO.success(medicalRecordService.insertMedicalRecord(medicalRecord));
    }

    /**
     * 修改病历
     */
    @PutMapping("/record")
    public ResultVO<Boolean> edit(@RequestBody MedicalRecord medicalRecord)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_RECORD);
        return ResultVO.success(medicalRecordService.updateMedicalRecord(medicalRecord));
    }

    /**
     * 删除病历
     */
    @DeleteMapping("/record/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        SecurityUtils.checkAdminPermission(UserConstants.PERM_RECORD);
        return ResultVO.success(medicalRecordService.deleteMedicalRecordByIds(ids));
    }
}
