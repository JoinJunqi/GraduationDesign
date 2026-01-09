package com.ruoyi.common.core.utils;

import com.ruoyi.common.core.constant.SecurityConstants;
import com.ruoyi.common.core.constant.TokenConstants;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 工具类
 * 用于生成、验证和解析 JWT Token
 */
public class JwtTokenUtil {

    private static final String SECRET = TokenConstants.SECRET;

    /**
     * 生成 Token
     *
     * @param userId 用户 ID
     * @param username 用户名
     * @param role 角色
     * @return Token 字符串
     */
    public static String createToken(Long userId, String username, String role) {
        Map<String, Object> claims = new HashMap<>();
        claims.put(SecurityConstants.DETAILS_USER_ID, userId);
        claims.put(SecurityConstants.DETAILS_USERNAME, username);
        claims.put("role", role);
        return createToken(claims);
    }

    /**
     * 生成 Token
     *
     * @param claims 数据声明
     * @return Token 字符串
     */
    public static String createToken(Map<String, Object> claims) {
        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(new Date())
                .signWith(SignatureAlgorithm.HS512, SECRET)
                .compact();
    }

    /**
     * 解析 Token
     *
     * @param token Token 字符串
     * @return Claims 数据声明
     */
    public static Claims parseToken(String token) {
        try {
            return Jwts.parser()
                    .setSigningKey(SECRET)
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 验证 Token 是否有效
     *
     * @param token Token 字符串
     * @return true 有效，false 无效
     */
    public static boolean validateToken(String token) {
        return parseToken(token) != null;
    }

    /**
     * 从 Token 中获取用户 ID
     *
     * @param token Token 字符串
     * @return 用户 ID
     */
    public static Long getUserId(String token) {
        Claims claims = parseToken(token);
        if (claims != null) {
            Object userId = claims.get(SecurityConstants.DETAILS_USER_ID);
            if (userId instanceof Integer) {
                return ((Integer) userId).longValue();
            } else if (userId instanceof Long) {
                return (Long) userId;
            }
        }
        return null;
    }

    /**
     * 从 Token 中获取用户名
     *
     * @param token Token 字符串
     * @return 用户名
     */
    public static String getUsername(String token) {
        Claims claims = parseToken(token);
        return claims != null ? (String) claims.get(SecurityConstants.DETAILS_USERNAME) : null;
    }

    /**
     * 从 Token 中获取角色
     *
     * @param token Token 字符串
     * @return 角色
     */
    public static String getRole(String token) {
        Claims claims = parseToken(token);
        return claims != null ? (String) claims.get("role") : null;
    }
}
