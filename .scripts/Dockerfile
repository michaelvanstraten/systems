FROM --platform=linux/amd64 ubuntu:noble

RUN apt update && apt install curl git -y

WORKDIR /root
RUN git clone --bare https://github.com/joshmedeski/dotfiles.git /root/.git
RUN git config --unset core.bare
RUN git checkout --force
RUN rm -rf .git

WORKDIR /

ENTRYPOINT bash -c "$(curl -sS https://raw.githubusercontent.com/michaelvanstraten/dotfiles/master/.scripts/bootstrap.sh)"
