# Vast.ai DL Bootstrap

```shell
git clone --depth 1 https://github.com/ccss17/vastai_quick_setup && cd vastai_quick_setup && ./setup.sh
```

![](https://raw.githubusercontent.com/ccss17/dotfiles/refs/heads/master/figure/vastai_setup.gif)

Fast, interruptible‑friendly developer environment for deep learning on vast.ai (H100/H200, etc.). The goal: **minimize cold‑start time** after preemptions while keeping the stack reproducible and lightweight.

On vast.ai, **interruptible** (spot/auction) instances are often 2–4× cheaper than on‑demand, but they can be preempted. With frequent restarts, the real bottleneck becomes **environment setup time**.

## What the script installs

* `git`, `zsh`, `vim`, `tmux`, `unzip`, `curl`, `wget`, `fd-find` (a.k.a. `fdfind`), `bat` (a.k.a. `batcat`), `time`, `nvtop`, `python3.12-dev`, `build-essential`, `tree`

    * **`fd-find` vs `find`** — sane defaults, fast search, gitignore awareness; dramatically lowers friction when digging through repos/datasets.
    * **`bat` vs `cat`** — syntax highlighting, Git integration, auto‑paging; makes scanning logs/configs much faster.
    * **`nvtop` vs `nvidia-smi`** — interactive GPU process view across multiple GPUs; ideal for training/serving sessions.
    * **`python3.x-dev` + `build-essential`** — reduces sdist build failures for Python packages with C/C++ extensions.
* **`btop`** — modern TUI system monitor (CPU/mem/disk/net, process control, mouse support). Faster triage than `top/htop`.
* **`gotop`** — graphical activity monitor in the terminal; quick visual grasp of spikes/bottlenecks.
* **`hyperfine`** — reliable micro‑benchmarking (warming, repeats, statistics, export). Great for comparing data loaders, conversion scripts, etc.
* **`lsd`** — `ls` with icons/tree/columns; faster directory scanning.
* **`vim-plug`** — single‑file plugin manager for Vim with *parallel* install/update; perfect for ephemeral hosts.
* **`zsh` + `oh-my-zsh`** — richer completion, plugin/theme ecosystem, easier to extend than plain bash.
* **`powerlevel10k`** — fast prompt showing git status, Python venv, time, etc.; high signal density with very low latency.
* **`tmux`** — persistent terminal sessions, pane/window layouts; SSH disconnects are no longer disruptive.
* **`uv` (Astral)** — blazingly fast Python package manager & workflow tool.

  * **Use when CUDA toolkit is *not* required in the environment.**

* **`micromamba`** (+ `conda-forge` & strict priority)

  * **Use when CUDA toolkit or conda‑only packages *are* required.**
  * Why it’s productive vs classic `conda`:

    * **Single static binary** (no bootstrap solver overhead), fast dependency resolution (libmamba), reproducible CUDA stacks (`cudatoolkit`, MKL, etc.) *inside* the env without system‑wide installs.

# Zsh Aliases 


| Alias | Expands to   | Category   | Why it’s more productive                                              | Notes                                                 |
| ----- | ------------ | ---------- | --------------------------------------------------------------------- | ----------------------------------------------------- |
| `t`   | `tmux`       | Sessions   | 1‑char attach/create; resilient panes survive SSH drops.              | Use with `tmux a -t <name>` to reattach.              |
| `v`   | `vim`        | Editing    | Fast editor launch; common muscle‑memory.                             | Pairs with `vim-plug` for instant plugin sync.        |
| `c`   | `clear`      | UI         | Clears clutter instantly.                                             | Works in any shell.                                   |
| `cl`  | `clear;ls`   | UI+Nav     | Clear + list current dir in one stroke; great after builds/pulls.     | Uses `lsd` (see below).                               |
| `cs`  | `cd ..`      | Nav        | Go up one directory with 2 keys.                                      | Combine: `cs; cl`.                                    |
| `l`   | `ls`         | Listing    | Short, frequent; keeps listing as default.                            | Aliased to `lsd` via `ls` below.                      |
| `la`  | `ls -a`      | Listing    | Show dotfiles by default.                                             | `lsd` preserves colors/icons.                         |
| `ll`  | `ls -la`     | Listing    | Long form with perms/owner/size.                                      | High‑signal directory scan.                           |
| `lt`  | `ls --tree`  | Listing    | Tree view for quick structure overview.                               | Requires `lsd`.                                       |
| `ls`  | `lsd`        | Listing    | Rich, colored, iconified output; faster visual parsing than GNU `ls`. | On Ubuntu/Debian, `lsd` is a separate pkg.            |
| `g`   | `git`        | VCS        | Common git verbs now 1 char: `g s`, `g d`, `g c -m`…                  | Add your own `git` aliases inside `~/.gitconfig`.     |
| `py`  | `python3`    | Python     | Always uses Py3 even if `python` points elsewhere.                    | Safer on mixed systems.                               |
| `py2` | `python2`    | Python     | Legacy interpreter (if installed).                                    | Most distros no longer ship Python 2.                 |
| `py3` | `python3`    | Python     | Redundant alias for clarity.                                          | Good for teaching/demo contexts.                      |
| `mm`  | `micromamba` | Env        | Fast conda‑forge env mgmt, single static binary.                      | Use when CUDA toolkits or conda‑only pkgs are needed. |
| `q`   | `exit`       | Shell      | Quick exit from subshells/tmux panes.                                 | Minimizes hand movement.                              |
| `fd`  | `fdfind`     | Search     | Modern, fast file finder (gitignore‑aware).                           | Ubuntu/Debian name is `fdfind`.                       |
| `bat` | `batcat`     | Viewer     | `cat` with syntax highlighting and Git integration.                   | Ubuntu/Debian binary is `batcat`.                     |

# Global `.gitconfig` 

In your shell, `g` is an alias for `git`. In Git, we define short subcommands like `s = status`. **Result:** typing `g s` runs `git status`. Likewise, `g lg` → `git log --oneline --graph --decorate`, etc.

| Shortcut       | Expands to                             | Purpose                                 |
| -------------- | -------------------------------------- | --------------------------------------- |
| `g s`          | `git status`                           | Quick status.                           |
| `g sb`         | `git status -s -b`                     | Short status + branch line.             |
| `g lg`         | `git log --oneline --graph --decorate` | Nice, compact history graph.            |
| `g d`          | `git diff`                             | Working tree diff.                      |
| `g dc`         | `git diff --cached`                    | Staged diff.                            |
| `g dt`         | `git difftool`                         | Open external diff (vimdiff).           |
| `g a`          | `git add --all`                        | Stage everything (tracked + untracked). |
| `g c`          | `git commit`                           | Commit (opens editor).                  |
| `g cm "msg"`   | `git commit -m "msg"`                  | Message inline.                         |
| `g cd`         | `git commit --amend`                   | Amend last commit (keep message).       |
| `g bc`         | `git rev-parse --abbrev-ref HEAD`      | Show current branch name.               |
| `g o <branch>` | `git checkout <branch>`                | Switch branch.                          |
| `g ob <new>`   | `git checkout -b <new>`                | Create + switch.                        |
| `g ploc`       | `git pull origin $(git bc)`            | Pull current branch from origin.        |
| `g pboc`       | `git pull --rebase origin $(git bc)`   | Rebase pull.                            |
| `g psoc`       | `git push origin $(git bc)`            | Push current branch to origin.          |
| `g psuoc`      | `git push -u origin $(git bc)`         | Push + set upstream.                    |
| `g pr`         | `git prune -v`                         | Cleanup unreachable objects (local).    |
| `g st`         | *counts stashes*                       | Number of stash entries.                |
| `g ss`         | `git stash save`                       | Stash working state.                    |
| `g sp`         | `git stash pop`                        | Apply + drop.                           |
| `g rb`         | `git rebase`                           | Start/continue a rebase.                |
| `g rbc`        | `git rebase --continue`                | Continue after conflict resolution.     |
| `g rba`        | `git rebase --abort`                   | Abort rebase.                           |

# Global `.gitignore`

```gitignore
# — OS cruft —
.DS_Store
Thumbs.db
ehthumbs.db
Desktop.ini
Icon?
._*
$RECYCLE.BIN/

# — Editor/IDE temps —
*~
*.swp
*.swo
.#*
\#*\#

# — Generic build artifacts —
*.o
*.class
*.exe
*.dll
*.com
*.pid
# *.so   # keep commented to avoid hiding intentional shared libs

# — Logs —
*.log

# — Python caches (safe globally) —
__pycache__/
*.py[cod]
*$py.class
.pytest_cache/
.mypy_cache/
.ruff_cache/
.ipynb_checkpoints/

# — Archives & packages (from your original) —
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip
*.deb
*.tgz

# — Databases (from your original) —
*.sql
*.sqlite
```

# tmux Config

This appendix explains **custom keybindings** that make tmux faster for day‑to‑day work on remote/ephemeral GPU hosts.

- Prefix: `Ctrl‑A` (instead of `Ctrl‑B`)

    * **Why**: `Ctrl‑A` is physically closer to the home row than `Ctrl‑B`. Lower hand travel → faster, less strain.
    * `send-prefix` lets you forward `C‑a` to nested tmux/screen sessions when needed.

- Splits: mnemonic and ergonomic
    * **`\\` (backslash) → left/right split** (Mnemonic: think of a **vertical divider** between panes.)
    * **`-` (minus) → top/bottom split** (Mnemonic: a **horizontal bar** separating panes.)

- Pane navigation & resizing (no prefix)

    * **No‑prefix Nav**: Alt+`h/j/k/l` mirrors Vim movement across panes. Muscle memory carries over.
    * **Coarse resize**: Alt+`←/→` adjusts width by 25 columns (quick layout fixes). Alt+`↑/↓` tweaks height by 5 rows for fine control.
    * **Window ops** without prefix keep flows fluid while logs/models stream.

* **Cycle pane**: `Alt + o`
* **New window / Next / Prev**: `Alt + c / Alt + n / Alt + p`

# Vim Config 

This appendix highlights **custom keybindings** that match your tmux ergonomics, and the **vim‑plug plugin set**—what each does and why it improves day‑to‑day productivity on remote GPU hosts.

## Custom keybindings 

**Window/tabs & layout**

* `<Up>/<Down>` → `:resize -5 / +5` (shrink/grow height)
* `<Left>/<Right>` → `:vertical resize -5 / +5` (shrink/grow width)

**Pane navigation (split windows)**

* `<C-h/j/k/l>` → `:wincmd h/j/k/l`
  *Exactly the same movement keys you use in tmux; your muscle memory transfers 1:1.*

**File tree & workflow**

* `<C-p>` → `:NERDTreeToggle`
  *One key to jump between code and file browser; hidden files are shown by default.*
* `<C-s>` → `:w` (save)
* `<C-q>` → `:q` (quit)


## Plugins (via **vim‑plug**) 

* **`scrooloose/nerdtree`** File explorer with bookmarks; pairs with `<C-p>` toggle. 
* **`terryma/vim-multiple-cursors`** Multi‑edit with `Ctrl‑n` / `Ctrl‑x` / `Ctrl‑p` (select next/skip/prev). **Why**: refactors and repetitive edits become trivial.
* **`scrooloose/nerdcommenter`** Smart comment/uncomment with `gc`/`gcc`. **Why**: consistent across languages.
* **`fidian/hexmode`** Toggle hex view with `:Hexmode`. **Why**: quick binary/weights inspection without leaving Vim.

# mamba (over conda)

Micromamba auto‑activation (vast.ai aware): **Intent**: Automatically land in the correct conda/mamba env on login.

* On vast.ai **framework templates** (e.g., *PyTorch*), an env named **`main`** is precreated. Your logic detects it and runs `micromamba activate main`.
* On bare **OS templates** (e.g., *Ubuntu 24 CUDA*), `main` does not exist yet, so it gracefully falls back to `micromamba activate base` (micromamba’s default root env).
