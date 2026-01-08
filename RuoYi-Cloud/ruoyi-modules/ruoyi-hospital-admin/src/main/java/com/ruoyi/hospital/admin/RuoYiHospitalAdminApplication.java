package com.ruoyi.hospital.admin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;
import org.mybatis.spring.annotation.MapperScan;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
@MapperScan("com.ruoyi.hospital.admin.mapper")
public class RuoYiHospitalAdminApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiHospitalAdminApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  管理员模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
