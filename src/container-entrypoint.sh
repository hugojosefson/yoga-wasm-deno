#!/usr/bin/env bash

set -euo pipefail
IFS=$'\t\n'

if ! [[ "${EUID}" == "0" ]]; then
  echo "This docker image must be started as root, so don't use 'docker run --user=...'.
Instead, pass environment variables USER_NAME, USER_ID, GROUP_NAME, GROUP_ID (and optionally HOME) for the user you want to become." >&2
  exit 1
fi

if [[ "|${USER_NAME:-""}|${USER_ID:-""}|${GROUP_NAME:-""}|${GROUP_ID:-""}" == *"||"* ]]; then
  echo "You must pass env variables USER_NAME, USER_ID, GROUP_NAME, GROUP_ID to the Docker container.
Passing env variable HOME is optional." >&2
  exit 1
fi
export HOME="${HOME:-"/home/${USER_NAME}"}"

groupadd \
  --gid "${GROUP_ID}" \
  "${GROUP_NAME}"

if [[ -d "${HOME}" ]]; then
  CREATE_HOME=""
else
  CREATE_HOME="--create-home"
fi

useradd \
  --uid "${USER_ID}" \
  --gid "${GROUP_ID}" \
  --groups nvm,video \
  ${CREATE_HOME} \
  --home-dir "${HOME}" \
  "${USER_NAME}"

echo -e "\n${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers

if [[ "${2:-""}" == "bash" ]]; then
  exec gosu "${USER_ID}:${GROUP_ID}" sh -c "cd ${HOME} && bash"
  exit 0
fi

XDG_RUNTIME_DIR="/run/user/${USER_ID}"
mkdir -p "${XDG_RUNTIME_DIR}"
mkdir -p "${HOME}/.config"
mkdir -p "${HOME}/.cache"
chown -R "${USER_ID}:${GROUP_ID}" "${XDG_RUNTIME_DIR}"
chown -R "${USER_ID}:${GROUP_ID}" "${HOME}/.config"
chown -R "${USER_ID}:${GROUP_ID}" "${HOME}/.cache"

# shellcheck disable=SC1091
. /opt/nvm/nvm.sh

XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" \
  exec gosu "${USER_ID}:${GROUP_ID}" "$@"
