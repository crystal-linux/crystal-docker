FROM archlinux:latest
LABEL org.opencontainers.image.description="A work-in-progress, easy to use, set up and configure Arch Linux derivative"

RUN  pacman -Syu --noconfirm
RUN  pacman -S --needed --noconfirm pacman-contrib base-devel git wget

RUN  useradd -u 901 temp-user
RUN  mkdir /tmp/crystal-keyring
RUN  chown temp-user /tmp/crystal-keyring

USER temp-user
RUN  git clone https://github.com/crystal-linux/pkgbuild.crystal-keyring.git /tmp/crystal-keyring
RUN  pushd /tmp/crystal-keyring && makepkg --noconfirm -sp /tmp/crystal-keyring/PKGBUILD && popd

RUN git clone https://github.com/crystal-linux/pkgbuild.crystal-mirrorlist.git /tmp/crystal-mirrorlist
RUN pushd /tmp/crystal-mirrorlist && makepkg --noconfirm -sp /tmp/crystal-mirrorlist/PKGBUILD && popd

USER root
RUN  userdel temp-user
RUN  pacman --noconfirm -U /tmp/crystal-{keyring,mirrorlist}/*.zst
RUN  rm -rfv /tmp/crystal-{keyring,mirrorlist}

RUN  pacman-key --init
RUN  pacman-key --populate crystal

RUN  mv /etc/pacman.conf /etc/pacman.conf.old
RUN  wget https://repo.getcryst.al/pacman.conf
RUN  mv pacman.conf /etc/pacman.conf
RUN  sed -i 's/^CheckSpace/#CheckSpace/g' /etc/pacman.conf

RUN  mv /etc/os-release /etc/os-release.old

RUN  pacman -Syu --noconfirm
