#!/bin/bash

set -euo pipefail

# ==============================
# 🎨 颜色输出
# ==============================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ==============================
# 📝 日志函数
# ==============================
info()    { echo -e "${GREEN}✅ $*${NC}"; }
warn()    { echo -e "${YELLOW}🔧 $*${NC}"; }
error()   { echo -e "${RED}❌ $*${NC}" >&2; }
section() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n${BLUE}  $*${NC}\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ==============================
# 🚨 错误捕获
# ==============================
trap 'error "脚本在第 $LINENO 行发生错误，退出码: $?"' ERR

# ==============================
# ⏱ 计时开始
# ==============================
START_TIME=$(date +%s)

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  🚀 Mac 开发环境一键初始化脚本${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# ==============================
# 🍺 安装 Homebrew
# ==============================
section "🍺 Homebrew"

if ! command -v brew &>/dev/null; then
  warn "Homebrew 未安装，开始安装..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon 与 Intel 兼容路径配置
#  if [[ -f /opt/homebrew/bin/brew ]]; then
#    eval "$(/opt/homebrew/bin/brew shellenv)"
#    grep -qxF 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile \
#      || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
#  elif [[ -f /usr/local/bin/brew ]]; then
#    eval "$(/usr/local/bin/brew shellenv)"
#  fi

  info "Homebrew 安装完成"
else
  info "Homebrew 已安装 ($(brew --version | head -1))"
fi

# ==============================
# 🔄 更新 Homebrew
# ==============================
section "🔄 更新 Homebrew"
brew update && info "Homebrew 更新完成"

# ==============================
# 🔧 CLI 安装函数
# ==============================
# 支持 "cmd:pkg" 格式指定不同的安装包名，如 "fd:fd"
install_cli() {
  local entry=$1
  local cmd="${entry%%:*}"
  local pkg="${entry##*:}"

  if ! command -v "$cmd" &>/dev/null; then
    warn "安装 $pkg ..."
    brew install "$pkg"
    info "$cmd 安装完成"
  else
    info "$cmd 已存在 ($(command -v "$cmd"))"
  fi
}

# ==============================
# 🖥 GUI 安装函数（cask）
# ==============================
install_cask() {
  local app=$1

  if brew list --cask "$app" &>/dev/null 2>&1; then
    info "$app 已安装"
  else
    warn "安装 $app ..."
    brew install --cask "$app"
    info "$app 安装完成"
  fi
}

# ==============================
# 📦 CLI 工具列表
# 格式: "命令名" 或 "命令名:brew包名"（命令与包名不同时使用）
# ==============================
CLI_TOOLS=(
  git
  make
  wget
  curl
  jq
  bat
  uv
)

section "📦 CLI 工具"
for tool in "${CLI_TOOLS[@]}"; do
  install_cli "$tool"
done

# ==============================
# 🖥 GUI 工具
# ==============================
section "🖥 GUI 工具"

CASK_APPS=(
#  docker
#  iterm2
#  visual-studio-code
)

for app in "${CASK_APPS[@]+"${CASK_APPS[@]}"}"; do
  # 跳过注释行
  [[ "$app" =~ ^#.*$ ]] && continue
  install_cask "$app"
done

# ==============================
# ⏱ 耗时统计
# ==============================
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

# ==============================
# 🎉 完成
# ==============================
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  🎉 开发环境初始化完成！（耗时 ${ELAPSED}s）${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
