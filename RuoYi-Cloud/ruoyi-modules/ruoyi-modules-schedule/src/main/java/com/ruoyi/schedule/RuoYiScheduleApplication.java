package com.ruoyi.schedule;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class RuoYiScheduleApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiScheduleApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  排班模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
