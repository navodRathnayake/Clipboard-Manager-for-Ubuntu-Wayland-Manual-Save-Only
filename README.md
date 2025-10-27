# Clipboard Manager for Ubuntu (Wayland) — Manual Save Only

Lightweight clipboard manager for Ubuntu Wayland. Save clipboard content **manually** via keybinding and browse history using `fzf`.

---

## Features

- Save clipboard only when manually triggered (**Ctrl+Space**).  
- Browse clipboard history with `fzf` (`cli-pick`).  
- Copy previous entries back to clipboard.  
- Clear history with `cli-clear`.  
- Minimal memory and CPU usage — **no background watcher**.  

---

## Requirements

- Ubuntu (Wayland)  
- `fzf`  
- `wl-clipboard` (`wl-paste` / `wl-copy`)  
- Perl  

---

## Install Dependencies

```bash
sudo apt update
sudo apt install fzf wl-clipboard perl
```

---

## Installation

1. **Add your `.cli-save.bash` script**:

```bash
nano ~/.cli-save.bash
```

Paste the following:

```bash
#!/usr/bin/env bash
CLIPBOARD_HISTORY="$HOME/.clipboard_history"

content=$(wl-paste 2>/dev/null)
if [[ -n "$content" ]]; then
    {
        printf "====ENTRY====\n"
        printf "%s" "$content"
        printf "\n"
    } >> "$CLIPBOARD_HISTORY"
    echo "[Saved clipboard entry]"
fi
```

Make it executable:

```bash
chmod +x ~/.cli-save.bash
```

2. **Add fzf functions to `~/.bashrc`**:

```bash
CLIPBOARD_HISTORY="$HOME/.clipboard_history"

cli-pick() { ... }   # your fzf pick function
cli-show() { ... }   # your fzf show function
cli-clear() { ... }  # your fzf clear function
```

Reload `.bashrc`:

```bash
source ~/.bashrc
```

---

## Keybinding

1. Go to **System Settings → Keyboard → Shortcuts → Custom Shortcut**.  
2. Add a custom shortcut pointing to:

```bash
~/.cli-save.bash
```

3. Assign **Ctrl+Space** as the shortcut.  

> **Note:** Clipboard is saved **only when this keybinding is pressed**. Normal Ctrl+C does **not** save automatically.

---

## Usage

| Command     | Description |
|------------|-------------|
| `cli-pick` | Browse and pick from clipboard history using `fzf`. Press **Ctrl+R** inside `fzf` to reload latest entries. |
| `cli-show` | View clipboard history in read-only mode. |
| `cli-clear` | Clear clipboard history. |

---

## Storage

- Clipboard history is stored at `~/.clipboard_history`.  
- Only the **last 1000 entries** are kept automatically.  
- Hidden file by default to keep your home directory clean.

---

## Troubleshooting

1. **Keybinding not saving clipboard**  
   - Ensure you use the **absolute path**:

```bash
~/.cli-save.bash
```

2. **Old entries showing in `cli-pick`**  
   - Press **Ctrl+R** inside `cli-pick` to reload.
