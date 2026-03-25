# Paperplane 部署指南

本文档介绍如何将 Paperplane 部署到各种云平台，特别针对中国用户可访问、基本免费或低成本的方案。

## 目录

- [方案对比](#方案对比)
- [推荐方案：腾讯云轻量应用服务器](#推荐方案腾讯云轻量应用服务器)
- [备选方案：阿里云轻量应用服务器](#备选方案阿里云轻量应用服务器)
- [海外方案：Railway](#海外方案railway)
- [海外方案：Fly.io](#海外方案flyio)
- [完全免费：Oracle Cloud](#完全免费oracle-cloud)

---

## 方案对比

| 平台 | 费用 | 中国访问 | 难度 | 推荐指数 |
|------|------|---------|------|---------|
| 腾讯云轻量 | 新用户首年 ~50元 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 阿里云轻量 | 新用户首年 ~50元 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Railway | $5/月免费额度 | ⭐⭐ | ⭐ | ⭐⭐⭐ |
| Fly.io | 有免费额度 | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Oracle Cloud | 永久免费 | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |

---

## 推荐方案：腾讯云轻量应用服务器（国内首选）

### 特点

- ✅ 国内访问速度快（香港/新加坡节点延迟低）
- ✅ 新用户首单 40-100元/年（几乎免费）
- ✅ 无需备案（选香港/新加坡）
- ✅ 有独立公网 IP
- ✅ 支持 Docker，一键部署

---

### 准备工作

1. **腾讯云账号**
   - 访问 https://cloud.tencent.com
   - 注册并实名认证

2. **支付方式**
   - 绑定微信支付或支付宝
   - 新用户首单通常 1-3 折

---

### 步骤 1：购买服务器

1. 访问 [腾讯云轻量应用服务器](https://cloud.tencent.com/product/lighthouse)

2. 点击「立即选购」，选择配置：

| 配置项 | 推荐选项 | 说明 |
|--------|---------|------|
| **地域** | 香港 或 新加坡 | 无需备案，国内访问快 |
| **镜像** | Docker 基础镜像 | 预装 Docker，省事 |
| **套餐** | 2核2G4M 或 2核4G6M | 最低配够用，建议 2核4G |
| **时长** | 1年 | 首年最便宜 |
| **数据盘** | 0-50GB | 可选，系统盘 50GB 够用 |

3. 点击购买，完成支付

4. 进入控制台，找到你的服务器，点击「重置密码」，设置 root 密码

---

### 步骤 2：连接服务器

```bash
# 在本地终端执行（Windows 用 PowerShell 或 Git Bash）
ssh root@你的服务器IP

# 示例
ssh root@43.123.45.67

# 输入密码（输入时不显示）
```

**Windows 用户推荐工具**：
- [Tabby](https://tabby.sh/)（免费，推荐）
- [PuTTY](https://www.putty.org/)
- Windows Terminal

---

### 步骤 3：初始化服务器

```bash
# 更新系统
apt update && apt upgrade -y

# 设置时区
timedatectl set-timezone Asia/Shanghai

# 安装必要工具
apt install -y curl wget git vim nginx
```

---

### 步骤 4：安装 Node.js 20+ 和 pnpm

```bash
# 安装 Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# 验证
node -v   # 应显示 v20.x.x
npm -v    # 应显示 10.x.x

# 安装 pnpm
npm install -g pnpm

# 验证
pnpm -v   # 应显示 9.x.x
```

---

### 步骤 5：克隆并构建 Paperplane

```bash
# 创建工作目录
mkdir -p /opt
cd /opt

# 克隆代码
git clone https://github.com/paperplaneai/paperplane.git
cd paperplane

# 安装依赖（可能需要 5-10 分钟）
pnpm install

# 构建
pnpm build
```

**如果 GitHub 访问慢，换镜像**：
```bash
git clone https://ghproxy.com/https://github.com/paperplaneai/paperplane.git
```

---

### 步骤 6：配置环境变量

```bash
# 创建数据目录
mkdir -p /paperplane/instances/default

# 创建环境变量文件
cat > /opt/paperplane/.env << 'EOF'
NODE_ENV=production
HOST=0.0.0.0
PORT=3100
SERVE_UI=true
PAPERPLANE_HOME=/paperplane
PAPERPLANE_INSTANCE_ID=default
PAPERPLANE_DEPLOYMENT_MODE=authenticated
PAPERPLANE_DEPLOYMENT_EXPOSURE=public
EOF

# 加载环境变量
source /opt/paperplane/.env
```

---

### 步骤 7：配置 Nginx 反向代理（推荐）

```bash
# 删除默认配置
rm -f /etc/nginx/sites-enabled/default

# 创建 Paperplane 配置
cat > /etc/nginx/sites-available/paperplane << 'EOF'
server {
    listen 80;
    server_name _;  # 接受任何域名或IP

    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:3100;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# 启用配置
ln -s /etc/nginx/sites-available/paperplane /etc/nginx/sites-enabled/

# 测试配置
nginx -t

# 启动 Nginx
systemctl restart nginx
systemctl enable nginx
```

---

### 步骤 8：配置 PM2 进程管理

```bash
# 安装 PM2
npm install -g pm2

# 创建 PM2 配置文件
cat > /opt/paperplane/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'paperplane',
    cwd: '/opt/paperplane',
    script: 'server/dist/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      HOST: '0.0.0.0',
      PORT: '3100',
      SERVE_UI: 'true',
      PAPERPLANE_HOME: '/paperplane',
      PAPERPLANE_INSTANCE_ID: 'default',
      PAPERPLANE_DEPLOYMENT_MODE: 'authenticated',
      PAPERPLANE_DEPLOYMENT_EXPOSURE: 'public'
    },
    log_file: '/paperplane/logs/combined.log',
    out_file: '/paperplane/logs/out.log',
    error_file: '/paperplane/logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss'
  }]
};
EOF

# 创建日志目录
mkdir -p /paperplane/logs

# 启动应用
pm2 start ecosystem.config.js

# 保存 PM2 配置
pm2 save

# 设置开机自启
pm2 startup systemd
```

**执行 PM2 startup 后显示的命令**，复制运行一次。

---

### 步骤 9：配置防火墙

```bash
# 开放 80 和 443 端口（在服务器内）
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3100/tcp
ufw enable
```

**同时在腾讯云控制台配置**：
1. 进入「轻量应用服务器」控制台
2. 找到你的服务器，点击「防火墙」
3. 添加规则：
   - TCP 80 允许
   - TCP 443 允许
   - TCP 3100 允许（可选，用于直接访问）

---

### 步骤 10：配置 HTTPS（可选但推荐）

使用 Certbot 申请免费 SSL 证书：

```bash
# 安装 Certbot
snap install --classic certbot

# 申请证书（需要已解析到服务器的域名）
certbot --nginx -d your-domain.com

# 自动续期已配置，无需手动操作
```

**如果没有域名**：
- 直接使用 `http://服务器IP` 访问
- 或购买域名并解析到服务器 IP

---

### 步骤 11：验证部署

```bash
# 查看服务状态
pm2 status
pm2 logs

# 查看端口监听
netstat -tlnp | grep 3100

# 测试本地访问
curl http://127.0.0.1:3100/api/health
```

**浏览器访问**：
- HTTP: `http://你的服务器IP`
- 如果有域名: `http://your-domain.com`
- HTTPS: `https://your-domain.com`（配置 SSL 后）

---

### 常用管理命令

```bash
# 查看日志
pm2 logs paperplane

# 重启应用
pm2 restart paperplane

# 停止应用
pm2 stop paperplane

# 查看资源占用
pm2 monit

# 更新代码后重新部署
cd /opt/paperplane
git pull
pnpm install
pnpm build
pm2 restart paperplane

# 备份数据
tar -czf /root/paperplane-backup-$(date +%Y%m%d).tar.gz /paperplane

# 查看 Nginx 日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

---

### 故障排查

**问题 1：无法访问网站**
```bash
# 检查服务运行状态
pm2 status
pm2 logs

# 检查端口监听
netstat -tlnp | grep 3100

# 检查防火墙
ufw status
```

**问题 2：内存不足（构建时）**
```bash
# 创建 swap 分区
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

**问题 3：GitHub 访问失败**
```bash
# 配置 Git 代理（如果有）
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 或使用镜像
git clone https://ghproxy.com/https://github.com/paperplaneai/paperplane.git
```

---

### 访问地址总结

| 方式 | 地址 |
|------|------|
| HTTP | `http://服务器IP` |
| HTTPS（有域名） | `https://your-domain.com` |
| 直接端口 | `http://服务器IP:3100` |

---

### 总费用

| 项目 | 费用 |
|------|------|
| 腾讯云轻量服务器（首年） | 约 50-100元 |
| 域名（可选） | 约 30-60元/年 |
| **总计** | **约 100-160元/年** |

---

### 下一步

部署完成后：
1. 浏览器访问 `http://服务器IP` 初始化 Paperplane
2. 创建管理员账号
3. 配置 OpenClaw Gateway 或其他 Agent
4. 开始使用！

---

## 备选方案：阿里云轻量应用服务器

与腾讯云几乎相同：

1. 访问 [阿里云轻量应用服务器](https://www.aliyun.com/product/swas)
2. 选择配置（类似腾讯云）
3. 其他部署步骤与腾讯云一致

**注意事项**：
- 阿里云香港节点对大陆访问也很友好
- 新用户首单通常 1折左右

---

## 海外方案：Railway

适合快速部署，但中国访问速度一般。

### 步骤 1：准备

1. 注册 [Railway](https://railway.app)
2. 绑定信用卡（获得 $5/月免费额度）
3. 安装 Railway CLI：

```bash
npm install -g @railway/cli
railway login
```

### 步骤 2：部署

```bash
# 克隆仓库
git clone https://github.com/paperplaneai/paperplane.git
cd paperplane

# 初始化项目
railway init

# 添加 PostgreSQL 服务（可选，Paperplane 有 embedded）
railway add --database

# 部署
railway up
```

### 步骤 3：配置环境变量

在 Railway Dashboard > Variables 中设置：

```
NODE_ENV=production
HOST=0.0.0.0
PORT=3000
SERVE_UI=true
PAPERPLANE_DEPLOYMENT_MODE=authenticated
PAPERPLANE_DEPLOYMENT_EXPOSURE=public
```

### 步骤 4：生成域名

Railway 会自动分配域名，或绑定自定义域名。

---

## 海外方案：Fly.io（推荐新加坡节点）

适合需要海外节点 + 国内访问尚可 + 免费额度的用户。

### 特点

- ✅ 新加坡节点(`sin`) 国内访问延迟约 50-100ms
- ✅ 免费额度足够个人使用
- ✅ 支持 Docker 部署
- ✅ 自带 HTTPS
- ❌ 需要绑定信用卡（验证用，不扣费）

### 步骤 1：注册和安装

1. **注册账号**
   - 访问 https://fly.io
   - 用 GitHub 账号登录
   - 绑定信用卡（仅验证，有免费额度不会扣费）

2. **安装 flyctl**

```bash
# macOS
brew install flyctl

# Windows
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"

# Linux
curl -L https://fly.io/install.sh | sh
```

3. **登录**

```bash
fly auth login
```

### 步骤 2：创建应用

```bash
cd paperplane

# 创建应用（会自动生成 fly.toml）
fly launch --name your-paperplane-name --region sin --no-deploy

# 注意：--name 要用全球唯一的名字，比如 paperplane-xxx-123
```

### 步骤 3：配置 fly.toml

编辑生成的 `fly.toml`，替换为：

```toml
app = 'your-paperplane-name'
primary_region = 'sin'

[build]
  dockerfile = "Dockerfile"

[env]
  NODE_ENV = "production"
  HOST = "0.0.0.0"
  PORT = "3100"
  SERVE_UI = "true"
  PAPERPLANE_DEPLOYMENT_MODE = "authenticated"
  PAPERPLANE_DEPLOYMENT_EXPOSURE = "public"
  PAPERPLANE_HOME = "/paperplane"
  PAPERPLANE_INSTANCE_ID = "default"

[http_service]
  internal_port = 3100
  force_https = true
  auto_stop_machines = false
  auto_start_machines = true
  min_machines_running = 1
  processes = ['app']

[[vm]]
  size = 'shared-cpu-1x'  # 免费档位：256MB 内存
  memory = '512mb'        # 升级到 512MB，防止构建时内存不足

[[mounts]]
  source = 'paperplane_data'
  destination = '/paperplane'
```

### 步骤 4：创建持久化卷

```bash
# 创建 3GB 存储卷（在 sin 区域）
fly volumes create paperplane_data --region sin --size 3
```

### 步骤 5：部署

```bash
# 首次部署
fly deploy

# 查看日志
fly logs

# 查看状态
fly status
```

### 步骤 6：访问应用

部署完成后，Fly.io 会自动分配域名：

```
https://your-paperplane-name.fly.dev
```

### 常用命令

```bash
# 查看日志
fly logs

# 重启应用
fly restart

# 进入容器调试
fly ssh console

# 更新环境变量
fly secrets set KEY=value

# 本地连接数据库（用于备份）
fly proxy 5432 -a your-db-app-name

# 销毁应用（彻底删除）
fly destroy your-paperplane-name
```

### 免费额度检查

```bash
# 查看使用量
fly status --watch

# 在 dashboard 查看账单
fly dashboard
```

### 国内访问优化

如果国内访问还是慢，可以：

1. **绑定自定义域名**（推荐）
```bash
# 添加自定义域名
fly certs add your-domain.com

# 然后在 DNS 添加 CNAME 记录指向 your-paperplane-name.fly.dev
```

2. **使用 Cloudflare 加速**
   - 域名 DNS 托管到 Cloudflare
   - 开启代理（橙色云）
   - 国内访问会走 Cloudflare 的 CDN

### 故障排查

**问题 1：部署失败，内存不足**
```bash
# 方案：升级到付费档位临时构建，再降级
fly scale vm shared-cpu-2x
fly deploy
fly scale vm shared-cpu-1x
```

**问题 2：国内访问超时**
```bash
# 检查应用状态
fly status

# 查看是否有错误日志
fly logs --tail
```

**问题 3：数据丢失**
```bash
# 确保 volume 已挂载
fly volumes list

# 进入容器检查
fly ssh console
ls -la /paperplane
```

---

## 完全免费：Oracle Cloud

永久免费 2核1G ARM 服务器，适合技术能力强的用户。

### 优点
- 完全免费，永久使用
- 有独立公网 IP
- 新加坡节点，国内访问尚可

### 缺点
- 注册和配置较复杂
- 需要信用卡验证
- 有时需要科学上网才能注册

### 部署步骤

1. 注册 [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)
2. 创建 Always Free ARM 实例（Ubuntu 22.04）
3. 开放安全组规则（端口 3100）
4. 其余步骤与腾讯云相同

---

## 常见问题

### Q: 为什么不能用 Vercel/Netlify？
A: Paperplane 需要 Node.js 服务器 + PostgreSQL + 持久化存储，不是纯前端项目，无法部署到静态托管平台。

### Q: 必须使用 PostgreSQL 吗？
A: Paperplane 内置 embedded PostgreSQL，开发时无需安装。生产环境建议使用独立 PostgreSQL。

### Q: 如何配置 HTTPS？
A:
- 方式1：使用 nginx + Let's Encrypt（certbot）
- 方式2：使用 Cloudflare Tunnel（免费，自带 HTTPS）
- 方式3：使用腾讯云 CLB（收费）

### Q: 如何备份数据？
A:
```bash
# Paperplane 数据在 /paperplane 目录
# 定期备份
tar -czf paperplane-backup-$(date +%Y%m%d).tar.gz /paperplane

# 或使用云对象存储同步
```

### Q: 如何更新 Paperplane？
A:
```bash
cd paperplane
git pull
pnpm install
pnpm build
pm2 restart paperplane
```

---

## 推荐配置总结

| 场景 | 推荐方案 | 预计费用 |
|------|---------|---------|
| 国内长期使用 | 腾讯云/阿里云轻量 | ~50元/年 |
| 快速试用 | Railway | 免费（$5额度） |
| 海外部署 | Fly.io 新加坡 | 免费额度内 |
| 完全免费 | Oracle Cloud | 永久免费 |

---

## 相关文档

- [Paperplane GitHub](https://github.com/paperplaneai/paperplane)
- [Paperplane 文档](https://paperplane.ing/docs)
- [OpenClaw Docker 部署](https://github.com/openclaw/openclaw)
