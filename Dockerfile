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
RUN paru -S fnm terraform-ls azure-cli-bin
# copy paru to /usr/bin and install packages
FROM archlinux:latest
COPY --from=builder /usr/bin/az /usr/bin/az
COPY --from=builder /usr/bin/terraform-ls /usr/bin/terraform-ls
COPY --from=builder /tmp/paru/target/release/paru /usr/bin/paru
COPY --from=builder /usr/bin/fnm /usr/bin/fnm
RUN pacman -Syyu --noconfirm stow starship neovim fzf bat exa git-delta mcfly\
                lazygit git \
                fd ripgrep direnv thefuck zoxide \
                tmux zsh sudo gcc go rustup unzip \
                kubectl terraform ansible helm aws-cli-v2 \
                shellcheck flake8 cmake && rm -rf /var/cache/pacman/pkg/*
RUN useradd -m devtainer && echo 'devtainer ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/devtainer
USER devtainer
RUN rustup default stable
