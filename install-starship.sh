#!/usr/bin/env bash
set -euo pipefail

echo "[starship] installing starship config..."

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STARSHIP_SRC="${DOTFILES_DIR}/starship/starship.toml"

if [ ! -f "${STARSHIP_SRC}" ]; then
  echo "[starship] ERROR: ${STARSHIP_SRC} 파일이 없습니다."
  exit 1
fi

CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
DEST_FILE="${CONFIG_HOME}/starship.toml"

mkdir -p "${CONFIG_HOME}"

# 기존 설정 백업 + symlink 생성
if [ -L "${DEST_FILE}" ] || [ -f "${DEST_FILE}" ]; then
  if [ "$(readlink "${DEST_FILE}" 2>/dev/null || true)" = "${STARSHIP_SRC}" ]; then
    echo "[starship] 이미 ${DEST_FILE} -> ${STARSHIP_SRC} 로 링크되어 있습니다. (skip)"
  else
    BACKUP="${DEST_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
    echo "[starship] 기존 ${DEST_FILE} 백업: ${BACKUP}"
    mv "${DEST_FILE}" "${BACKUP}"
    ln -s "${STARSHIP_SRC}" "${DEST_FILE}"
    echo "[starship] 새 starship config 링크 생성: ${DEST_FILE} -> ${STARSHIP_SRC}"
  fi
else
  ln -s "${STARSHIP_SRC}" "${DEST_FILE}"
  echo "[starship] starship config 링크 생성: ${DEST_FILE} -> ${STARSHIP_SRC}"
fi

# starship 설치 확인
if command -v starship >/dev/null 2>&1; then
  echo "[starship] starship 이미 설치됨: $(which starship)"
else
  echo "[starship] 경고: starship 명령을 찾지 못했습니다."
  echo "       macOS: brew install starship"
  echo "       Linux: curl -sS https://starship.rs/install.sh | sh"
fi

echo "[starship] 완료! shell rc 파일에 다음을 추가하세요:"
echo '       eval "$(starship init bash)"  # bash'
echo '       eval "$(starship init zsh)"   # zsh'
echo '       starship init fish | source   # fish'
