package com.ruoyi.hospital.record;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;
import org.mybatis.spring.annotation.MapperScan;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
@MapperScan("com.ruoyi.hospital.record.mapper")
public class RuoYiHospitalRecordApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiHospitalRecordApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  病历模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
