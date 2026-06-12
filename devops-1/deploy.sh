#!/usr/bin/env bash
# =============================================================
#  deploy.sh — Triển khai DevOps Training App lên Ubuntu server
#  Chạy với: sudo bash deploy.sh
# =============================================================
set -euo pipefail

APP_DIR="/opt/devops-training-app"
APP_USER="devops"
BACKEND_PORT="3000"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ─── Kiểm tra chạy với quyền root ───────────────────────────
[[ $EUID -ne 0 ]] && error "Vui lòng chạy script với sudo hoặc root"

# ─── Bước 1: Cài đặt dependencies ───────────────────────────
info "Cập nhật package list..."
apt-get update -qq

info "Cài đặt Python 3 + pip + venv..."
apt-get install -y python3 python3-pip python3-venv
python3 --version

info "Cài đặt Docker & Docker Compose..."
if ! command -v docker &>/dev/null; then
    apt-get install -y ca-certificates curl gnupg lsb-release
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update -qq
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    systemctl enable --now docker
fi
docker --version

info "Cài đặt Nginx..."
if ! command -v nginx &>/dev/null; then
    apt-get install -y nginx
    systemctl enable nginx
fi

# ─── Bước 2: Tạo user hệ thống ──────────────────────────────
if ! id "$APP_USER" &>/dev/null; then
    info "Tạo user '$APP_USER'..."
    useradd -r -s /bin/bash -m -d /home/$APP_USER $APP_USER
    usermod -aG docker $APP_USER
fi

# ─── Bước 3: Sao chép source code ───────────────────────────
info "Sao chép source code vào $APP_DIR..."
mkdir -p $APP_DIR
cp -r "$(dirname "$0")/." $APP_DIR/
chown -R $APP_USER:$APP_USER $APP_DIR

# ─── Bước 4: Cấu hình môi trường backend ────────────────────
info "Cấu hình file .env cho backend..."
ENV_FILE="$APP_DIR/backend/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    cp "$APP_DIR/backend/.env.example" "$ENV_FILE"
    warn "Đã tạo $ENV_FILE từ .env.example — kiểm tra lại thông tin DB nếu cần"
fi

# ─── Bước 5: Khởi động PostgreSQL qua Docker Compose ────────
info "Khởi động PostgreSQL (Docker Compose)..."
cd $APP_DIR
docker compose up -d --wait
info "PostgreSQL đang chạy!"

# Chờ DB sẵn sàng
info "Chờ PostgreSQL khởi động hoàn toàn..."
for i in {1..15}; do
    if docker exec devops_training_db pg_isready -U devops_user -d devops_training &>/dev/null; then
        info "PostgreSQL ready!"
        break
    fi
    echo -n "."
    sleep 2
done

# ─── Bước 6: Tạo virtualenv và cài Python dependencies ──────
info "Tạo Python virtualenv và cài packages..."
python3 -m venv $APP_DIR/venv
$APP_DIR/venv/bin/pip install --upgrade pip -q
$APP_DIR/venv/bin/pip install -r $APP_DIR/backend/requirements.txt -q
chown -R $APP_USER:$APP_USER $APP_DIR/venv

# ─── Bước 7: Cài đặt systemd service ────────────────────────
info "Cài đặt systemd service..."
cp $APP_DIR/systemd/devops-backend.service /etc/systemd/system/devops-backend.service
systemctl daemon-reload
systemctl enable devops-backend
systemctl restart devops-backend

sleep 3
if systemctl is-active --quiet devops-backend; then
    info "Service devops-backend đang chạy!"
else
    error "Service devops-backend không khởi động được. Kiểm tra: journalctl -u devops-backend -n 50"
fi

# ─── Bước 8: Cấu hình Nginx ─────────────────────────────────
info "Cấu hình Nginx..."
cp $APP_DIR/nginx/devops-training.conf /etc/nginx/sites-available/devops-training.conf

# Bật site, tắt default
ln -sf /etc/nginx/sites-available/devops-training.conf /etc/nginx/sites-enabled/devops-training.conf
rm -f /etc/nginx/sites-enabled/default

# Test cấu hình Nginx
nginx -t && systemctl reload nginx
info "Nginx đã được cấu hình và reload!"

# ─── Bước 9: Mở firewall ────────────────────────────────────
if command -v ufw &>/dev/null; then
    info "Mở port trên UFW firewall..."
    ufw allow 80/tcp comment "HTTP DevOps Training"
    ufw allow 443/tcp comment "HTTPS DevOps Training"
    ufw allow OpenSSH
    ufw --force enable
fi

# ─── Tóm tắt ────────────────────────────────────────────────
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        TRIỂN KHAI THÀNH CÔNG! 🚀                 ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  Frontend :  http://${SERVER_IP}                   "
echo -e "${GREEN}║${NC}  Backend  :  http://${SERVER_IP}/api/health        "
echo -e "${GREEN}║${NC}  App dir  :  ${APP_DIR}                            "
echo -e "${GREEN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  Kiểm tra service backend:                        "
echo -e "${GREEN}║${NC}    systemctl status devops-backend                 "
echo -e "${GREEN}║${NC}  Xem log backend:                                  "
echo -e "${GREEN}║${NC}    journalctl -u devops-backend -f                 "
echo -e "${GREEN}║${NC}  Xem log DB:                                       "
echo -e "${GREEN}║${NC}    docker logs devops_training_db -f               "
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
