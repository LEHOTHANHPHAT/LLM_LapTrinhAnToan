#!/usr/bin/env bash
set -e

REPO_NAME="LLM-secure-code-generation"
mkdir -p "LapTrinhAnToan"
cd "$LapTrinhAnToan"

echo "[1/6] Đang tạo cấu trúc thư mục..."
mkdir -p configs \
         data/benchmarks \
         data/knowledge_base \
         data/generated_code \
         data/sarif_reports \
         data/evaluation_results \
         scripts \
         src/tv1_llm_pipeline \
         src/tv2_sast_evaluation \
         src/app_demo \
         docs

# Tạo .gitkeep cho các thư mục dữ liệu trống
touch data/benchmarks/.gitkeep \
      data/knowledge_base/.gitkeep \
      data/generated_code/.gitkeep \
      data/sarif_reports/.gitkeep \
      data/evaluation_results/.gitkeep \
      docs/.gitkeep

echo "[2/6] Đang tạo các file khung (skeleton) rỗng cho TV1 và TV2..."
touch src/__init__.py \
      src/tv1_llm_pipeline/__init__.py \
      src/tv1_llm_pipeline/llm_client.py \
      src/tv1_llm_pipeline/post_processor.py \
      src/tv1_llm_pipeline/baseline_generator.py \
      src/tv1_llm_pipeline/proactive_hints.py \
      src/tv1_llm_pipeline/feedback_builder.py \
      src/tv1_llm_pipeline/rag_security_engine.py \
      src/tv2_sast_evaluation/__init__.py \
      src/tv2_sast_evaluation/dataset_loader.py \
      src/tv2_sast_evaluation/codeql_runner.py \
      src/tv2_sast_evaluation/sarif_parser_metrics.py \
      src/tv2_sast_evaluation/hint_judge.py \
      src/tv2_sast_evaluation/repair_loop_evaluator.py \
      src/tv2_sast_evaluation/multi_sast_runner.py \
      src/app_demo/__init__.py \
      src/app_demo/app.py

echo "[3/6] Đang tạo các file cấu hình (.gitignore, .env.example, YAML, requirements.txt)..."

cat << 'EOF' > .gitignore
# Môi trường ảo Python
.venv/
venv/
__pycache__/
*.py[cod]
*$py.class

# Biến môi trường & API Keys
.env

