#!/bin/bash

# =========================================================
# Bash Spinner
#
# Description: Display a small customizable progress spinner in bash while your commands are running
# Usage: 
#   source <file>.sh
#   start_spinner --type={value} --color={value}
#   sleep 1
#   stop_spinner
#
# Parameters:
#   --type          - Available spinner types : line, dot, mini_dot, ellipsis, jump
#   --color         - Available spinner colors : red, green, yellow, blue, magenta, cyan, white
#
# Created by: https://github.com/vidardev/
# =========================================================

# --- Configuration ---
# Available spinner characters and delays
SPINNER_CHARS_LINE=('|' '/' '-' '\')
SPINNER_CHARS_LINE_DELAY=0.1

SPINNER_CHARS_DOT=('⣾' '⣽' '⣻' '⢿' '⡿' '⣟' '⣯' '⣷')
SPINNER_CHARS_DOT_DELAY=0.1

SPINNER_CHARS_MINI_DOT=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
SPINNER_CHARS_MINI_DOT_DELAY=0.08

SPINNER_CHARS_ELLIPSIS=('' '.' '..' '...')
SPINNER_CHARS_ELLIPSIS_DELAY=0.12

SPINNER_CHARS_JUMP=("▱▱▱" "▰▱▱" "▰▰▱" "▰▰▰" "▰▰▱" "▰▱▱" "▱▱▱")
SPINNER_CHARS_JUMP_DELAY=0.14

# Available colors (name:code)
COLORS=(
  "red:31" "green:32" "yellow:33" 
  "blue:34" "magenta:35" "cyan:36" "white:37"
)

# Default spinner color and reset code
COLOR_DEFAULT='\033[36m'
COLOR_RESET='\033[0m'

# --- Global variables ---
_SPINNER_PID=""           # Process ID of the spinner
_SPINNER_ACTIVE="false"   # Spinner active state
_CURRENT_DELAY=""         # Current delay for the spinner
_CURRENT_COLOR=""         # Current color for the spinner

# --- Private functions ---
_is_supported_utf8() {
  [[ "${LANG:-}" == *.UTF-8 || "${LC_ALL:-}" == *.UTF-8 || "${LC_CTYPE:-}" == *.UTF-8 ]] || \
  (command -v locale >/dev/null 2>&1 && locale charmap 2>/dev/null | grep -q "UTF-8")
}

_get_delay_for_spinner() {
  local spinner_type="$1"
  
  case "$spinner_type" in
    "line")      echo "$SPINNER_CHARS_LINE_DELAY" ;;
    "dot")       echo "$SPINNER_CHARS_DOT_DELAY" ;;
    "mini_dot")  echo "$SPINNER_CHARS_MINI_DOT_DELAY" ;;
    "ellipsis")  echo "$SPINNER_CHARS_ELLIPSIS_DELAY" ;;
    "jump")      echo "$SPINNER_CHARS_JUMP_DELAY" ;;
    *)           echo "$SPINNER_CHARS_LINE_DELAY" ;;  # Default value
  esac
}

_get_color_code() {
  local color_name="$1"
  
  # If it's already a full ANSI code, return it
  if [[ "$color_name" == '\033['*'m' ]]; then
    echo "$color_name"
    return
  fi
  
  # Otherwise, search in the color list
  for color_entry in "${COLORS[@]}"; do
    local name="${color_entry%%:*}"
    local code="${color_entry##*:}"
    
    if [[ "$name" == "$color_name" ]]; then
      echo "\033[${code}m"
      return
    fi
  done
  
  # Return default color if not found
  echo "$COLOR_DEFAULT"
}

# Run the spinner animation logic in the background
_run_spinner_logic() {
  local chars_to_use=("$@")  # All arguments are the characters
  local delay="$_CURRENT_DELAY"
  
  # Hide the cursor
  printf "\033[?25l" 2>/dev/null || true
  
  # Ensure the cursor is restored on exit
  trap 'printf "\033[?25h" 2>/dev/null || true; exit 0' INT TERM EXIT
  
  # Spinner animation loop
  while true; do
    for char in "${chars_to_use[@]}"; do
      # Check if the parent process still exists
      if ! kill -0 "$PPID" 2>/dev/null; then
        printf "\033[?25h" 2>/dev/null || true # Restore the cursor before exiting
        exit 0
      fi
      
      # Display the spinner character
      printf "\033[s"                                         # Save cursor position
      printf "\033[K"                                         # Clear the line
      printf "%b%s%b" "$_CURRENT_COLOR" "$char" "$COLOR_RESET" # Display the spinner
      printf "\033[u"                                         # Restore cursor position
      
      # Pause between frames
      sleep "$delay" 2>/dev/null || sleep 0.1
    done
  done
}

