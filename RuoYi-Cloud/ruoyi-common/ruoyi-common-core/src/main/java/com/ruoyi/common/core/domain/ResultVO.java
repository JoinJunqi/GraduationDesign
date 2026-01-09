package com.ruoyi.common.core.domain;

import com.ruoyi.common.core.constant.Constants;
import java.io.Serializable;

/**
 * 通用REST API响应类
 */
public class ResultVO<T> implements Serializable {
    private static final long serialVersionUID = 1L;

    /** 成功 */
    public static final int SUCCESS = Constants.SUCCESS;

    /** 失败 */
    public static final int FAIL = Constants.FAIL;

    /** 状态码 */
    private int code;

    /** 消息 */
    private String msg;

    /** 数据 */
    private T data;

    public ResultVO() {
    }

    public ResultVO(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    /**
     * 成功响应，无数据
     */
    public static <T> ResultVO<T> success() {
        return new ResultVO<>(SUCCESS, "操作成功", null);
    }

    /**
     * 成功响应，带数据
     */
    public static <T> ResultVO<T> success(T data) {
        return new ResultVO<>(SUCCESS, "操作成功", data);
    }

    /**
     * 成功响应，带数据和消息
     */
    public static <T> ResultVO<T> success(T data, String msg) {
        return new ResultVO<>(SUCCESS, msg, data);
    }

    /**
     * 失败响应，默认消息
     */
    public static <T> ResultVO<T> error() {
        return new ResultVO<>(FAIL, "操作失败", null);
    }

    /**
     * 失败响应，自定义消息
     */
    public static <T> ResultVO<T> error(String msg) {
        return new ResultVO<>(FAIL, msg, null);
    }

    /**
     * 失败响应，自定义状态码和消息
     */
    public static <T> ResultVO<T> error(int code, String msg) {
        return new ResultVO<>(code, msg, null);
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}
