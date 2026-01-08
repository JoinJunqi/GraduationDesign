package com.ruoyi.hospital.doctor;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;
import org.mybatis.spring.annotation.MapperScan;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
@MapperScan("com.ruoyi.hospital.doctor.mapper")
public class RuoYiHospitalDoctorApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiHospitalDoctorApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  医生模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
