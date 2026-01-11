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
    public List<HospitalNotice> selectActiveNoticeList() {
        Date now = new Date();
        return this.list(new LambdaQueryWrapper<HospitalNotice>()
                .eq(HospitalNotice::getIsActive, 1)
                .le(HospitalNotice::getPublishTime, now)
                .and(w -> w.isNull(HospitalNotice::getExpireTime).or().ge(HospitalNotice::getExpireTime, now))
                .orderByDesc(HospitalNotice::getIsTop)
                .orderByDesc(HospitalNotice::getPublishTime));
    }
}
