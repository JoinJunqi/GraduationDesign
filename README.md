# 医院预约挂号管理系统 - 安装与使用说明

## 目录
1. [项目概述](#项目概述)
2. [系统架构](#系统架构)
3. [功能说明](#功能说明)
4. [项目目录结构](#项目目录结构)
5. [环境准备](#环境准备)
6. [部署前必须确认的配置](#部署前必须确认的配置)
7. [传统方式部署（推荐开发调试）](#传统方式部署推荐开发调试)
8. [Docker 与混合部署说明](#docker-与混合部署说明)
9. [前端运行方式](#前端运行方式)
10. [系统使用说明](#系统使用说明)
11. [常见问题](#常见问题)
12. [附录](#附录)

---

## 项目概述

本项目是一个基于 **Spring Cloud + Vue 3 + Vite** 的医院预约挂号管理系统，后端采用微服务架构，前端采用单仓库多角色入口方式，覆盖管理员、医生、患者和访客四类使用场景。

项目的核心目标包括：

- 实现医院基础信息数字化管理
- 实现医生排班与号源管理
- 实现患者在线预约挂号
- 实现预约取消、审核、回收站恢复等业务闭环
- 实现医生就诊与病历书写
- 提供预约统计看板与后台管理能力

### 技术栈

**后端**

- Java 17
- Maven 3.6+
- Spring Boot 2.7.18
- Spring Cloud 2021.0.9
- Spring Cloud Alibaba 2021.0.6.1
- Nacos 2.x（注册中心 / 配置中心）
- Redis（缓存与并发控制）
- MySQL 5.7+
- Sentinel（流控配置已预留）
- MyBatis-Plus

**前端**

- Vue 3.5.16
- Vite 6.3.5
- Element Plus 2.10.7
- Pinia 3.0.2
- Vue Router 4.5.1
- Axios 1.9.0
- ECharts 5.6.0

### 项目特点

- 采用网关统一转发接口，前后端彻底分离
- 前端同一套代码支持管理员端、患者端、医生端三种入口
- 患者支持注册与访客浏览
- 预约流程采用五步式交互：选科室 -> 选医生 -> 选排班 -> 选时段 -> 确认预约
- 预约与排班模块包含审核流、软删除、回收站恢复等完整后台管理能力
- 排班号源使用 Redis 进行缓存与并发控制

---

## 系统架构

### 整体架构

系统由以下部分组成：

1. **前端应用**
   - `d:\GraduationDesign\RuoYi-Cloud-Vue3`
   - 负责页面渲染、角色入口、交互流程和接口调用

2. **网关与认证中心**
   - `ruoyi-gateway`：统一入口，负责路由转发
   - `ruoyi-auth`：管理员认证中心

3. **系统基础服务**
   - `ruoyi-system`：菜单、用户、个人信息、路由等系统基础能力

4. **医院业务微服务**
   - `ruoyi-hospital-doctor`：医生管理
   - `ruoyi-hospital-patient`：患者管理 / 患者登录注册
   - `ruoyi-hospital-department`：科室管理 / 科室介绍 / 公告
   - `ruoyi-hospital-schedule`：排班管理
   - `ruoyi-hospital-appointment`：预约管理 / 审核流 / 统计
   - `ruoyi-hospital-record`：病历管理

5. **基础中间件**
   - MySQL：业务数据存储
   - Redis：缓存、号源控制、锁控制
   - Nacos：服务注册与配置下发

### 网关路由前缀

前端实际访问的后端路径统一经过 `Gateway(8080)` 转发，常见前缀如下：

| 路由前缀 | 对应服务 |
|---|---|
| `/auth/**` | `ruoyi-auth` |
| `/system/**` | `ruoyi-system` |
| `/ruoyi-hospital-department/**` | 科室服务 |
| `/ruoyi-hospital-doctor/**` | 医生服务 |
| `/ruoyi-hospital-patient/**` | 患者服务 |
| `/ruoyi-hospital-schedule/**` | 排班服务 |
| `/ruoyi-hospital-appointment/**` | 预约服务 |
| `/ruoyi-hospital-record/**` | 病历服务 |

### 微服务端口说明

根据各模块 `bootstrap.yml`，当前项目默认端口如下：

| 服务名 | 应用名 | 默认端口 | 说明 |
|---|---|---:|---|
| Gateway | `ruoyi-gateway` | 8080 | 统一网关入口 |
| Auth | `ruoyi-auth` | 9200 | 管理员认证 |
| System | `ruoyi-system` | 9201 | 用户、菜单、系统资料 |
| Patient | `ruoyi-hospital-patient` | 9602 | 患者资料、登录、注册 |
| Doctor | `ruoyi-hospital-doctor` | 9603 | 医生资料、登录、个人中心 |
| Appointment | `ruoyi-hospital-appointment` | 9604 | 预约、取消、审核、统计 |
| Schedule | `ruoyi-hospital-schedule` | 9605 | 排班与号源 |
| Department | `ruoyi-hospital-department` | 9606 | 科室、科室介绍、公告 |
| Record | `ruoyi-hospital-record` | 9607 | 病历管理 |
| Monitor | `ruoyi-monitor` | 9100 | 监控中心 |

---

## 功能说明

### 一、管理员端功能

管理员端是后台运营与数据维护中心，主要包括：

- **首页看板**
  - 展示总预约量、今日预约量、注册患者数、在职医生数
  - 展示近 7 天预约趋势、预约状态分布、科室预约分布

- **科室管理**
  - 科室增删改查
  - 科室介绍维护
  - 科室回收站恢复

- **医生管理**
  - 医生信息维护
  - 医生账号管理
  - 医生回收站恢复

- **患者管理**
  - 患者信息维护
  - 患者状态管理
  - 患者回收站恢复

- **排班管理**
  - 排班新增、修改、取消、删除
  - 支持按医生、科室、日期筛选
  - 支持排班回收站恢复

- **预约管理**
  - 查看所有预约记录
  - 修改预约状态
  - 取消预约 / 审核取消 / 查看回收站
  - 统计分析

- **审核中心**
  - 审核预约取消申请
  - 审核医生发起的排班调整 / 取消 / 删除申请

- **病历管理**
  - 查看病历记录
  - 维护病历信息

- **公告管理**
  - 医院公告发布、编辑、删除

### 二、医生端功能

医生端以排班和就诊为主，主要包括：

- 医生登录
- 个人中心与密码修改
- 仅查看和维护本人的排班
- 发起排班新增、调整、取消、删除申请
- 查看分配给自己的预约记录
- 进入就诊工作台
- 书写病历、保存病历
- 将预约状态更新为“已完成”

### 三、患者端功能

患者端以挂号和查看个人就诊信息为主，主要包括：

- 患者注册
- 患者登录
- 个人中心与密码修改
- 按科室、医生、日期查看可预约资源
- 五步式预约挂号
- 查看我的预约
- 发起取消申请 / 撤回取消申请
- 查看我的病历

### 四、访客模式

前端支持访客登录能力，访客可浏览部分信息，但受限于权限：

- 可浏览科室、医生、排班、部分挂号页信息
- 无法真正提交预约
- 无法查看“我的预约”和“我的病历”
- 当访客尝试挂号或查看个人数据时，系统会提示先登录

### 五、预约业务特性

结合前后端源码，当前预约流程与规则如下：

1. 患者进入挂号页后，按照以下步骤操作：
   - 选择科室
   - 选择医生
   - 选择排班
   - 选择具体时段
   - 确认预约

2. 具体时段按 **15 分钟 / 号源** 划分
   - 上午、下午、全天三种班次
   - 半天理论最大号源为 14
   - 全天理论最大号源为 28

3. 后端会校验：
   - 同一患者不能重复预约同一排班
   - 同一排班下同一具体时段不能被重复占用
   - 排班剩余号源不足时不能继续预约

4. 预约列表具有角色数据隔离：
   - 管理员查看全量预约
   - 医生仅查看自己的预约
   - 患者仅查看自己的预约

5. 预约状态支持业务流转，例如：
   - 待就诊
   - 已完成
   - 已取消
   - 取消审核中
   - 已过期

### 六、排班业务特性

- 患者 / 匿名用户只查看可预约范围内的排班
- 患者侧默认更关注近期排班数据
- 医生只能维护自己的排班
- 医生发起的新增、修改、删除、取消等关键操作会进入审核流
- 排班取消时会联动预约处理
- 排班与号源缓存通过 Redis 维护，降低并发下的超卖风险

---

## 项目目录结构

```text
d:\GraduationDesign\
├── RuoYi-Cloud-Vue3\                 # Vue3 前端项目
│   ├── src\
│   │   ├── api\                      # 接口封装
│   │   ├── views\                    # 页面视图
│   │   ├── router\                   # 路由配置
│   │   ├── store\                    # Pinia 状态管理
│   │   └── utils\                    # 工具类
│   ├── bin\                          # 前端脚本
│   ├── .env.development              # 开发环境变量
│   ├── vite.config.js                # Vite 配置
│   └── package.json
├── RuoYi-Cloud\                      # Spring Cloud 后端项目
│   ├── ruoyi-auth\                   # 认证服务
│   ├── ruoyi-gateway\                # 网关服务
│   ├── ruoyi-common\                 # 公共组件
│   ├── ruoyi-api\                    # 公共接口
│   ├── ruoyi-modules\                # 业务模块
│   │   ├── ruoyi-system\             # 系统模块
│   │   ├── ruoyi-modules-doctor\     # 医生模块
│   │   ├── ruoyi-modules-patient\    # 患者模块
│   │   ├── ruoyi-modules-department\ # 科室模块
│   │   ├── ruoyi-modules-schedule\   # 排班模块
│   │   ├── ruoyi-modules-appointment\ # 预约模块
│   │   └── ruoyi-modules-record\     # 病历模块
│   ├── ruoyi-visual\                 # 可视化监控
│   ├── nacos\                        # Nacos 导入配置文件
│   ├── DEFAULT_GROUP\                # 另一份分组配置参考
│   ├── sql\                          # 数据库脚本
│   ├── docker\                       # Docker 配置
│   ├── bin\                          # 启动脚本
│   ├── init_admin_data.sql           # 初始化管理员数据
│   └── pom.xml
└── 项目安装与使用说明.md             # 当前文档
```

---

## 环境准备

### 必须安装的软件

1. **JDK 17**
   - 配置 `JAVA_HOME`
   - 验证命令：`java -version`

2. **Maven 3.6+**
   - 配置 `MAVEN_HOME`
   - 验证命令：`mvn -v`

3. **Node.js 16+**
   - 验证命令：`node -v`
   - 验证命令：`npm -v`

4. **MySQL 5.7+**
   - 默认端口：`3306`

5. **Redis**
   - 默认端口：`6379`

6. **Nacos 2.x**
   - 默认端口：`8848`

### 可选软件

- Docker
- Docker Compose
- Navicat / DBeaver
- Postman / Apifox

### Maven 镜像建议

若依赖下载缓慢，建议在 `settings.xml` 中配置阿里云镜像：

```xml
<mirror>
  <id>aliyunmaven</id>
  <mirrorOf>*</mirrorOf>
  <name>aliyun public</name>
  <url>https://maven.aliyun.com/repository/public</url>
</mirror>
```

---

## 部署前必须确认的配置

这一步非常重要，建议先完成再启动服务。

### 1. 数据库名称不是 `ry-cloud`，而是 `hospital_booking`

当前项目源码与 Nacos 配置中实际连接的数据库名称为：

```sql
hospital_booking
```

因此创建数据库时请使用：

```sql
CREATE DATABASE `hospital_booking` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. Nacos 配置文件实际位置

请导入以下目录中的配置文件，而不是旧文档中的外部路径：

```text
d:\GraduationDesign\RuoYi-Cloud\nacos\
```

需要导入的文件包括：

- `application-dev.yml`
- `ruoyi-auth-dev.yml`
- `ruoyi-gateway-dev.yml`
- `ruoyi-hospital-admin-dev.yml`
- `ruoyi-hospital-appointment-dev.yml`
- `ruoyi-hospital-department-dev.yml`
- `ruoyi-hospital-doctor-dev.yml`
- `ruoyi-hospital-patient-dev.yml`
- `ruoyi-hospital-record-dev.yml`
- `ruoyi-hospital-schedule-dev.yml`
- `ruoyi-system-dev.yml`

### 3. 检查 Nacos 地址是否需要改成本机

当前多个服务的 `bootstrap.yml` 中，`Nacos` 地址写的是：

```text
192.168.233.128:8848
```

如果你是在本机单机部署，请将对应模块中的 `bootstrap.yml` 改为：

```text
127.0.0.1:8848
```

需要重点检查的目录包括：

- `d:\GraduationDesign\RuoYi-Cloud\ruoyi-auth\src\main\resources\bootstrap.yml`
- `d:\GraduationDesign\RuoYi-Cloud\ruoyi-gateway\src\main\resources\bootstrap.yml`
- `d:\GraduationDesign\RuoYi-Cloud\ruoyi-modules\**\src\main\resources\bootstrap.yml`

### 4. 检查共享配置中的数据库与 Redis 连接

打开以下文件，按你的本机环境修改：

```text
d:\GraduationDesign\RuoYi-Cloud\nacos\application-dev.yml
```

需要重点确认：

- `spring.datasource.host`
- `spring.datasource.port`
- `spring.datasource.username`
- `spring.datasource.password`
- `spring.redis.host`
- `spring.redis.port`

### 5. Sentinel 配置为固定 IP，单机开发可按需关闭或改成本机

在 `application-dev.yml` 中已存在如下配置：

- `dashboard: 192.168.233.128:8858`
- `client-ip: 192.168.233.1`

如果本机没有该 Sentinel 环境，开发调试时建议修改为本机地址，或暂时关闭相关依赖影响。

---

## 传统方式部署（推荐开发调试）

该方式最适合本项目当前结构，因为医院业务模块、网关、认证、系统模块的联调最方便。

### 一、创建数据库并导入脚本

```bash
mysql -u root -p
```

执行：

```sql
CREATE DATABASE `hospital_booking` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

然后导入 SQL：

```bash
mysql -u root -p hospital_booking < d:\GraduationDesign\RuoYi-Cloud\sql\hospital_booking_new.sql
mysql -u root -p hospital_booking < d:\GraduationDesign\RuoYi-Cloud\init_admin_data.sql
```

### 二、启动 Redis

确保 Redis 已正常启动，端口为 `6379`。

### 三、启动 Nacos

```bash
cd nacos\bin
startup.cmd -m standalone
```

启动后访问：

- `http://localhost:8848/nacos`
- 默认账号：`nacos`
- 默认密码：`nacos`

### 四、导入 Nacos 配置

在 Nacos 控制台中导入：

- 配置来源目录：`d:\GraduationDesign\RuoYi-Cloud\nacos\`
- 文件类型：`yml`
- 命名空间：默认即可
- Group：建议使用 `DEFAULT_GROUP`

### 五、编译后端项目

```bash
cd d:\GraduationDesign\RuoYi-Cloud
mvn clean package -DskipTests
```

### 六、启动后端服务

#### 方式一：使用现成脚本启动

```bash
cd d:\GraduationDesign\RuoYi-Cloud\bin
run-all-service.bat
```

说明：

- `run-all-service.bat` 会启动 `Gateway`、`Auth`、`System`
- 随后会调用 `run-modules-hospital.bat` 启动 6 个医院业务模块

#### 方式二：手动按顺序启动

```bash
cd d:\GraduationDesign\RuoYi-Cloud\bin

run-gateway.bat
run-auth.bat
run-modules-system.bat
run-modules-hospital.bat
```

### 七、验证后端是否启动成功

建议依次检查：

- `http://localhost:8080/actuator/health`
- Nacos 中是否已注册所有服务
- 控制台是否出现各服务启动成功日志

---

## Docker 与混合部署说明

### 重要说明

当前项目的 `docker-compose.yml` **并不是完整的一键部署方案**。

它目前包含的主要是：

- `ruoyi-mysql`
- `ruoyi-redis`
- `ruoyi-nacos`
- `ruoyi-gateway`
- `ruoyi-auth`
- `ruoyi-modules-system`
- `ruoyi-modules-gen`
- `ruoyi-modules-job`
- `ruoyi-modules-file`
- `ruoyi-visual-monitor`
- `ruoyi-nginx`

**但不包含以下医院核心业务模块：**

- `ruoyi-hospital-doctor`
- `ruoyi-hospital-patient`
- `ruoyi-hospital-appointment`
- `ruoyi-hospital-department`
- `ruoyi-hospital-schedule`
- `ruoyi-hospital-record`

因此，当前更准确的说法是：

- 可以用 Docker 启动基础环境和若依通用模块
- 医院业务模块建议仍按本地 Java 进程方式启动
- 或者你自行补充 Dockerfile 与 Compose 配置后再实现完整容器化

### 推荐的混合部署方式

#### 1. 先启动基础中间件

```bash
cd d:\GraduationDesign\RuoYi-Cloud\docker
docker-compose up -d ruoyi-mysql ruoyi-redis ruoyi-nacos
```

#### 2. 导入数据库与 Nacos 配置

仍按本文“传统方式部署”中的步骤执行。

#### 3. 本地启动医院业务服务

```bash
cd d:\GraduationDesign\RuoYi-Cloud\bin
run-all-service.bat
```

#### 4. 前端本地运行，或构建后交给 Nginx

```bash
cd d:\GraduationDesign\RuoYi-Cloud-Vue3
npm install
npm run build:prod
```

### Docker 目录说明

- `docker/mysql`：MySQL 镜像构建目录
- `docker/redis`：Redis 镜像构建目录
- `docker/nacos`：Nacos 镜像构建目录
- `docker/nginx`：Nginx 配置
- `docker/ruoyi`：若依通用模块镜像目录

---

## 前端运行方式

前端项目路径：

```text
d:\GraduationDesign\RuoYi-Cloud-Vue3
```

### 1. 安装依赖

```bash
cd d:\GraduationDesign\RuoYi-Cloud-Vue3
npm install
```

如安装较慢，可使用镜像源：

```bash
npm install --registry=https://registry.npmmirror.com
```

### 2. 开发环境启动

```bash
# 管理员端
npm run dev:admin

# 患者端
npm run dev:patient

# 医生端
npm run dev:doctor
```

### 3. 默认访问地址

| 角色 | 启动命令 | 地址 |
|---|---|---|
| 管理员端 | `npm run dev:admin` | `http://localhost:3000/login?type=admin` |
| 患者端 | `npm run dev:patient` | `http://localhost:3001/login?type=patient` |
| 医生端 | `npm run dev:doctor` | `http://localhost:3002/login?type=doctor` |

补充说明：

- 路由中还提供了便捷入口：
  - `/admin` 会重定向到管理员登录
  - `/doc` 会重定向到医生登录
- 开发环境接口代理目标为：

```text
http://localhost:8080
```

也就是所有前端请求最终都会转发到网关服务。

### 4. 生产构建

```bash
npm run build:prod
```

构建产物输出到：

```text
d:\GraduationDesign\RuoYi-Cloud-Vue3\dist
```

可将该目录部署到 Nginx。

---

## 系统使用说明

### 一、初始化账号

根据 `init_admin_data.sql`，可确认管理员初始化账号为：

| 角色 | 用户名 | 密码 | 说明 |
|---|---|---|---|
| 管理员 | `admin` | `admin123` | 已在初始化 SQL 中明确提供 |

说明：

- 患者端支持自行注册
- 医生账号通常依赖你导入的业务初始化数据
- 若导入的是完整 `hospital_booking_new.sql`，可根据数据表中的样例数据进行登录测试

### 二、推荐测试路径

#### 1. 管理员测试

- 登录后台
- 配置科室
- 配置医生
- 配置排班
- 查看预约统计看板
- 审核取消申请与排班调整申请

#### 2. 患者测试

- 先注册患者账号
- 登录患者端
- 进入挂号页
- 选择科室、医生、排班、时段并提交预约
- 查看我的预约
- 发起取消申请

#### 3. 医生测试

- 登录医生端
- 查看个人排班
- 管理自己可维护的排班
- 进入就诊工作台
- 填写病历并完成就诊

### 三、完整业务流程

1. 管理员维护科室与医生基础信息
2. 管理员或医生生成排班与号源
3. 患者登录后选择科室和医生
4. 患者选择具体排班与 15 分钟时段
5. 系统创建预约记录并扣减号源
6. 患者可在预约列表中查看记录
7. 如需取消，可提交取消申请进入审核流
8. 医生在就诊工作台查看预约详情并书写病历
9. 医生完成就诊后，预约状态更新为“已完成”

---

## 常见问题

### 1. Nacos 能启动，但服务注册不上

**常见原因：**

- `bootstrap.yml` 中的 Nacos 地址仍然是局域网 IP `192.168.233.128:8848`
- 本机 Nacos 实际运行在 `127.0.0.1:8848`

**解决方法：**

- 将各服务 `bootstrap.yml` 中的 `server-addr` 统一改为本机地址

### 2. 数据库明明创建了，服务仍提示找不到库

**常见原因：**

- 文档旧版本写的是 `ry-cloud`
- 当前项目源码实际连接的是 `hospital_booking`

**解决方法：**

- 创建并导入到 `hospital_booking`

### 3. Nacos 配置导入了，但服务读取不到

**排查方向：**

- Data ID 是否正确
- Group 是否正确
- YML 格式是否被破坏
- 是否导入了 `d:\GraduationDesign\RuoYi-Cloud\nacos\` 下的完整文件

### 4. 前端页面能打开，但接口全部 404

**排查方向：**

- 网关 `8080` 是否已启动
- Vite 代理是否仍指向 `http://localhost:8080`
- Nacos 中医院业务模块是否全部已注册

### 5. Docker 启动后仍然不能挂号

**常见原因：**

- 当前 `docker-compose.yml` 未包含医院核心业务模块

**解决方法：**

- 按本文采用混合部署方式
- 或自行补充 doctor / patient / appointment / department / schedule / record 的容器配置

### 6. 预约页面没有可选时段

**可能原因：**

- 该日期没有排班
- 排班已取消
- 号源已满
- 当前时间已过可预约时段

### 7. Maven 编译失败

**解决方法：**

- 检查 JDK 版本是否为 17
- 检查 Maven 镜像配置
- 执行 `mvn -v` 确认环境变量是否正确

### 8. 端口被占用

Windows 可执行：

```bash
netstat -ano | findstr "8080"
taskkill /PID 进程ID /F
```

将端口号替换为实际冲突端口即可。

---

## 附录

### A. 服务健康检查地址

启动成功后可检查以下地址：

- Nacos：`http://localhost:8848/nacos`
- Gateway：`http://localhost:8080/actuator/health`
- 管理员前端：`http://localhost:3000`
- 患者前端：`http://localhost:3001`
- 医生前端：`http://localhost:3002`

### B. 常用启动命令速查

```bash
# 后端编译
cd d:\GraduationDesign\RuoYi-Cloud
mvn clean package -DskipTests

# 启动后端
cd d:\GraduationDesign\RuoYi-Cloud\bin
run-all-service.bat

# 启动管理员前端
cd d:\GraduationDesign\RuoYi-Cloud-Vue3
npm run dev:admin

# 启动患者前端
npm run dev:patient

# 启动医生前端
npm run dev:doctor
```

### C. 开发工具建议

- 后端 IDE：IntelliJ IDEA
- 前端 IDE：VS Code
- 数据库工具：Navicat、DBeaver
- 接口工具：Postman、Apifox
- 版本管理：Git

---

**说明**：本说明文档已根据 `d:\GraduationDesign\RuoYi-Cloud-Vue3` 与 `d:\GraduationDesign\RuoYi-Cloud` 当前源码结构重新整理，优先以实际项目代码、脚本和配置为准。
