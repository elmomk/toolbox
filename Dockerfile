FROM testarchbase:latest as builder
RUN pacman --noconfirm -S base-devel git rustup  \
               core/openssl-1.1 binutils fakeroot gcc \
               sudo go core/libnsl core/python
RUN useradd -m build  && echo 'build ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build 
USER build
RUN rustup default stable
RUN git clone https://github.com/Morganamilo/paru.git /tmp/paru && cd /tmp/paru && cargo build --release && \
    sudo cp /tmp/paru/target/release/paru /usr/bin/paru
RUN paru -S terraform-ls fnm

FROM testarchbase:latest
COPY --from=builder /usr/bin/terraform-ls /usr/bin/terraform-ls
COPY --from=builder /tmp/paru/target/release/paru /usr/bin/paru
COPY --from=builder /usr/bin/fnm /usr/bin/fnm
RUN pacman -S --noconfirm stow starship neovim fzf bat exa git-delta mcfly\
               lazygit \
               fd ripgrep direnv thefuck zoxide \
               tmux zsh sudo \
               shellcheck flake8 cmake && rm -rf /var/cache/pacman/pkg/*
