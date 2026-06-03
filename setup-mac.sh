#!/bin/bash
# Salvium + XMRig 一键部署 (macOS ARM64)
set -euo pipefail

XMRIG_VERSION="6.26.0"
INSTALL_DIR="${HOME}/salvium-mining/xmrig"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POOL_URL="${POOL_URL:-sal-sg.kryptex.network:7028}"

echo "=== Salvium 挖矿部署 (macOS) ==="
echo ""

# 钱包地址
if [[ -n "${SC1_WALLET:-}" ]]; then
  WALLET="$SC1_WALLET"
else
  read -r -p "粘贴 SC1 钱包地址: " WALLET
fi
WALLET="$(echo "$WALLET" | tr -d '[:space:]')"

if [[ ! "$WALLET" =~ ^SC1 ]]; then
  echo "错误: 地址必须以 SC1 开头（Salvium Carrot 地址）"
  exit 1
fi

# 矿工名（默认本机名，方便多机区分）
DEFAULT_WORKER="$(scutil --get ComputerName 2>/dev/null | tr ' ' '-' | tr -cd '[:alnum:]._-' || hostname -s)"
if [[ -n "${WORKER_NAME:-}" ]]; then
  WORKER="$WORKER_NAME"
else
  read -r -p "矿工名 [默认: ${DEFAULT_WORKER}]: " WORKER
  WORKER="${WORKER:-$DEFAULT_WORKER}"
fi
WORKER="$(echo "$WORKER" | tr -cd '[:alnum:]._-')"

# 线程数（M4 10 核默认 8）
if [[ -n "${RX_THREADS:-}" ]]; then
  THREADS="$RX_THREADS"
else
  CORES="$(sysctl -n hw.ncpu 2>/dev/null || echo 8)"
  DEFAULT_THREADS=$((CORES > 2 ? CORES - 2 : 1))
  read -r -p "CPU 线程数 [默认: ${DEFAULT_THREADS}]: " THREADS
  THREADS="${THREADS:-$DEFAULT_THREADS}"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 下载 XMRig（仅 Apple Silicon；Intel Mac 需改 github 上的 x64 包名）
ARCH="$(uname -m)"
if [[ "$ARCH" != "arm64" ]]; then
  echo "当前为 ${ARCH}，请从 https://github.com/xmrig/xmrig/releases 下载 macOS x64 包并解压到:"
  echo "  ${INSTALL_DIR}"
  read -r -p "解压完成后按回车继续..."
else
  TGZ="xmrig-${XMRIG_VERSION}-macos-arm64.tar.gz"
  URL="https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/${TGZ}"
  if [[ ! -x "${INSTALL_DIR}/xmrig-${XMRIG_VERSION}/xmrig" ]]; then
    echo "下载 XMRig ${XMRIG_VERSION} ..."
    curl -fsSL -o "$TGZ" "$URL"
    tar xzf "$TGZ"
    rm -f "$TGZ"
  fi
  ln -sfn "xmrig-${XMRIG_VERSION}" current
fi

XMRIG_BIN="${INSTALL_DIR}/current/xmrig"
if [[ ! -x "$XMRIG_BIN" ]]; then
  XMRIG_BIN="$(find "$INSTALL_DIR" -maxdepth 2 -name xmrig -perm +111 2>/dev/null | head -1)"
fi
[[ -x "$XMRIG_BIN" ]] || { echo "未找到 xmrig 可执行文件"; exit 1; }

# 生成 rx 线程数组 JSON
RX_JSON="["
for ((i = 0; i < THREADS; i++)); do
  [[ $i -gt 0 ]] && RX_JSON+=", "
  RX_JSON+="$i"
done
RX_JSON+="]"

# 写入 config.json
sed -e "s|SC1_WALLET_PLACEHOLDER|${WALLET}|g" \
    -e "s|WORKER_PLACEHOLDER|${WORKER}|g" \
    "${SCRIPT_DIR}/config.template.json" > "${INSTALL_DIR}/current/config.json"

# 用 python 改 rx 数组（macOS 自带 python3）
python3 - "$INSTALL_DIR/current/config.json" "$RX_JSON" <<'PY'
import json, sys
path, rx = sys.argv[1], json.loads(sys.argv[2])
with open(path) as f:
    cfg = json.load(f)
cfg.setdefault("cpu", {})["rx"] = rx
with open(path, "w") as f:
    json.dump(cfg, f, indent=4)
PY

# 启动脚本
cat > "${INSTALL_DIR}/start.sh" <<EOF
#!/bin/bash
cd "${INSTALL_DIR}/current"
exec ./xmrig --config=config.json
EOF

cat > "${INSTALL_DIR}/start-background.sh" <<EOF
#!/bin/bash
cd "${INSTALL_DIR}/current"
nohup ./xmrig --config=config.json >> xmrig.log 2>&1 &
echo "已后台启动 PID \$!"
echo "日志: ${INSTALL_DIR}/current/xmrig.log"
EOF

cat > "${INSTALL_DIR}/stop.sh" <<EOF
#!/bin/bash
pkill -f "${INSTALL_DIR}/current/xmrig" 2>/dev/null && echo "已停止" || echo "未在运行"
EOF

chmod +x "${INSTALL_DIR}/start.sh" "${INSTALL_DIR}/start-background.sh" "${INSTALL_DIR}/stop.sh"

echo ""
echo "=== 部署完成 ==="
echo "  目录:   ${INSTALL_DIR}/current"
echo "  矿池:   ${POOL_URL}"
echo "  账户:   ${WALLET}/${WORKER}"
echo "  线程:   ${THREADS}"
echo ""
echo "  前台挖矿:  ${INSTALL_DIR}/start.sh"
echo "  后台挖矿:  ${INSTALL_DIR}/start-background.sh"
echo "  停止:      ${INSTALL_DIR}/stop.sh"
echo ""

read -r -p "是否现在启动挖矿? [y/N]: " GO
if [[ "${GO,,}" == "y" ]]; then
  exec "${INSTALL_DIR}/start.sh"
fi
