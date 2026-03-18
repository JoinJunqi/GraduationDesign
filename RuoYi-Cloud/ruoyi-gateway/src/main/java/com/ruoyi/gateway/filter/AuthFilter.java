package com.ruoyi.gateway.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import com.ruoyi.common.core.constant.CacheConstants;
import com.ruoyi.common.core.constant.HttpStatus;
import com.ruoyi.common.core.constant.SecurityConstants;
import com.ruoyi.common.core.constant.TokenConstants;
import com.ruoyi.common.core.utils.JwtUtils;
import com.ruoyi.common.core.utils.ServletUtils;
import com.ruoyi.common.core.utils.StringUtils;
import com.ruoyi.common.redis.service.RedisService;
import com.ruoyi.gateway.config.properties.IgnoreWhiteProperties;
import io.jsonwebtoken.Claims;
import reactor.core.publisher.Mono;

/**
 * 网关鉴权
 * 
 * @author ruoyi
 */
@Component
public class AuthFilter implements GlobalFilter, Ordered
{
    private static final Logger log = LoggerFactory.getLogger(AuthFilter.class);

    // 排除过滤的 uri 地址，nacos自行添加
    @Autowired
    private IgnoreWhiteProperties ignoreWhite;

    @Autowired
    private RedisService redisService;


    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain)
    {
        ServerHttpRequest request = exchange.getRequest();
        ServerHttpRequest.Builder mutate = request.mutate();

        String url = request.getURI().getPath();
        
        // 提取 token
        String token = getToken(request);
        boolean isTokenValid = false;
        String userkey = null;
        String userid = null;
        String username = null;
        
        // 尝试解析 token，即便是白名单接口，如果传了有效 token 也向后透传用户信息
        if (StringUtils.isNotEmpty(token)) {
            try {
                Claims claims = JwtUtils.parseToken(token);
                if (claims != null) {
                    userkey = JwtUtils.getUserKey(claims);
                    if (redisService.hasKey(getTokenKey(userkey))) {
                        userid = JwtUtils.getUserId(claims);
                        username = JwtUtils.getUserName(claims);
                        if (StringUtils.isNotEmpty(userid) && StringUtils.isNotEmpty(username)) {
                            isTokenValid = true;
                            addHeader(mutate, SecurityConstants.USER_KEY, userkey);
                            addHeader(mutate, SecurityConstants.DETAILS_USER_ID, userid);
                            addHeader(mutate, SecurityConstants.DETAILS_USERNAME, username);
                        }
                    }
                }
            } catch (Exception e) {
                // Token 解析失败忽略异常，后续判断是否是白名单决定是否拦截
            }
        }

        // 跳过不需要验证的路径（白名单）
        if (StringUtils.matches(url, ignoreWhite.getWhites()) || 
            url.contains("/login") || url.contains("/register") ||
            url.contains("/logout") || url.contains("/code"))
        {
            return chain.filter(exchange.mutate().request(mutate.build()).build());
        }
        
        // 非白名单接口，严格校验 token
        if (StringUtils.isEmpty(token))
        {
            return unauthorizedResponse(exchange, "令牌不能为空");
        }
        if (!isTokenValid)
        {
            return unauthorizedResponse(exchange, "令牌已过期或验证不正确！");
        }

        // 内部请求来源参数清除
        removeHeader(mutate, SecurityConstants.FROM_SOURCE);
        return chain.filter(exchange.mutate().request(mutate.build()).build());
    }

    private void addHeader(ServerHttpRequest.Builder mutate, String name, Object value)
    {
        if (value == null)
        {
            return;
        }
        String valueStr = value.toString();
        String valueEncode = ServletUtils.urlEncode(valueStr);
        mutate.header(name, valueEncode);
    }

    private void removeHeader(ServerHttpRequest.Builder mutate, String name)
    {
        mutate.headers(httpHeaders -> httpHeaders.remove(name)).build();
    }

    private Mono<Void> unauthorizedResponse(ServerWebExchange exchange, String msg)
    {
        log.error("[鉴权异常处理]请求路径:{},错误信息:{}", exchange.getRequest().getPath(), msg);
        return ServletUtils.webFluxResponseWriter(exchange.getResponse(), msg, HttpStatus.UNAUTHORIZED);
    }

    /**
     * 获取缓存key
     */
    private String getTokenKey(String token)
    {
        return CacheConstants.LOGIN_TOKEN_KEY + token;
    }

    /**
     * 获取请求token
     */
    private String getToken(ServerHttpRequest request)
    {
        String token = request.getHeaders().getFirst(SecurityConstants.AUTHORIZATION_HEADER);
        // 如果前端设置了令牌前缀，则裁剪掉前缀
        if (StringUtils.isNotEmpty(token) && token.startsWith(TokenConstants.PREFIX))
        {
            token = token.replaceFirst(TokenConstants.PREFIX, StringUtils.EMPTY);
        }
        return token;
    }

    @Override
    public int getOrder()
    {
        return -200;
    }
}