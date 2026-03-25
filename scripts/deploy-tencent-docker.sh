#!/bin/bash
#
# Paperplane 腾讯云 Docker 一键部署脚本
# 适用于：腾讯云轻量应用服务器（Docker 镜像）
# 系统：Ubuntu 20.04/22.04 / Debian 11/12
#

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
PAPERPLANE_DIR="/opt/paperplane"
DATA_DIR="/paperplane"
LOG_DIR="/paperplane/logs"
NGINX_CONFIG="/etc/nginx/sites-available/paperplane"
APP_NAME="paperplane"
PORT=3100

# 打印信息
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检查 root 权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "请使用 root 用户运行此脚本，或使用 sudo"
    fi
}

# 检查系统
check_system() {
    info "检查系统环境..."

    # 检查操作系统
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        info "检测到系统: $OS $VER"
    else
        error "无法检测操作系统"
    fi

    # 检查内存
    MEM_TOTAL=$(free -m | awk '/^Mem:/{print $2}')
    if [[ $MEM_TOTAL -lt 1024 ]]; then
        warning "内存不足 1GB (${MEM_TOTAL}MB)，建议至少 2GB"
        read -p "是否继续? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        info "内存检查通过: ${MEM_TOTAL}MB"
    fi

    # 检查磁盘
    DISK_AVAIL=$(df -m / | awk 'NR==2 {print $4}')
    if [[ $DISK_AVAIL -lt 5120 ]]; then
        warning "磁盘空间不足 5GB (${DISK_AVAIL}MB)"
    else
        info "磁盘空间检查通过: ${DISK_AVAIL}MB 可用"
    fi
}

# 安装基础依赖
install_dependencies() {
    info "安装基础依赖..."

    apt-get update
    apt-get install -y \
        curl \
        wget \
        git \
        vim \
        nginx \
        ufw \
        net-tools \
        jq \
        htop

    success "基础依赖安装完成"
}

# 检查并安装 Docker
install_docker() {
    info "检查 Docker..."

    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        success "Docker 已安装: $DOCKER_VERSION"
    else
        info "安装 Docker..."
        curl -fsSL https://get.docker.com | bash
        systemctl enable docker
        systemctl start docker
        success "Docker 安装完成"
    fi

    # 检查 Docker Compose
    if command -v docker-compose &> /dev/null; then
        success "Docker Compose 已安装"
    else
        info "安装 Docker Compose..."
        apt-get install -y docker-compose-plugin || {
            # 备用安装方式
            DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
            curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        }
        success "Docker Compose 安装完成"
    fi
}

# 克隆代码
clone_code() {
    info "克隆 Paperplane 代码..."

    if [[ -d "$PAPERPLANE_DIR" ]]; then
        warning "目录 $PAPERPLANE_DIR 已存在"
        read -p "是否删除重新克隆? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PAPERPLANE_DIR"
        else
            info "使用现有代码，执行 git pull..."
            cd "$PAPERPLANE_DIR"
            git pull
            return
        fi
    fi

    # 尝试 GitHub，如果失败使用镜像
    info "尝试从 GitHub 克隆..."
    if git clone https://github.com/paperplaneai/paperplane.git "$PAPERPLANE_DIR" 2>/dev/null; then
        success "代码克隆完成"
    else
        warning "GitHub 访问失败，尝试镜像..."
        git clone https://ghproxy.com/https://github.com/paperplaneai/paperplane.git "$PAPERPLANE_DIR"
        success "代码从镜像克隆完成"
    fi
}

# 创建数据目录
setup_directories() {
    info "创建数据目录..."

    mkdir -p "$DATA_DIR"/instances/default
    mkdir -p "$LOG_DIR"
    chmod 755 "$DATA_DIR"

    success "数据目录创建完成: $DATA_DIR"
}

# 创建 Docker Compose 配置
create_docker_compose() {
    info "创建 Docker Compose 配置..."

    cat > "$PAPERPLANE_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  paperplane:
    build:
      context: .
      dockerfile: Dockerfile
    image: paperplane:latest
    container_name: paperplane
    restart: unless-stopped
    ports:
      - "3100:3100"
    volumes:
      - /paperplane:/paperplane
    environment:
      - NODE_ENV=production
      - HOST=0.0.0.0
      - PORT=3100
      - SERVE_UI=true
      - PAPERPLANE_HOME=/paperplane
      - PAPERPLANE_INSTANCE_ID=default
      - PAPERPLANE_DEPLOYMENT_MODE=authenticated
      - PAPERPLANE_DEPLOYMENT_EXPOSURE=public
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3100/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "5"
EOF

    success "Docker Compose 配置创建完成"
}

