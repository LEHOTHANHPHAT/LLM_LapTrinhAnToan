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
