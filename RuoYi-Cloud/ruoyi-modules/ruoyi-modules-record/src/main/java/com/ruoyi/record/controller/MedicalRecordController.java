package com.ruoyi.record.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.record.domain.MedicalRecord;
import com.ruoyi.record.service.IMedicalRecordService;

/**
 * 电子病历Controller
 */
@RestController
@RequestMapping("/record")
public class MedicalRecordController extends BaseController
{
    @Autowired
    private IMedicalRecordService medicalRecordService;

    @GetMapping("/list")
    public ResultVO<List<MedicalRecord>> list(MedicalRecord medicalRecord)
    {
        List<MedicalRecord> list = medicalRecordService.selectMedicalRecordList(medicalRecord);
        return ResultVO.success(list);
    }

    /**
     * 获取病历详细信息
     */
    @GetMapping(value = "/{id}")
    public ResultVO<MedicalRecord> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(medicalRecordService.getMedicalRecordById(id));
    }

    /**
     * 新增病历
     */
    @PostMapping
    public ResultVO<Boolean> add(@RequestBody MedicalRecord medicalRecord)
    {
        return ResultVO.success(medicalRecordService.insertMedicalRecord(medicalRecord));
    }

    /**
     * 修改病历
     */
    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody MedicalRecord medicalRecord)
    {
        return ResultVO.success(medicalRecordService.updateMedicalRecord(medicalRecord));
    }

    /**
     * 删除病历
     */
    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(medicalRecordService.deleteMedicalRecordByIds(ids));
    }
}
