package com.ruoyi.hospital.schedule;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;
import org.mybatis.spring.annotation.MapperScan;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
@MapperScan("com.ruoyi.hospital.schedule.mapper")
public class RuoYiHospitalScheduleApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiHospitalScheduleApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  排班模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
