package com.ruoyi.department;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import com.ruoyi.common.security.annotation.EnableCustomConfig;
import com.ruoyi.common.security.annotation.EnableRyFeignClients;

@EnableCustomConfig
@EnableRyFeignClients
@SpringBootApplication
public class RuoYiDepartmentApplication
{
    public static void main(String[] args)
    {
        SpringApplication.run(RuoYiDepartmentApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  科室模块启动成功   ლ(´ڡ`ლ)ﾞ  \n");
    }
}
