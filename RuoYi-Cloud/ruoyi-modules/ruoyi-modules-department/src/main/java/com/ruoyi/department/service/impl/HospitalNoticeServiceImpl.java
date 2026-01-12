package com.ruoyi.department.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.department.domain.HospitalNotice;
import com.ruoyi.department.mapper.HospitalNoticeMapper;
import com.ruoyi.department.service.IHospitalNoticeService;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

/**
 * 医院通知Service业务层处理
 */
@Service
public class HospitalNoticeServiceImpl extends ServiceImpl<HospitalNoticeMapper, HospitalNotice> implements IHospitalNoticeService {
    @Override
    public List<HospitalNotice> selectActiveNoticeList(String targetAudience) {
        return this.list(new LambdaQueryWrapper<HospitalNotice>()
                .eq(HospitalNotice::getIsActive, 1)
                .and(targetAudience != null, w -> w.eq(HospitalNotice::getTargetAudience, "全部").or().eq(HospitalNotice::getTargetAudience, targetAudience))
                .orderByDesc(HospitalNotice::getIsTop)
                .orderByDesc(HospitalNotice::getPublishTime));
    }

    @Override
    public List<HospitalNotice> selectNoticeList(HospitalNotice notice) {
        return this.list(new LambdaQueryWrapper<HospitalNotice>()
                .like(notice.getTitle() != null, HospitalNotice::getTitle, notice.getTitle())
                .eq(notice.getNoticeType() != null, HospitalNotice::getNoticeType, notice.getNoticeType())
                .eq(notice.getIsActive() != null, HospitalNotice::getIsActive, notice.getIsActive())
                .orderByDesc(HospitalNotice::getIsTop)
                .orderByDesc(HospitalNotice::getPublishTime));
    }
}
