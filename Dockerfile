# create docker file for archlinux
FROM archlinux:latest as builder
RUN pacman --noconfirm -Syyu base-devel git rustup  \
               core/openssl-1.1 binutils fakeroot gcc \
               sudo go core/libnsl core/python
RUN useradd -m build  && echo 'build ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build 
USER build
RUN rustup default stable
RUN git clone https://github.com/Morganamilo/paru.git /tmp/paru && cd /tmp/paru && cargo build --release && \
    sudo cp /tmp/paru/target/release/paru /usr/bin/paru
RUN paru -S terraform-ls fnm  azure-cli-bin
#
# copy paru to /usr/bin and install packages
FROM archlinux:latest
COPY --from=builder /tmp/paru/target/release/paru /usr/bin/paru
COPY --from=builder /usr/bin/fnm /usr/bin/fnm
COPY --from=builder /usr/bin/terraform-ls /usr/bin/terraform-ls
COPY --from=builder /usr/bin/az /usr/bin/az

RUN pacman -Syyu --noconfirm stow starship neovim fzf bat exa git-delta mcfly\
               lazygit kubectl terraform \
               fd ripgrep direnv thefuck zoxide \
               tmux zsh sudo \
               shellcheck flake8 cmake aws-cli-v2 && rm -rf /var/cache/pacman/pkg/*