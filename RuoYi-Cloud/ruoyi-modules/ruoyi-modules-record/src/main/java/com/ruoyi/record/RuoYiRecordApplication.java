package com.ruoyi.record;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class RuoYiRecordApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiRecordApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  病历模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
