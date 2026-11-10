# Guiding AI to Fix Its Own Flaws: An Empirical Study on LLM-Driven Secure Code Generation

Repository đồ án tái hiện thực nghiệm và mở rộng bài báo **"Guiding AI to Fix Its Own Flaws: An Empirical Study on LLM-Driven Secure Code Generation"** (*ACM Transactions on Software Engineering and Methodology*).

---

## 1. Sơ đồ


---

## 2. Hướng dẫn Cài đặt Môi trường (Chỉ chạy 1 lệnh)

### Cách 1: Cài đặt trực tiếp trên Ubuntu / WSL2 (Khuyên dùng khi phát triển)

```bash
git clone <URL_REPO_GITHUB_CUA_BAN>
cd llm-secure-code-generation
bash scripts/setup_env.sh --with-codeql
- Kích hoạt môi trường và kiểm tra:
source .venv/bin/activate
bash scripts/verify_env.sh
- Tạo .env