# --- Public functions ---
start_spinner() {
  # If standard output is not a terminal, do nothing
  if [[ ! -t 1 ]]; then
    _SPINNER_ACTIVE="false"
    return 0
  fi
  
  # Check if a spinner is already running
  if [[ "$_SPINNER_ACTIVE" == "true" && -n "$_SPINNER_PID" ]] && kill -0 "$_SPINNER_PID" 2>/dev/null; then
    return 1
  fi
  
  # Process options for spinner type and color
  local spinner_type="line"
  local custom_color=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type=*)
        spinner_type="${1#*=}"
        shift
        ;;
      --color=*)
        custom_color="${1#*=}"
        shift
        ;;
      *)
        # Accept simple type without --type= prefix
        if [[ -z "$2" || "$2" == --* ]]; then
          spinner_type="$1"
        fi
        shift
        ;;
    esac
  done
  
  # Check UTF-8 support for character types that require it
  if ! _is_supported_utf8 && [[ "$spinner_type" != "line" && "$spinner_type" != "ellipsis" ]]; then
    spinner_type="line"
  fi
  
  local chars_to_use=()  
  case "$spinner_type" in
    "line")
      chars_to_use=("${SPINNER_CHARS_LINE[@]}")
      _CURRENT_DELAY="$SPINNER_CHARS_LINE_DELAY"
      ;;
    "dot")
      chars_to_use=("${SPINNER_CHARS_DOT[@]}")
      _CURRENT_DELAY="$SPINNER_CHARS_DOT_DELAY"
      ;;
    "mini_dot")
      chars_to_use=("${SPINNER_CHARS_MINI_DOT[@]}")
      _CURRENT_DELAY="$SPINNER_CHARS_MINI_DOT_DELAY"
      ;;
    "ellipsis")
      chars_to_use=("${SPINNER_CHARS_ELLIPSIS[@]}")
      _CURRENT_DELAY="$SPINNER_CHARS_ELLIPSIS_DELAY"
      ;;
    "jump")
      chars_to_use=("${SPINNER_CHARS_JUMP[@]}")
      _CURRENT_DELAY="$SPINNER_CHARS_JUMP_DELAY"
      ;;
    *)
      chars_to_use=("${SPINNER_CHARS_LINE[@]}")
      _CURRENT_DELAY="$SPINNER_CHARS_LINE_DELAY"
      ;;
  esac
  
  # Set the custom color if provided
  if [[ -n "$custom_color" ]]; then
    _CURRENT_COLOR="$(_get_color_code "$custom_color")"
  fi
  
  # Start the spinner in the background
  _run_spinner_logic "${chars_to_use[@]}" &
  _SPINNER_PID=$!
  _SPINNER_ACTIVE="true"
  
  # Set traps for cleanup, suppressing any errors from the trap command itself
  trap 'stop_spinner; exit 130' INT 2>/dev/null || true  # Ctrl+C
  trap 'stop_spinner; exit 143' TERM 2>/dev/null || true # kill
  trap 'stop_spinner' EXIT 2>/dev/null || true           # Normal exit or other signal
}

stop_spinner() {
  # Do nothing if the spinner is not active
  if [[ "$_SPINNER_ACTIVE" != "true" ]]; then
    return 0
  fi
  
  # Stop the spinner process if it exists
  if [[ -n "$_SPINNER_PID" ]] && kill -0 "$_SPINNER_PID" 2>/dev/null; then
    kill "$_SPINNER_PID" 2>/dev/null
    wait "$_SPINNER_PID" 2>/dev/null || true # Ignore errors on wait
  fi
  
  # Reset global variables
  _SPINNER_PID=""
  _SPINNER_ACTIVE="false"
  _CURRENT_DELAY=""
  
  # Clean the line ONLY if we are in a TTY
  if [[ -t 1 ]]; then
    printf "\033[s"           # Save position
    printf "\033[K"           # Clear the line
    printf "\033[u"           # Restore position
    printf "\033[?25h"        # Show the cursor
  fi
  
  # Remove traps to avoid multiple executions
  trap - INT TERM EXIT 2>/dev/null || true
}

# --- Export function ---
_export_spinner_functions() {
  # Export public functions for subshells
  export -f start_spinner stop_spinner  
  # Export private functions needed by public ones
  export -f _run_spinner_logic _is_supported_utf8 _get_delay_for_spinner _get_color_code
}

_export_spinner_functions