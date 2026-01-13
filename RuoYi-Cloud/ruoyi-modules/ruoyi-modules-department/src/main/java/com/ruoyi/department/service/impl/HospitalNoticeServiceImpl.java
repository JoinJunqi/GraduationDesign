package com.ruoyi.department.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.department.domain.HospitalNotice;
import com.ruoyi.department.mapper.HospitalNoticeMapper;
import com.ruoyi.department.service.IHospitalNoticeService;
import org.springframework.stereotype.Service;
import java.util.Arrays;
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
    public boolean deleteNoticeByIds(Long[] ids) {
        HospitalNotice notice = new HospitalNotice();
        notice.setIsDeleted(1);
        notice.setDeletedAt(new Date());
        return update(notice, new LambdaQueryWrapper<HospitalNotice>().in(HospitalNotice::getId, Arrays.asList(ids)));
    }

    @Override
    public List<HospitalNotice> selectNoticeList(HospitalNotice notice) {
        return baseMapper.selectNoticeList(notice);
    }
}
