#!/usr/bin/env bash
CLIPBOARD_HISTORY="$HOME/.clipboard_history"

# small delay to allow the clipboard to update
sleep 0.05  # 50 milliseconds

content=$(wl-paste 2>/dev/null)

if [[ -n "$content" ]]; then
    {
        printf "====ENTRY====\n"
        printf "%s" "$content"
        printf "\n"
    } >> "$CLIPBOARD_HISTORY"
fi
