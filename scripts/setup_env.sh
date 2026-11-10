#!/usr/bin/env bash
set -e

echo "============================================================"
echo "  THIẾT LẬP MÔI TRƯỜNG ĐỒ ÁN: LLM-DRIVEN SECURE CODE GEN    "
echo "============================================================"

# 1. Kiểm tra Python 3
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Chưa cài đặt python3. Vui lòng cài đặt Python 3.10+ trước."
    exit 1
fi

# 2. Tạo Virtual Environment (.venv)
if [ ! -d ".venv" ]; then
    echo "[1/4] Đang khởi tạo môi trường ảo Python (.venv)..."
    python3 -m venv .venv
else
    echo "[1/4] Đã tìm thấy môi trường ảo .venv."
fi

# Kích hoạt .venv
source .venv/bin/activate

# 3. Cài đặt thư viện Python
echo "[2/4] Đang cập nhật pip và cài đặt thư viện từ requirements.txt..."
pip install --upgrade pip
pip install -r requirements.txt

# 4. Tạo file .env nếu chưa có
if [ ! -f ".env" ]; then
    echo "[3/4] Đang khởi tạo file .env từ .env.example..."
    cp .env.example .env
else
    echo "[3/4] File .env đã tồn tại."
fi

# 5. Tải CodeQL CLI (nếu truyền cờ --with-codeql)
if [[ "$1" == "--with-codeql" ]]; then
    echo "[4/4] Đang tải và cài đặt CodeQL CLI Bundle vào ./.tools/codeql ..."
    mkdir -p .tools
    CODEQL_BUNDLE_URL="https://github.com/github/codeql-action/releases/latest/download/codeql-bundle-linux64.tar.gz"
    curl -L "$CODEQL_BUNDLE_URL" -o .tools/codeql-bundle.tar.gz
    tar -xzf .tools/codeql-bundle.tar.gz -C .tools/
    rm -f .tools/codeql-bundle.tar.gz
    echo "Đã cài đặt CodeQL CLI tại: $(pwd)/.tools/codeql/codeql"
else
    echo "[4/4] Bỏ qua bước tải tự động CodeQL Bundle (chạy './scripts/setup_env.sh --with-codeql' nếu muốn tải tự động ~500MB)."
fi

echo "============================================================"
echo "  HOÀN TẤT! Chạy lệnh sau để kích hoạt môi trường:          "
echo "  source .venv/bin/activate && bash scripts/verify_env.sh   "
echo "============================================================"
