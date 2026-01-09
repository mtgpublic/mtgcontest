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

if ! command -v curl >/dev/null 2>&1; then red "Missing dependency: curl"; read -r -p "Press Enter to exit..."; exit 0; fi
if ! command -v jq >/dev/null 2>&1; then red "Missing dependency: jq"; read -r -p "Press Enter to exit..."; exit 0; fi

read -r -p "Enter your login: " login
read -r -s -p "Enter your password: " password
printf '\n'

login_json="$(curl -sS -X POST \
  --data-urlencode "login=$login" \
  --data-urlencode "password=$password" \
  "$SIGN_IN_URL" 2>/dev/null)"

status="$(printf '%s' "$login_json" | jq -r '.status // empty' 2>/dev/null)"
if [ "$status" != "success" ]; then
  msg="$(printf '%s' "$login_json" | jq -r '.message // "Unknown error"' 2>/dev/null)"
  red "Sign-in failed: $msg"
  read -r -p "Press Enter to exit..."
  exit 0
fi

sessionid="$(printf '%s' "$login_json" | jq -r '.sessionid // empty' 2>/dev/null)"
if [ -z "${sessionid:-}" ]; then
  red "Sign-in failed: missing sessionid in response."
  read -r -p "Press Enter to exit..."
  exit 0
fi

printf 'Sign-in successful.\n'
read -r -p "Enter Replay ID: " replayid

replay_json="$(curl -sS -X POST \
  --data-urlencode "replayid=$replayid" \
  --data-urlencode "sessionid=$sessionid" \
  "$GET_REPLAY_URL" 2>/dev/null)"

rstatus="$(printf '%s' "$replay_json" | jq -r '.status // empty' 2>/dev/null)"
if [ "$rstatus" != "success" ]; then
  msg="$(printf '%s' "$replay_json" | jq -r '.message // "Unknown error"' 2>/dev/null)"
  red "GetReplay failed: $msg"
  read -r -p "Press Enter to exit..."
  exit 0
fi

replay="$(printf '%s' "$replay_json" | jq -r '.replay // ""' 2>/dev/null)"
prefix="${replay:0:64}"
printf 'Replay first %s chars: %s\n' "${#prefix}" "$prefix"

file="${replayid}.txt"
if printf '%s' "$replay" >"$file"; then
  printf 'Replay saved to: %s\n' "$file"
else
  red "Failed to save file: $file"
fi

if printf '%s' "$replay" | copy_clipboard; then
  printf 'Replay copied to clipboard.\n'
else
  red "Failed to copy to clipboard (install wl-clipboard or xclip)."
fi

read -r -p "Press Enter to exit..."