package com.ruoyi.appointment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class RuoYiAppointmentApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiAppointmentApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  预约模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
