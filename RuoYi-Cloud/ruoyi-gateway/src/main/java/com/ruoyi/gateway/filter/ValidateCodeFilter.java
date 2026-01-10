package com.ruoyi.gateway.filter;

import java.nio.charset.StandardCharsets;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferUtils;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpRequestDecorator;
import org.springframework.stereotype.Component;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.core.utils.ServletUtils;
import com.ruoyi.common.core.utils.StringUtils;
import com.ruoyi.gateway.config.properties.CaptchaProperties;
import com.ruoyi.gateway.service.ValidateCodeService;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * 验证码过滤器
 *
 * @author ruoyi
 */
@Component
public class ValidateCodeFilter extends AbstractGatewayFilterFactory<Object>
{
    private final static String[] VALIDATE_URL = new String[] { 
        "/auth/login", "/auth/register", 
        "/patient/login", "/patient/register", 
        "/doctor/login", "/admin/login",
        "/ruoyi-hospital-patient/patient/login", "/ruoyi-hospital-patient/patient/register",
        "/ruoyi-hospital-doctor/doctor/login",
        "/ruoyi-hospital-admin/admin/login"
    };

    @Autowired
    private ValidateCodeService validateCodeService;

    @Autowired
    private CaptchaProperties captchaProperties;

    private static final String CODE = "code";

    private static final String UUID = "uuid";

    @Override
    public GatewayFilter apply(Object config)
    {
        return (exchange, chain) -> {
            ServerHttpRequest request = exchange.getRequest();

            // 非登录/注册请求或验证码关闭，不处理
            if (!StringUtils.equalsAnyIgnoreCase(request.getURI().getPath(), VALIDATE_URL) || !captchaProperties.getEnabled())
            {
                return chain.filter(exchange);
            }

            return DataBufferUtils.join(exchange.getRequest().getBody()).flatMap(dataBuffer -> {
                byte[] bytes = new byte[dataBuffer.readableByteCount()];
                dataBuffer.read(bytes);
                String bodyString = new String(bytes, StandardCharsets.UTF_8);
                DataBufferUtils.release(dataBuffer);
                
                try
                {
                    JSONObject obj = JSON.parseObject(bodyString);
                    validateCodeService.checkCaptcha(obj.getString(CODE), obj.getString(UUID));
                }
                catch (Exception e)
                {
                    return ServletUtils.webFluxResponseWriter(exchange.getResponse(), e.getMessage());
                }
                
                // 将读取出来的 body 重新包装成 DataBuffer 传递下去，否则下游无法再次读取
                ServerHttpRequest mutatedRequest = new ServerHttpRequestDecorator(exchange.getRequest())
                {
                    @Override
                    public Flux<DataBuffer> getBody()
                    {
                        return Flux.just(exchange.getResponse().bufferFactory().wrap(bytes));
                    }
                };
                return chain.filter(exchange.mutate().request(mutatedRequest).build());
            });
        };
    }
}
