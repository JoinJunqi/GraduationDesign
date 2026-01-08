# 医院预约挂号管理系统

## 简介

本项目是基于 Spring Cloud + Vue3 微服务架构的医院预约挂号管理系统。
旨在解决传统医疗挂号排队时间长、号源分配不均等痛点，提供高效的挂号、排班、医生与患者管理服务。

## 技术栈

### 后端
- **核心框架**：Spring Boot, Spring Cloud & Alibaba
- **注册/配置中心**：Nacos
- **流量控制**：Sentinel
- **数据库**：MySQL
- **缓存**：Redis
- **对象存储**：Minio (可选)

### 前端
- **框架**：Vue3
- **UI组件库**：Element Plus
- **构建工具**：Vite

## 模块说明

- `ruoyi-gateway`: 网关服务
- `ruoyi-auth`: 认证中心
- `ruoyi-api`: 公共API
- `ruoyi-common`: 公共模块
- `ruoyi-modules`: 业务模块
  - `ruoyi-system`: 系统/医院基础管理 (用户/科室/医生)
  - `ruoyi-gen`: 代码生成
  - `ruoyi-job`: 定时任务
  - `ruoyi-file`: 文件服务
- `ruoyi-visual`: 监控中心

## 快速开始

1. **环境准备**：MySQL, Redis, Nacos 已启动。
2. **配置修改**：确保 Nacos 配置中心 (`ry-config` 库) 中的 Redis/MySQL 地址正确。
3. **启动服务**：Gateway, Auth, System 为基础服务，必须启动。
4. **前端启动**：进入前端目录，运行 `npm run dev`。

