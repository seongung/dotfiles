#!/usr/bin/env bash
set -euo pipefail

echo "[tmux] installing tmux config..."

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SRC="${DOTFILES_DIR}/tmux"

if [ ! -d "${TMUX_SRC}" ]; then
  echo "[tmux] ERROR: ${TMUX_SRC} 디렉터리가 없습니다."
  exit 1
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
DEST_DIR="${CONFIG_HOME}/tmux"

mkdir -p "${CONFIG_HOME}"

# 기존 설정 백업 + symlink 생성
if [ -L "${DEST_DIR}" ] || [ -d "${DEST_DIR}" ]; then
  if [ "$(readlink "${DEST_DIR}" 2>/dev/null || true)" = "${TMUX_SRC}" ]; then
    echo "[tmux] 이미 ${DEST_DIR} -> ${TMUX_SRC} 로 링크되어 있습니다. (skip)"
  else
    BACKUP="${DEST_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
    echo "[tmux] 기존 ${DEST_DIR} 백업: ${BACKUP}"
    mv "${DEST_DIR}" "${BACKUP}"
    ln -s "${TMUX_SRC}" "${DEST_DIR}"
    echo "[tmux] 새 tmux config 링크 생성: ${DEST_DIR} -> ${TMUX_SRC}"
  fi
else
  ln -s "${TMUX_SRC}" "${DEST_DIR}"
  echo "[tmux] tmux config 링크 생성: ${DEST_DIR} -> ${TMUX_SRC}"
fi

########################################
# tpm 설치 (플러그인 설치는 tmux 안에서 C-b I)
########################################
if command -v tmux >/dev/null 2>&1; then
  PLUGINS_DIR="${DEST_DIR}/plugins"
  TPM_DIR="${PLUGINS_DIR}/tpm"

  if [ ! -d "${TPM_DIR}" ]; then
    echo "[tmux] tpm 설치 중..."
    mkdir -p "${PLUGINS_DIR}"
    if command -v git >/dev/null 2>&1; then
      git clone --depth=1 https://github.com/tmux-plugins/tpm "${TPM_DIR}"
      echo "[tmux] tpm 설치 완료. tmux 안에서 C-b I 를 눌러 플러그인을 설치하세요."
    else
      echo "[tmux] 경고: git 이 없어서 tpm을 클론하지 못했습니다."
      echo "       나중에 git 설치 후 수동으로 클론하거나, tmux 안에서 C-b I 를 눌러 설치하세요."
    fi
  else
    echo "[tmux] tpm 이미 설치됨. (skip)"
  fi
else
  echo "[tmux] 경고: tmux 명령을 찾지 못했습니다. tmux 설치 후 사용하세요."
fi

########################################
# yq 설치 (tmux-nerd-font-window-name 등에서 사용)
########################################
if command -v yq >/dev/null 2>&1; then
  echo "[tmux] yq 이미 설치됨. (skip)"
else
  echo "[tmux] yq 가 설치되어 있지 않습니다. 설치를 시도합니다..."

  OS="$(uname -s)"
  ARCH="$(uname -m)"

  # root 권한 또는 sudo 여부 확인
  SUDO=""
  if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  fi

  if [ "$OS" = "Linux" ] && command -v apt-get >/dev/null 2>&1; then
    echo "[tmux] apt-get 으로 yq 설치..."
    $SUDO apt-get update -y || true
    if $SUDO apt-get install -y yq; then
      echo "[tmux] yq 설치 완료 (apt-get)."
    else
      echo "[tmux] 경고: apt-get 으로 yq 설치 실패."
    fi
  elif [ "$OS" = "Linux" ] && command -v wget >/dev/null 2>&1; then
    echo "[tmux] GitHub 바이너리로 yq 설치..."
    YQ_BIN="/usr/local/bin/yq"
    URL=""
    case "$ARCH" in
      x86_64|amd64) URL="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" ;;
      aarch64|arm64) URL="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64" ;;
      *)
        echo "[tmux] 경고: 아키텍처($ARCH)에 대한 yq 바이너리 URL을 알 수 없습니다. 수동 설치가 필요합니다."
        URL=""
        ;;
    esac

    if [ -n "$URL" ]; then
      if $SUDO wget -qO "$YQ_BIN" "$URL" && $SUDO chmod +x "$YQ_BIN"; then
        echo "[tmux] yq 설치 완료 ($YQ_BIN)."
      else
        echo "[tmux] 경고: yq 바이너리 다운로드/설치 실패. 나중에 수동으로 설치하세요."
      fi
    fi
  elif [ "$OS" = "Darwin" ]; then
    echo "[tmux] macOS 환경입니다. Homebrew가 있다면 다음으로 yq 를 설치하세요:"
    echo "       brew install yq"
  else
    echo "[tmux] 경고: yq 자동 설치 방법을 알 수 없습니다. 수동 설치가 필요합니다."
  fi
fi

echo "[tmux] 완료! 이제 'tmux' 를 실행한 다음, 세션 안에서 C-b I 로 플러그인을 설치하면 됩니다."
