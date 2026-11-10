#!/usr/bin/env bash
set -e

echo "=== KIỂM TRA TRẠNG THÁI MÔI TRƯỜNG ==="
echo -n "1. Python version: "
python3 --version

echo -n "2. Bandit SAST CLI: "
if command -v bandit &> /dev/null; then
    bandit --version | head -n 1
else
    echo "Chưa kích hoạt .venv hoặc chưa cài đặt."
fi

echo -n "3. Semgrep SAST CLI: "
if command -v semgrep &> /dev/null; then
    semgrep --version
else
    echo "Chưa kích hoạt .venv hoặc chưa cài đặt."
fi

echo -n "4. CodeQL CLI: "
if command -v codeql &> /dev/null; then
    codeql --version | head -n 1
elif [ -f "./.tools/codeql/codeql" ]; then
    ./.tools/codeql/codeql --version | head -n 1
else
    echo "Chưa tìm thấy trong PATH hoặc ./.tools/codeql (Chạy: bash scripts/setup_env.sh --with-codeql)"
fi
echo "======================================"
