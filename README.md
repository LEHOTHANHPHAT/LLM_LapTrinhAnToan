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
