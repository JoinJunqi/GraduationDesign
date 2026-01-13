package com.ruoyi.department.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ruoyi.department.domain.HospitalNotice;
import org.apache.ibatis.annotations.Mapper;

/**
 * 医院通知Mapper接口
 */
@Mapper
public interface HospitalNoticeMapper extends BaseMapper<HospitalNotice> {
    /**
     * 查询通知列表
     * 
     * @param notice 通知信息
     * @return 通知列表
     */
    public java.util.List<HospitalNotice> selectNoticeList(HospitalNotice notice);
}
