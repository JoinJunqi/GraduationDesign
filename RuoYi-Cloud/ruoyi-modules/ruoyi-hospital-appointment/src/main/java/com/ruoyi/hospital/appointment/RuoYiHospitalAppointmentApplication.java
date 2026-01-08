package com.ruoyi.hospital.appointment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;
import org.mybatis.spring.annotation.MapperScan;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
@MapperScan("com.ruoyi.hospital.appointment.mapper")
public class RuoYiHospitalAppointmentApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiHospitalAppointmentApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  预约模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
