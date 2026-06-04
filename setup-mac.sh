#!/bin/bash
# Salvium + XMRig 一键部署 (macOS ARM64)
set -euo pipefail

XMRIG_VERSION="6.26.0"
INSTALL_DIR="${HOME}/salvium-mining/xmrig"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POOL_URL="${POOL_URL:-sal-sg.kryptex.network:7028}"

GREEN='\033[0;32m'
NC='\033[0m'

# curl | bash 时 stdin 不是终端，必须从 /dev/tty 读入
read_prompt() {
  local prompt="$1"
  local value=""
  if [[ -t 0 ]]; then
    printf '%b' "$prompt"
    read -r value
  elif [[ -e /dev/tty ]]; then
    printf '%b' "$prompt" >/dev/tty
    read -r value </dev/tty
  else
    echo "错误: 无法交互输入。请改用:" >&2
    echo "  SC1_WALLET='SC1你的地址' curl -fsSL .../install.sh | bash" >&2
    exit 1
  fi
  printf '%s' "$value"
}

echo "=== Salvium 挖矿部署 (macOS) ==="
echo ""

# 钱包地址
if [[ -n "${SC1_WALLET:-}" ]]; then
  WALLET="$SC1_WALLET"
else
  WALLET="$(read_prompt "${GREEN}SC1 钱包地址${NC}: ")"
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
  WORKER="$(read_prompt "矿工名 [默认: ${GREEN}${DEFAULT_WORKER}${NC}]: ")"
  WORKER="${WORKER:-$DEFAULT_WORKER}"
fi
WORKER="$(echo "$WORKER" | tr -cd '[:alnum:]._-')"

# 线程数（M4 10 核默认 8）
if [[ -n "${RX_THREADS:-}" ]]; then
  THREADS="$RX_THREADS"
else
  CORES="$(sysctl -n hw.ncpu 2>/dev/null || echo 8)"
  DEFAULT_THREADS=$((CORES > 2 ? CORES - 2 : 1))
  THREADS="$(read_prompt "CPU 线程数 [默认: ${GREEN}${DEFAULT_THREADS}${NC}]: ")"
  THREADS="${THREADS:-$DEFAULT_THREADS}"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 下载 XMRig（仅 Apple Silicon；Intel Mac 需改 github 上的 x64 包名）
ARCH="$(uname -m)"
if [[ "$ARCH" != "arm64" ]]; then
  echo "当前为 ${ARCH}，请从 https://github.com/xmrig/xmrig/releases 下载 macOS x64 包并解压到:"
  echo "  ${INSTALL_DIR}"
  read_prompt "解压完成后按回车继续… " >/dev/null
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
echo "正在启动前台挖矿…"
exec "${INSTALL_DIR}/start.sh"
