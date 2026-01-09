package com.ruoyi.record.controller;

import java.util.List;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.ruoyi.common.core.web.controller.BaseController;
import com.ruoyi.common.core.domain.ResultVO;
import com.ruoyi.common.core.web.page.TableDataInfo;
import com.ruoyi.record.domain.MedicalRecord;
import com.ruoyi.record.service.IMedicalRecordService;

@RestController
@RequestMapping("/record")
public class MedicalRecordController extends BaseController
{
    @Autowired
    private IMedicalRecordService medicalRecordService;

    @GetMapping("/list")
    public TableDataInfo list(MedicalRecord medicalRecord)
    {
        startPage();
        List<MedicalRecord> list = medicalRecordService.list();
        return getDataTable(list);
    }

    @GetMapping(value = "/{id}")
    public ResultVO<MedicalRecord> getInfo(@PathVariable("id") Long id)
    {
        return ResultVO.success(medicalRecordService.getById(id));
    }

    @PostMapping
    public ResultVO<Boolean> add(@RequestBody MedicalRecord medicalRecord)
    {
        return ResultVO.success(medicalRecordService.save(medicalRecord));
    }

    @PutMapping
    public ResultVO<Boolean> edit(@RequestBody MedicalRecord medicalRecord)
    {
        return ResultVO.success(medicalRecordService.updateById(medicalRecord));
    }

    @DeleteMapping("/{ids}")
    public ResultVO<Boolean> remove(@PathVariable Long[] ids)
    {
        return ResultVO.success(medicalRecordService.removeBatchByIds(Arrays.asList(ids)));
    }
}
