#!/usr/bin/env bash
set -u

SIGN_IN_URL='https://infinitode.prineside.com/?m=api&a=signIn&v=208'
GET_REPLAY_URL='https://infinitode.prineside.com/?m=api&a=getReplay&v=208'

red() { printf '\033[31m%s\033[0m\n' "$*"; }

copy_clipboard() {
  if command -v wl-copy >/dev/null 2>&1; then
    wl-copy
    return 0
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
    return 0
  fi
  return 1
}

if ! command -v curl >/dev/null 2>&1; then red "缺少依赖：curl"; read -r -p "按回车键退出..."; exit 0; fi
if ! command -v jq >/dev/null 2>&1; then red "缺少依赖：jq"; read -r -p "按回车键退出..."; exit 0; fi

read -r -p "请输入您的登录名(login)： " login
read -r -s -p "请输入您的密码(password)： " password
printf '\n'

login_json="$(curl -sS -X POST \
  --data-urlencode "login=$login" \
  --data-urlencode "password=$password" \
  "$SIGN_IN_URL" 2>/dev/null)"

status="$(printf '%s' "$login_json" | jq -r '.status // empty' 2>/dev/null)"
if [ "$status" != "success" ]; then
  msg="$(printf '%s' "$login_json" | jq -r '.message // "未知错误"' 2>/dev/null)"
  red "登录失败！错误信息：$msg"
  read -r -p "按回车键退出..."
  exit 0
fi

sessionid="$(printf '%s' "$login_json" | jq -r '.sessionid // empty' 2>/dev/null)"
if [ -z "${sessionid:-}" ]; then
  red "登录失败：返回中缺少 sessionid。"
  read -r -p "按回车键退出..."
  exit 0
fi

printf '登录成功！\n'
read -r -p "请输入 Replay ID： " replayid

replay_json="$(curl -sS -X POST \
  --data-urlencode "replayid=$replayid" \
  --data-urlencode "sessionid=$sessionid" \
  "$GET_REPLAY_URL" 2>/dev/null)"

rstatus="$(printf '%s' "$replay_json" | jq -r '.status // empty' 2>/dev/null)"
if [ "$rstatus" != "success" ]; then
  msg="$(printf '%s' "$replay_json" | jq -r '.message // "未知错误"' 2>/dev/null)"
  red "获取 Replay 失败！错误信息：$msg"
  read -r -p "按回车键退出..."
  exit 0
fi

replay="$(printf '%s' "$replay_json" | jq -r '.replay // ""' 2>/dev/null)"
prefix="${replay:0:64}"
printf 'Replay 前%s字符：%s\n' "${#prefix}" "$prefix"

file="${replayid}.txt"
if printf '%s' "$replay" >"$file"; then
  printf 'Replay 已保存到文件：%s\n' "$file"
else
  red "保存文件失败：$file"
fi

if printf '%s' "$replay" | copy_clipboard; then
  printf 'Replay 已复制到剪贴板。\n'
else
  red "复制到剪贴板失败（可安装 wl-clipboard 或 xclip）。"
fi

read -r -p "按回车键退出..."