package com.ruoyi.patient;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class RuoYiPatientApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiPatientApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  患者模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
