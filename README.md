# Vast.ai DL Bootstrap

```shell
git clone --depth 1 https://github.com/ccss17/vastai_quick_setup && cd vastai_quick_setup && ./setup.sh
```

![](https://raw.githubusercontent.com/ccss17/dotfiles/refs/heads/master/figure/vastai_setup.gif)

Fast, interruptible‑friendly developer environment for deep learning on vast.ai (H100/H200, etc.). The goal: **minimize cold‑start time** after preemptions while keeping the stack reproducible and lightweight.

On vast.ai, **interruptible** (spot/auction) instances are often 2–4× cheaper than on‑demand, but they can be preempted. With frequent restarts, the real bottleneck becomes **environment setup time**.

## Vast.ai GGul Tips

#### 1. filter: internet speed >= 1Gbps

![](figure/1.png)

#### 2. filter: Interruptible + DLPerf/$/Hr --> rent H100/H200 GPU

On-demand instances won’t be preempted—no one can outbid you—so they won’t be force-stopped, but they cost more than interruptible GPU instances. Even if the GPU instance you're using gets interrupted, you can spin up a new GPU instance and either clone the working path as-is or sync it to the cloud, so my in-progress workspace doesn’t get deleted. 

![](figure/2.png)

As for DLPert/$/Hr, it’s a cost-efficiency ranking by deep learning performance per hour; when you sort instances by this, H100 or H200 usually float to the top because they offer the best “performance-for-price” in deep learning. It’s actually cheaper and faster to rent an H100/H200 and finish a job that would take 4 hours in under 1 hour.



## What the script installs

* **`pixi`** — fast, lockfile-first, GPU-aware environment manager that unifies conda binaries and PyPI (via `uv`) under one project manifest.
* **`micromamba`**(instead conda) (+ `conda-forge` & strict priority)

* `fd-find`, `bat`, `time`, `nvtop`, `tree`

    * **`fd-find` vs `find`** — sane defaults, fast search, gitignore awareness; dramatically lowers friction when digging through repos/datasets.
    * **`bat` vs `cat`** — syntax highlighting, Git integration, auto‑paging; makes scanning logs/configs much faster.
    * **`nvtop` vs `nvidia-smi`** — interactive GPU process view across multiple GPUs; ideal for training/serving sessions.
* **`btop`** — modern TUI system monitor (CPU/mem/disk/net, process control, mouse support). Faster triage than `top/htop`.
* **`gotop`** — graphical activity monitor in the terminal; quick visual grasp of spikes/bottlenecks.
* **`hyperfine`** — reliable micro‑benchmarking (warming, repeats, statistics, export). Great for comparing data loaders, conversion scripts, etc.
* **`lsd`** — `ls` with icons/tree/columns; faster directory scanning.
* **`vim-plug`** — single‑file plugin manager for Vim with *parallel* install/update; perfect for ephemeral hosts.
* **`zsh` + `oh-my-zsh`** — richer completion, plugin/theme ecosystem, easier to extend than plain bash.
* **`powerlevel10k`** — fast prompt showing git status, Python venv, time, etc.; high signal density with very low latency.
* **`tmux`** — persistent terminal sessions, pane/window layouts; SSH disconnects are no longer disruptive.

# pixi (over mamba (over conda))

Why `mamba` instead of plain `conda`: **Much faster solves**: libmamba solver dramatically reduces dependency‐resolution time. 

* **conda → mamba → pixi** is a speed & reproducibility ladder.

Why `pixi` instead of `mamba`: `pixi` takes the conda performance baseline and adds project‑centric features that reduce time‑to‑run and prevent drift across machines.

`pixi` takes the fastest path for each ecosystem:

* **Conda binaries:** When a package is available as a prebuilt conda package, `pixi` uses the same class of high-performance solver and parallel download/extract pipeline as `mamba` (libmamba/rattler style). 

* **PyPI packages:** When you pull from PyPI, `pixi` delegates to **`uv`** under the hood, inheriting `uv`’s highly parallel resolution and download performance.

**Outcome:** 

* **When prebuilt conda binaries exist:** `pixi ≈ mamba ≫ uv`
  *(uv can’t consume conda packages.)*

* **When only PyPI wheels exist:** `pixi ≈ uv ≫ mamba`
  *(mamba’s pip stage is typically more serial.)*

* **When neither binaries nor wheels exist (source build):** `pixi ≈ uv ≈ mamba`
  *(everyone is slow; compilation dominates.)*

**Benchmark: LLM fine-tuning environment template**

```toml
# pyproject.toml (pixi section)
[project]
name = "dl-cu129"
requires-python = ">=3.12"

[tool.pixi.project]
channels  = ["conda-forge"]
platforms = ["linux-64"]

[tool.pixi.system-requirements]
cuda = "12.9"                   # lock GPU capability

[tool.pixi.dependencies]
cuda-version = "12.9.*"         # pin the CUDA release line
pytorch      = "2.7.1"          # example; choose the build that matches your stack
flash-attn   = "2.8.3"          # example; channel build on Linux
numpy = "*"
pandas = "*"
scikit-learn = "*"
pyarrow = "*"
tqdm = "*"
accelerate = "*"
datasets = "*"
transformers = "*"
peft = "*"
bitsandbytes = "*"
trl = "*"
```

result:


![](https://raw.githubusercontent.com/ccss17/dotfiles/refs/heads/master/figure/pixi.gif)

![](https://raw.githubusercontent.com/ccss17/dotfiles/refs/heads/master/figure/micromamba.gif)


```bash
$ /usr/bin/time -p pixi install
...
real 30.26
user 79.93
sys 28.76
$ pixi project export conda-environment environment.yml
$ /usr/bin/time -p micromamba create -n dl -f environment.yml -y
...
real 53.79
user 94.04
sys 41.59
```

**Interpretation:** `pixi` finished **~43.7% faster** wall-clock (**30.26s vs 53.79s**). In this run it also used **less total CPU time** (`user+sys`: **108.69s vs 135.63s**), suggesting less overall work and/or more efficient parallel fetch/extract and solving. 


# Zsh Aliases 

| Alias | Expands to   |
| ----- | ------------ |
| `t`   | `tmux`       |
| `v`   | `vim`        |
| `cl`  | `clear;ls`   |
| `l`   | `ls`         |
| `ll`  | `ls -la`     |
| `g`   | `git`        |
| `mm`  | `micromamba` |
| `q`   | `exit`       |

# Global `.gitconfig` 

In your shell, `g` is an alias for `git`. In Git, we define short subcommands like `s = status`. **Result:** typing `g s` runs `git status`. Likewise, `g lg` → `git log --oneline --graph --decorate`, etc.

| Shortcut       | Expands to                             | Purpose                                 |
| -------------- | -------------------------------------- | --------------------------------------- |
| `g s`          | `git status`                           | Quick status.                           |
| `g d`          | `git diff`                             | Working tree diff.                      |
| `g a`          | `git add --all`                        | Stage everything (tracked + untracked). |
| `g cm "msg"`   | `git commit -m "msg"`                  | Message inline.                         |
| `g o <branch>` | `git checkout <branch>`                | Switch branch.                          |
| `g ob <new>`   | `git checkout -b <new>`                | Create + switch.                        |

# tmux Config


- Prefix: `Ctrl‑A` (instead of `Ctrl‑B`): `Ctrl‑A` is physically closer to the home row than `Ctrl‑B`. Lower hand travel → faster, less strain.
- Splits: mnemonic and ergonomic
    * **`\\` (backslash) → left/right split** 
    * **`-` (minus) → top/bottom split** 

- Pane navigation & resizing (no prefix)

    * **No‑prefix Nav**: Alt+`h/j/k/l` mirrors Vim movement across panes.
    * **Coarse resize**: Alt+`←/→`. Alt+`↑/↓`.

* **Cycle pane**: `Alt + o`
* **New window / Next / Prev**: `Alt + c / Alt + n / Alt + p`

# Vim Config 

* `<Up>/<Down>` → `:resize -5 / +5` (shrink/grow height)
* `<Left>/<Right>` → `:vertical resize -5 / +5` (shrink/grow width)
* `<C-h/j/k/l>` → `:wincmd h/j/k/l`
* `<C-p>` → `:NERDTreeToggle`
* `<C-s>` → `:w` (save)
* `<C-q>` → `:q` (quit)

Plugins (via **vim‑plug**):

* **`scrooloose/nerdtree`** File explorer with bookmarks; pairs with `<C-p>` toggle. 
* **`terryma/vim-multiple-cursors`** Multi‑edit with `Ctrl‑n` / `Ctrl‑x` / `Ctrl‑p` 
* **`scrooloose/nerdcommenter`** Smart comment/uncomment with `gc`/`gcc`.
* **`fidian/hexmode`** Toggle hex view with `:Hexmode`.