# 构建并启动容器
build_and_start() {
    info "构建 Docker 镜像..."

    cd "$PAPERPLANE_DIR"

    # 构建镜像
    docker compose build --no-cache

    success "镜像构建完成"

    # 启动服务
    info "启动 Paperplane 服务..."
    docker compose up -d

    # 等待服务启动
    info "等待服务启动..."
    sleep 10

    # 检查健康状态
    if docker compose ps | grep -q "healthy"; then
        success "Paperplane 服务启动成功"
    else
        warning "服务状态未知，请检查日志: docker compose logs"
    fi
}

# 配置 Nginx
setup_nginx() {
    info "配置 Nginx..."

    # 删除默认配置
    rm -f /etc/nginx/sites-enabled/default

    # 创建 Paperplane 配置
    cat > "$NGINX_CONFIG" << 'EOF'
server {
    listen 80;
    server_name _;

    client_max_body_size 50M;

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        proxy_pass http://127.0.0.1:3100;
        proxy_http_version 1.1;

        # WebSocket 支持
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # 代理头
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 日志
    access_log /var/log/nginx/paperplane-access.log;
    error_log /var/log/nginx/paperplane-error.log;
}
EOF

    # 启用配置
    ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/

    # 测试配置
    if nginx -t; then
        success "Nginx 配置测试通过"
    else
        error "Nginx 配置测试失败"
    fi

    # 重启 Nginx
    systemctl restart nginx
    systemctl enable nginx

    success "Nginx 配置完成"
}

# 配置防火墙
setup_firewall() {
    info "配置防火墙..."

    # 配置 UFW
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 3100/tcp

    # 启用防火墙（非交互式）
    echo "y" | ufw enable

    success "防火墙配置完成"
    ufw status
}

# 健康检查
health_check() {
    info "执行健康检查..."

    # 等待服务完全启动
    sleep 5

    # 检查容器状态
    if docker compose -f "$PAPERPLANE_DIR/docker-compose.yml" ps | grep -q "Up"; then
        success "Docker 容器运行正常"
    else
        error "Docker 容器未正常运行"
    fi

    # 检查端口
    if netstat -tlnp | grep -q ":3100"; then
        success "端口 3100 监听正常"
    else
        error "端口 3100 未监听"
    fi

    # 检查 HTTP 响应
    if curl -s http://127.0.0.1:3100/api/health > /dev/null; then
        success "Paperplane API 响应正常"
    else
        warning "Paperplane API 暂时无响应，可能需要等待更长时间"
    fi

    # 检查 Nginx
    if systemctl is-active --quiet nginx; then
        success "Nginx 运行正常"
    else
        error "Nginx 未运行"
    fi
}

# 显示完成信息
show_completion() {
    SERVER_IP=$(curl -s http://metadata.tencentyun.com/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "你的服务器IP")

    echo
    echo "=========================================="
    echo -e "${GREEN}Paperplane 部署完成!${NC}"
    echo "=========================================="
    echo
    echo "访问地址:"
    echo "  HTTP:   http://$SERVER_IP"
    echo "  端口:   http://$SERVER_IP:3100"
    echo
    echo "管理命令:"
    echo "  查看日志:   docker compose -f $PAPERPLANE_DIR/docker-compose.yml logs -f"
    echo "  重启服务:   docker compose -f $PAPERPLANE_DIR/docker-compose.yml restart"
    echo "  停止服务:   docker compose -f $PAPERPLANE_DIR/docker-compose.yml down"
    echo "  更新代码:   cd $PAPERPLANE_DIR && git pull && docker compose up -d --build"
    echo
    echo "数据目录: $DATA_DIR"
    echo "日志目录: $LOG_DIR"
    echo
    echo "=========================================="
    echo -e "${YELLOW}请确保在腾讯云控制台放行 80 和 443 端口!${NC}"
    echo "=========================================="
}

# 主函数
main() {
    echo "=========================================="
    echo " Paperplane 腾讯云 Docker 一键部署脚本"
    echo "=========================================="
    echo

    check_root
    check_system

    info "开始部署..."

    install_dependencies
    install_docker
    clone_code
    setup_directories
    create_docker_compose
    build_and_start
    setup_nginx
    setup_firewall
    health_check

    show_completion
}

# 执行主函数
main "$@"
