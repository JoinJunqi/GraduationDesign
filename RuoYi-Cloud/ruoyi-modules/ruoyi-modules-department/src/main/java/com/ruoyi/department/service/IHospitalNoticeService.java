package com.ruoyi.department.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ruoyi.department.domain.HospitalNotice;
import java.util.List;

/**
 * 医院通知Service接口
 */
public interface IHospitalNoticeService extends IService<HospitalNotice> {
    /**
     * 查询有效通知列表
     * @param targetAudience 目标受众
     */
    List<HospitalNotice> selectActiveNoticeList(String targetAudience);

    /**
     * 查询通知列表
     */
    List<HospitalNotice> selectNoticeList(HospitalNotice notice);
}
