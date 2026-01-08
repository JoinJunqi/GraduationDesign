package com.ruoyi.hospital.department;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;
import org.mybatis.spring.annotation.MapperScan;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
@MapperScan("com.ruoyi.hospital.department.mapper")
public class RuoYiHospitalDepartmentApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiHospitalDepartmentApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  科室模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
