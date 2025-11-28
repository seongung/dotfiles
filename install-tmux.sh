#!/usr/bin/env bash
set -euo pipefail

echo "[tmux] installing tmux config..."

# 이 스크립트가 있는 디렉터리 = dotfiles 루트
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TMUX_SRC="${DOTFILES_DIR}/tmux"

if [ ! -d "${TMUX_SRC}" ]; then
  echo "[tmux] ERROR: ${TMUX_SRC} 디렉터리가 없습니다."
  echo "       ~/dotfiles/tmux 안에 tmux.conf 등이 있어야 해요."
  exit 1
fi

# XDG_CONFIG_HOME 이 있으면 그걸 쓰고, 없으면 ~/.config 사용
CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
DEST_DIR="${CONFIG_HOME}/tmux"

mkdir -p "${CONFIG_HOME}"

# 기존 설정 백업 + symlink 생성
if [ -L "${DEST_DIR}" ] || [ -d "${DEST_DIR}" ]; then
  # 이미 우리가 만든 링크면 그대로 둠
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

# tmux plugin manager (tpm) 설치 (있으면 skip)
if command -v tmux >/dev/null 2>&1; then
  PLUGINS_DIR="${DEST_DIR}/plugins"
  TPM_DIR="${PLUGINS_DIR}/tpm"

  if [ ! -d "${TPM_DIR}" ]; then
    echo "[tmux] tpm 설치 중..."
    mkdir -p "${PLUGINS_DIR}"
    if command -v git >/dev/null 2>&1; then
      git clone --depth=1 https://github.com/tmux-plugins/tpm "${TPM_DIR}"
    else
      echo "[tmux] 경고: git 이 없어서 tpm을 클론하지 못했습니다."
      echo "       나중에 git 설치 후 수동으로 클론하거나, tmux 안에서 C-b I 를 눌러 설치하세요."
    fi
  else
    echo "[tmux] tpm 이미 설치됨. (skip)"
  fi

  # 플러그인 설치 시도 (실패해도 tmux 자체 설치는 완료된 것이므로 에러 무시)
  if [ -x "${TPM_DIR}/bin/install_plugins" ]; then
    echo "[tmux] tpm 플러그인 설치 중..."
    "${TPM_DIR}/bin/install_plugins" || echo "[tmux] 플러그인 설치 중 일부 실패 (무시 가능)"
  else
    echo "[tmux] tpm/bin/install_plugins 를 찾지 못했습니다. 나중에 tmux 안에서 C-b I 로 설치하세요."
  fi
else
  echo "[tmux] 경고: tmux 명령을 찾지 못했습니다. tmux 설치 후 다시 실행하거나,"
  echo "       나중에 tmux 안에서 C-b I 로 플러그인을 설치하면 됩니다."
fi

echo "[tmux] 완료! 이제 'tmux' 를 실행해서 테마/설정이 잘 적용됐는지 확인해보세요."
