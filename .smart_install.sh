#!/bin/bash

function _smart_install_wrapper() {
  _warn() {
    echo -e "\033[1;31m$@\033[0m"
  }

  _cmd() {
    echo -e "\033[1;32m$@\033[0m"
    eval "$@"
  }

  local _HAS_CARGO=""
  local _HAS_PIP=""
  local _NODE_PKG_MGR=""

  # test cargo
  [[ -f "./Cargo.toml" ]] && _HAS_CARGO="1"
  # test pip 
  [[ -f "./requirements.txt" ]] && _HAS_PIP="1"  
  # test node 
  if [[ -f "./package.json" ]]; then 
    # test if package manager is specified in `package.json` file.
    if ! command -v jq 2>&1 >> /dev/null; then 
      _warn "No `jq` installed. Cannot parse `package.json` contents!" 
    else
      _NODE_PKG_MGR=$(jq ".packageManager" "./package.json")
      if [[ "$_NODE_PKG_MGR" == "null" ]]; then 
        _NODE_PKG_MGR=""
      fi 
    fi 
    # if package manager is not specified, detect by local scaffold files.
    if [[ -z "$_NODE_PKG_MGR" ]];then 
      [[ -f "./bun.lockb" ]] && _NODE_PKG_MGR="bun"
      [[ -f "./pnpm-lock.yaml" ]] && _NODE_PKG_MGR="pnpm"
      [[ -f "./pnpm-workspace.yaml" ]] && _NODE_PKG_MGR="pnpm"
      [[ -f "./yarn.lock" ]] && _NODE_PKG_MGR="yarn"
      [[ -f "./lerna.json" ]] && _NODE_PKG_MGR="yarn"

      # default: npm
      [[ -z "$_NODE_PKG_MGR" ]] && _NODE_PKG_MGR="npm"
    fi 
  fi 

  if [[ "$_HAS_PIP" ]]; then 
    # try activate venv 
    if [[ "$VIRTUAL_ENV" == "" ]] && [[ -d "./venv" ]]; then
      _warn "Python venv detected. Using it."
      _warn "You may want to exec `. ./venv/bin/activate` command to activate it in the future"
      . ./venv/bin/activate
    fi 
    _cmd pip install "$@"
  elif [[ "$_HAS_CARGO" ]]; then 
    if [[ "$@" == "" ]];then 
      _cmd cargo install --path .
    else 
      _cmd cargo install "$@"
    fi 
  elif [[ "$_NODE_PKG_MGR" ]]; then 
    _cmd $_NODE_PKG_MGR install "$@"
  else
    _warn "Cannot detect any development environment under $(pwd)"
  fi 
}
alias install="_smart_install_wrapper"