# Dữ liệu lớn, Database CodeQL và Kết quả sinh tự động
data/benchmarks/*
!data/benchmarks/.gitkeep
data/knowledge_base/*
!data/knowledge_base/.gitkeep
data/generated_code/*
!data/generated_code/.gitkeep
data/sarif_reports/*
!data/sarif_reports/.gitkeep
data/evaluation_results/*
!data/evaluation_results/.gitkeep
codeql_dbs/
*.db

# Công cụ CodeQL tải cục bộ
.tools/

# IDE & OS
.vscode/
.idea/
.DS_Store
EOF

cat << 'EOF' > .env.example
# ==========================================================
# CẤU HÌNH API KEYS CHO LLM INFERENCE & LLM-AS-A-JUDGE
# Copy file này thành .env và điền key thực tế: cp .env.example .env
# ==========================================================
OPENAI_API_KEY=your_openai_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
HF_TOKEN=your_huggingface_token_here

# Cấu hình Ollama / vLLM Local Server (nếu chạy local)
OLLAMA_BASE_URL=http://localhost:11434
VLLM_BASE_URL=http://localhost:8000/v1

# Đường dẫn tới CodeQL CLI (mặc định trỏ vào thư mục .tools nếu cài qua script)
CODEQL_CLI_PATH=./.tools/codeql/codeql
EOF

cat << 'EOF' > requirements.txt
# --- Core & Environment ---
python-dotenv>=1.0.1
pyyaml>=6.0.1
tqdm>=4.66.0
pandas>=2.2.0
numpy>=1.26.0

# --- TV1: LLM Inference, Prompting & RAG (Tuần 1 - Tuần 5) ---
openai>=1.50.0
google-generativeai>=0.8.0
transformers>=4.44.0
accelerate>=0.33.0
huggingface-hub>=0.24.0
chromadb>=0.5.5
sentence-transformers>=3.0.0

# --- TV2: SAST Tools, SARIF Parsing & Visualization (Tuần 1 - Tuần 5) ---
bandit>=1.7.9
semgrep>=1.85.0
sarif-om>=1.0.4
jschema-to-python>=1.2.3
matplotlib>=3.9.0
seaborn>=0.13.2

# --- Web Demo UI (Tuần 6) ---
streamlit>=1.38.0
gradio>=4.44.0
EOF

cat << 'EOF' > configs/models_config.yaml
# Cấu hình tham số suy luận chuẩn theo bài báo gốc (Table 3)
generation_defaults:
  temperature_code: 0.0          # Dùng cho Code Generation & Repair
  temperature_hint: 0.7          # Dùng cho Hint Generation & Explained Feedback
  temperature_judge: 0.0         # Dùng cho LLM-as-a-Judge
  top_p: 1.0
  max_new_tokens_open: 2048
  max_new_tokens_api: 4096
  top_k_hints: 5

models:
  gpt-4o-mini:
    provider: openai
    model_name: gpt-4o-mini
  llama-3.1-8b:
    provider: ollama
    model_name: llama3.1:8b-instruct-fp16
  codellama-7b:
    provider: ollama
    model_name: codellama:7b-instruct
  qwen2.5-coder-7b:
    provider: ollama
    model_name: qwen2.5-coder:7b-instruct
EOF

cat << 'EOF' > configs/scanner_config.yaml
# Cấu hình công cụ phân tích tĩnh SAST (Dành cho TV2)
codeql:
  language: python
  query_suite: python-security-extended.qls
  output_format: sarif-latest

secondary_sast:
  enable_bandit: true
  enable_semgrep: true
  semgrep_ruleset: "p/python"
EOF

echo "[4/6] Đang tạo script cài đặt và kiểm tra môi trường (scripts/)..."

cat << 'EOF' > scripts/setup_env.sh
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
EOF

cat << 'EOF' > scripts/verify_env.sh
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
EOF

chmod +x scripts/setup_env.sh scripts/verify_env.sh

echo "[5/6] Đang tạo Dockerfile và docker-compose.yml..."

cat << 'EOF' > Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    curl wget git unzip tar \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt CodeQL CLI Bundle
RUN mkdir -p /opt/codeql && \
    curl -L "https://github.com/github/codeql-action/releases/latest/download/codeql-bundle-linux64.tar.gz" -o /tmp/codeql.tar.gz && \
    tar -xzf /tmp/codeql.tar.gz -C /opt/ && \
    rm -f /tmp/codeql.tar.gz

ENV PATH="/opt/codeql:${PATH}"

COPY requirements.txt .
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

COPY . .

CMD ["bash", "scripts/verify_env.sh"]
EOF

cat << 'EOF' > docker-compose.yml
services:
  sec-codegen-env:
    build: .
    container_name: llm_sec_codegen
    volumes:
      - .:/workspace
    env_file:
      - .env
    tty: true
EOF

echo "[6/6] Đang tạo file README.md..."

cat << 'EOF' > README.md
# Guiding AI to Fix Its Own Flaws: An Empirical Study on LLM-Driven Secure Code Generation

Repository đồ án tái hiện thực nghiệm và mở rộng bài báo **"Guiding AI to Fix Its Own Flaws: An Empirical Study on LLM-Driven Secure Code Generation"** (*ACM Transactions on Software Engineering and Methodology*).

---

## 1. Phân công nhiệm vụ & Khu vực làm việc (6 Tuần)

| Thành viên | Vai trò chính | Thư mục code phụ trách | Nội dung công việc trọng tâm |
| :--- | :--- | :--- | :--- |
| **Thành viên 1 (TV1)** | **LLM Inference, Prompting, RAG & Web UI** | `src/tv1_llm_pipeline/`<br>`src/app_demo/` | • Thiết lập LLM Inference (API / Ollama / vLLM).<br>• Pipeline sinh mã Baseline & hậu xử lý trích xuất code (Tuần 2).<br>• Pipeline RQ1: Self-Generated Vulnerability Hints & Oracle Hints (Tuần 3).<br>• Module chuyển đổi SARIF thành Direct / Explained / Self-Explained Feedback (Tuần 4).<br>• Cải tiến **RAG-Enhanced Security Hinting & Multi-turn Repair** (Tuần 5).<br>• Xây dựng Web Demo 4 Tab bằng Streamlit/Gradio (Tuần 6). |
| **Thành viên 2 (TV2)** | **SAST CodeQL, Multi-SAST & Evaluation** | `src/tv2_sast_evaluation/`<br>`Dockerfile` | • Chuẩn bị 3 bộ dữ liệu (`SecurityEval`, `SecCodePLT`, `CyberSecEval`) & cấu hình CodeQL CLI (Tuần 1).<br>• Tự động đóng gói CodeQL Database, xuất báo cáo SARIF & tính chỉ số **TarV-R**, **AllV-R** (Tuần 2).<br>• Module **LLM-as-a-Judge** chấm điểm Hint theo *Relevance* & *Preciseness* (Tuần 3).<br>• Đánh giá vòng lặp Post-hoc Repair, tính *Repair Rate* (Tuần 4).<br>• Thực nghiệm bổ sung trên mô hình mới & tích hợp **Bandit / Semgrep** song song với CodeQL (Tuần 5). |

---

## 2. Hướng dẫn Cài đặt Môi trường (Chỉ chạy 1 lệnh)

### Cách 1: Cài đặt trực tiếp trên Ubuntu / WSL2 (Khuyên dùng khi phát triển)

**Bước 1: Clone repository về máy**
```bash
git clone <URL_REPO_GITHUB_CUA_BAN>
cd llm-secure-code-generation
