package com.ruoyi.hospital.admin.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ruoyi.hospital.admin.domain.Admin;
import com.ruoyi.hospital.admin.mapper.AdminMapper;
import com.ruoyi.hospital.admin.service.IAdminService;
import org.springframework.stereotype.Service;

/**
 * 管理员 Service 实现类
 */
@Service
public class AdminServiceImpl extends ServiceImpl<AdminMapper, Admin> implements IAdminService {
}
