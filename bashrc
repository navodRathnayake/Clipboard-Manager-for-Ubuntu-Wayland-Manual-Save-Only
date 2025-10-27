# include this in bashrc

# Suppress wl-paste watch warnings
export WL_PASTE_SILENCE=1



#!/usr/bin/env bash

CLIPBOARD_HISTORY="$HOME/.clipboard_history"

# Start clipboard watcher silently (auto-save new copies)
pgrep -f "wl-paste --watch" >/dev/null || \
    wl-paste --watch bash -c 'cli-save' 2>/dev/null &


# -----------------------------
# Save clipboard content
# -----------------------------
cli-save() {
    local content
    content=$(wl-paste)
    if [[ -n "$content" ]]; then
        {
            printf "====ENTRY====\n"
            printf "%s" "$content"
            printf "\n"
        } >> "$CLIPBOARD_HISTORY"
        echo "[Saved clipboard entry]"
    else
        echo "[Clipboard empty]"
    fi
}



# -----------------------------
# Pick and copy entries
# -----------------------------

cli-pick() {
    local selected
    selected=$(perl -0777 -ne '
        while (/====ENTRY====\n(.*?)(?=\n====ENTRY====|\z)/sg) {
            my $e = $1;
            $e =~ s/\n/␤/g;      # Replace newlines with placeholder
            $e =~ s/␤+\z//;      # Remove trailing placeholders
            print $e, "\0";      # Null-delimited for fzf
        }
    ' "$CLIPBOARD_HISTORY" \
    | fzf --read0 --multi --height 40% \
        --preview 'printf "%s" "{}" | tr "␤" "\n" | awk NF' \
        --bind 'tab:toggle,ctrl-t:toggle,alt-a:toggle-all,ctrl-r:reload(cat '"$CLIPBOARD_HISTORY"' | perl -0777 -ne '\''while (/====ENTRY====\n(.*?)(?=\n====ENTRY====|\z)/sg){my $e=$1;$e=~s/\n/␤/g;$e=~s/␤+\z//;print $e,"\0";}'\'')')
    if [[ -n "$selected" ]]; then
        printf "%s" "$selected" | tr "␤" "\n" | sed '/^$/d' | wl-copy
        echo "[Copied to clipboard]"
    fi
}



# -----------------------------
# Show clipboard entries
# -----------------------------

cli-show() {
    perl -0777 -ne '
        while (/====ENTRY====\n(.*?)(?=\n====ENTRY====|\z)/sg) {
            my $e = $1;
            $e =~ s/\n/␤/g;      # Replace newlines with placeholder
            $e =~ s/␤+\z//;      # Remove trailing placeholders
            print $e, "\0";      # Null-delimited for fzf
        }
    ' "$CLIPBOARD_HISTORY" \
    | fzf --read0 --no-sort --height 40% \
        --preview 'printf "%s" "{}" | tr "␤" "\n" | sed "/^$/d"' \
        --bind 'ctrl-q:abort'
}


# -----------------------------
# Clear clipboard history
# -----------------------------
cli-clear() {
    read -p "Are you sure you want to clear clipboard history? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        : > "$CLIPBOARD_HISTORY"
        echo "[Clipboard history cleared]"
    else
        echo "[Aborted]"
    fi
}

# -----------------------------
# CLI usage helper
# -----------------------------
cli-help() {
    echo "Usage: $0 {save|pick|show|clear}"
    echo "  save   - Save current clipboard content"
    echo "  pick   - Pick from history and copy to clipboard"
    echo "  show   - Show clipboard history"
    echo "  clear  - Clear clipboard history"
}



pgrep -f "wl-paste --watch" > /dev/null || nohup wl-paste --watch bash -c 'cli-save' &>/dev/null &
