#!/bin/zsh

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
# 📂 ZSH_CUSTOM 路径（自动推断）
# ==============================
ZSH_CUSTOM="${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}"

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  🚀 Oh My Zsh 插件安装脚本${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# ==============================
# 🐚 安装 Oh My Zsh
# ==============================
section "🐚 Oh My Zsh"

if [ ! -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  warn "Oh My Zsh 未安装，开始安装..."
  # chsh -s /bin/zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  info "Oh My Zsh 安装完成"

   # 提示 shell
    if [ "$SHELL" != "$(which zsh)" ]; then
      warn "当前 shell 不是 zsh，建议执行: chsh -s $(which zsh)"
    fi
else
  info "Oh My Zsh 已安装"
fi

# ==============================
# 🔌 插件安装函数
# ==============================
# 用法: install_plugin <显示名称> <仓库URL> <目标目录>
install_plugin() {
  local name="$1"
  local repo="$2"
  local dest="$3"

  if [ ! -d "$dest" ]; then
    warn "安装 $name ..."
    git clone --depth=1 "$repo" "$dest"
    info "$name 安装完成"
  else
    info "$name 已安装"
  fi
}

# ==============================
# 🍺 brew 工具安装函数
# ==============================
install_brew() {
  local cmd="$1"
  local pkg="${2:-$1}"

  if ! command -v "$cmd" &>/dev/null; then
    warn "安装 $pkg ..."
    brew install "$pkg"
    info "$cmd 安装完成"
  else
    info "$cmd 已存在 ($(command -v "$cmd"))"
  fi
}

# ==============================
# 🍺 Homebrew 工具
# ==============================
section "🍺 Homebrew 工具"

install_brew autojump
# 提示用法
echo -e "  ${BLUE}👉 autojump 用法: j <目录名>${NC}"
echo -e "  ${BLUE}👉 请在 .zshrc 的 plugins=(...) 中添加: autojump${NC}"

# ==============================
# 💻 VS Code
# ==============================
section "💻 VS Code"

if command -v code &>/dev/null; then
  info "VS Code 已安装 ($(command -v code))"
else
  warn "VS Code 未安装，请手动下载安装:"
  echo -e "  ${BLUE}👉 https://code.visualstudio.com/Download${NC}"
  echo -e "  ${BLUE}👉 安装后在 .zshrc plugins=(...) 中添加: vscode${NC}"
  echo -e "  ${BLUE}👉 插件文档: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/vscode${NC}"
fi

# ==============================
# 🔌 Oh My Zsh 插件
# ==============================
section "🔌 Oh My Zsh 插件"

install_plugin "git-open" \
  "https://github.com/paulirish/git-open.git" \
  "$ZSH_CUSTOM/plugins/git-open"
echo -e "  ${BLUE}👉 用法: git open${NC}"

install_plugin "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

install_plugin "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

install_plugin "zsh-completions" \
  "https://github.com/zsh-users/zsh-completions" \
  "$ZSH_CUSTOM/plugins/zsh-completions"

install_plugin "zsh-history-substring-search" \
  "https://github.com/zsh-users/zsh-history-substring-search.git" \
  "$ZSH_CUSTOM/plugins/zsh-history-substring-search"

# ==============================
# ⚙️ 自动更新 ~/.zshrc plugins
# ==============================
section "⚙️ 更新 ~/.zshrc plugins 配置"

ZSHRC="$HOME/.zshrc"
PLUGINS_LINE='plugins=(
	git
	autojump
	git-open
	vscode
	zsh-syntax-highlighting
	zsh-autosuggestions
	zsh-completions
	zsh-history-substring-search
	sublime
	tmux
)'

if [ -f "$ZSHRC" ]; then
  if grep -q "^plugins=" "$ZSHRC"; then
    # 替换已有的 plugins=(...) 单行或多行配置
    perl -i.bak -0pe 's/^plugins=\(.*?\)/'"$PLUGINS_LINE"'/ms' "$ZSHRC"
    info "~/.zshrc plugins 已更新"
  else
    echo "$PLUGINS_LINE" >> "$ZSHRC"
    info "~/.zshrc plugins 已追加"
  fi
  echo -e "  ${GREEN}${PLUGINS_LINE}${NC}"
else
  warn "未找到 ~/.zshrc，跳过自动配置"
fi

# ==============================
# 📋 最终提示
# ==============================
section "📋 后续配置"

echo -e "修改完成后执行: ${YELLOW}source ~/.zshrc${NC}"
echo ""
info "Oh My Zsh 插件安装完成 🎉"
