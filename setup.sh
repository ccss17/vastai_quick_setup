#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "[!] Failed at line $LINENO: $BASH_COMMAND" >&2' ERR
export DEBIAN_FRONTEND=noninteractive

# ------------------------- base packages -------------------------
echo "[+] Installing base packages (single apt txn)"
apt-get update -qq
apt-get -y -qq install --no-install-recommends git zsh vim tmux unzip curl wget fd-find bat time nvtop python3.12-dev build-essential tree

# ------------------------- resolve versions (exactly like yours) -------------------------
# Avoid curl (23) by disabling pipefail only around these pipelines
set +o pipefail
HYPERFINE_VER=$(curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest     | grep tag_name | cut -d '"' -f 4)
LSD_VER=$(        curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest          | grep tag_name | cut -d '"' -f 4)
BTOP_VER=$(       curl -s https://api.github.com/repos/aristocratos/btop/releases/latest   | grep tag_name | cut -d '"' -f 4)
GOTOP_VER=$(      curl -s https://api.github.com/repos/xxxserxxx/gotop/releases/latest     | grep tag_name | cut -d '"' -f 4)
set -o pipefail

# Construct your exact URLs
HYPERFINE_DEB_URL="https://github.com/sharkdp/hyperfine/releases/download/${HYPERFINE_VER}/hyperfine_${HYPERFINE_VER:1}_amd64.deb"
LSD_DEB_URL="https://github.com/lsd-rs/lsd/releases/download/${LSD_VER}/lsd-musl_${LSD_VER:1}_amd64.deb"
BTOP_TBZ_URL="https://github.com/aristocratos/btop/releases/download/${BTOP_VER}/btop-x86_64-linux-musl.tbz"
GOTOP_DEB_URL="https://github.com/xxxserxxx/gotop/releases/download/${GOTOP_VER}/gotop_${GOTOP_VER}_linux_amd64.deb"

# ------------------------- paths -------------------------
WORK=/tmp/bootstrap
mkdir -p "$WORK" "$HOME/.vim/autoload"
HYPERFINE_DEB="$WORK/hyperfine.deb"
LSD_DEB="$WORK/lsd.deb"
BTOP_TBZ="$WORK/btop-x86_64-linux-musl.tbz"
GOTOP_DEB="$WORK/gotop.deb"
PLUG_VIM="$HOME/.vim/autoload/plug.vim"
OMZ_SH="$WORK/install_ohmyzsh.sh"
UV_SH="$WORK/install_uv.sh"
MM_TAR="$WORK/micromamba.tar"

# ------------------------- parallel downloads -------------------------
echo "[+] Parallel downloading artifacts (incl. plug.vim, OMZ, uv, micromamba)"
curl -sSfL -Z --parallel-max 10 \
  -o "$HYPERFINE_DEB" "$HYPERFINE_DEB_URL" \
  -o "$LSD_DEB"      "$LSD_DEB_URL" \
  -o "$BTOP_TBZ"     "$BTOP_TBZ_URL" \
  -o "$GOTOP_DEB"    "$GOTOP_DEB_URL" \
  -o "$PLUG_VIM"     "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" \
  -o "$OMZ_SH"       "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" \
  -o "$UV_SH"        "https://astral.sh/uv/install.sh" \
  -o "$MM_TAR"       "https://micro.mamba.pm/api/micromamba/linux-64/latest"


# Quick sanity checks (optional but helpful)
for deb in "$HYPERFINE_DEB" "$LSD_DEB" "$GOTOP_DEB"; do
  dpkg-deb -I "$deb" >/dev/null 2>&1 || { echo "[!] Invalid deb: $deb"; exit 3; }
done

# ------------------------- install debs (your flow) -------------------------
echo "[+] Installing hyperfine, lsd, gotop via dpkg -i (fix deps with apt -f if needed)"
dpkg -i "$HYPERFINE_DEB" || apt-get -y -qq -f install
dpkg -i "$LSD_DEB"       || apt-get -y -qq -f install
dpkg -i "$GOTOP_DEB"     || apt-get -y -qq -f install

# ------------------------- btop -------------------------
echo "[+] Installing btop from tbz"
tar -xjf "$BTOP_TBZ" -C "$WORK"
make -C "$WORK/btop" -j"$(nproc)" install


# ------------------------- uv (save-then-run; same official URL) -------------------------
echo "[+] Installing uv"
sh "$UV_SH"

# ------------------------- oh-my-zsh -------------------------
echo "[+] Installing oh-my-zsh"
sh "$OMZ_SH" --unattended || true
git clone --depth=1 -q https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/plugins/zsh-autosuggestions || true
git clone --depth=1 -q https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" || true

# ------------------------- micromamba -------------------------
echo "[+] Installing micromamba"
mkdir -p "$WORK/mm_extract"
tar -xvf "$MM_TAR" -C "$WORK/mm_extract" bin/micromamba
mkdir -p "$HOME/.local/bin"
mv "$WORK/mm_extract/bin/micromamba" "$HOME/.local/bin/micromamba"
rm -rf "$WORK/mm_extract"

# init micromamba (idempotent)
export MAMBA_ROOT_PREFIX="$HOME/micromamba"
export MAMBA_EXE="$HOME/.local/bin/micromamba"
eval "$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"
"$MAMBA_EXE" shell init -s zsh -r "$MAMBA_ROOT_PREFIX"
micromamba config append channels conda-forge
micromamba config set channel_priority strict


# ------------------------- dotfiles -------------------------
echo "[+] Linking dotfiles & appending rc snippets"
for file_path in $(find "$PWD" -type f -maxdepth 1 -name ".*"); do
  fname=$(basename "$file_path")
  if ! [ "$fname" = ".zshrc" ] && ! [ "$fname" = ".gdbinit" ] && ! [ "$fname" = ".gitconfig" ]; then
    ln -sf "$file_path" "$HOME/$fname"
  fi
done
cat .gitconfig       >> "$HOME/.gitconfig"
cat .zshrc_vastai    >> "$HOME/.zshrc"
cat .p10k_vastai.zsh >> "$HOME/.p10k.zsh"

# ------------------------- tmux 2.x tweak -------------------------
TMUX_VERSION=$(tmux -V | cut -d' ' -f2)
if [[ "${TMUX_VERSION:0:1}" == "2" ]]; then
  sed -i 's/bind \\ split-window -h/bind \\ split-window -h/g' "$HOME/.tmux.conf"
fi

# ------------------------- vim-plug -------------------------
echo "[+] Installing vim-plug plugins (sync)"
vim +'PlugInstall --sync' +qall

# ------------------------- locale (append) -------------------------
echo 'LANG="en_US.UTF-8"' >> /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

echo "[+] Done."