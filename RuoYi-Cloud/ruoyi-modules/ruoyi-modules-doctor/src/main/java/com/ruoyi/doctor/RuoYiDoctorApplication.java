package com.ruoyi.doctor;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class RuoYiDoctorApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiDoctorApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  医生模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
