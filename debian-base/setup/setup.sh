#!/bin/bash

set -ex

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy
apt-get install -qy sudo locales lsb-release wget curl gnupg2 less vim screen ripgrep tree unzip htop

SUITE=$(lsb_release -sc)

# install Systemd
apt-get install -y systemd systemd-sysv

# cleanup Systemd configuration
rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

# Postfix is needed to prevent excessive package pulls (Exim etc.) later
debconf-set-selections <<< "postfix postfix/mailname string 'localhost'"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Local only'"
apt-get install -qy postfix

# install SSH
apt-get install -y openssh-server

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries [0-9]\+/MaxAuthTries 32/g' /etc/ssh/sshd_config

# regenerate host key on container startup
mkdir /etc/systemd/system/sshd.service.d

cat << EOF > /etc/systemd/system/sshd.service.d/regenerate-host-keys.conf
[Service]
ExecStartPre=/bin/bash -c '/bin/rm /etc/ssh/ssh_host_* || :'
ExecStartPre=/usr/sbin/dpkg-reconfigure openssh-server
EOF

chmod 644 /etc/systemd/system/sshd.service.d/regenerate-host-keys.conf

# set the root password to admin
echo 'root:admin' | chpasswd

# install and configure PostgreSQL
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $SUITE-pgdg main" >> /etc/apt/sources.list

apt-get update -qy
apt-get install -qy postgresql

sed -i 's/^port.*$/port = 5432/g' /etc/postgresql/13/main/postgresql.conf
sed -i 's/md5$/trust/g' /etc/postgresql/13/main/pg_hba.conf

$(shopt -s dotglob ; cp /etc/skel/* /var/lib/postgresql/)

# system configuration: locales
echo 'de_DE.UTF-8 UTF-8' >> /etc/locale.gen
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
/usr/sbin/locale-gen

# global shell configuration
sed -i 's/# "\\e\[5~": history-search-backward/"\\e\[5~": history-search-backward/g' /etc/inputrc
sed -i 's/# "\\e\[6~": history-search-forward/"\\e\[6~": history-search-forward/g' /etc/inputrc

sed -i 's/SHELL=\/bin\/sh/SHELL=\/bin\/bash/g' /etc/default/useradd

sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /etc/skel/.bashrc

# global vim configuration
sed -i 's/"syntax on/syntax on/g' /etc/vim/vimrc
sed -i 's/"set background=dark/set background=dark/g' /etc/vim/vimrc

# global screen configuration
sed -i 's/#startup_message off/startup_message off/g' /etc/screenrc

# shell settings for root
cat << EOF >> /root/.bashrc
PS1='\[\033[01;33m\](container) \u@\h\[\033[01;34m\] \w \$\[\033[00m\] '

alias halt="systemctl poweroff"
alias sc=systemctl
alias jc=journalctl
alias l="ls --time-style=long-iso --color=always -laF"
alias ll="ls --time-style=long-iso --color=auto -laF"
alias ls="ls --time-style=long-iso --color=auto"
alias dt="date --utc '+%Y-%m-%d %H:%M:%S UTC'"
alias g="grep --exclude-dir .git --exclude-dir .svn --color=always"
alias o="less -r"
alias s="screen"
alias t="screen -dr || screen"
alias v="vim"
alias ..="cd .."
alias ...="cd ../.."
EOF

# vim settings for root
echo 'set mouse-=a' > /root/.vimrc

# Git settings for root
cat << EOF > /root/.gitconfig
[user]
  email = root@container
  name = Container Chef

[core]
  editor = vim
[log]
  date = iso
[alias]
  st = status
  co = checkout
  br = branch
  up = rebase
  ci = commit
  lol = log --graph --decorate --pretty=oneline --abbrev-commit --all
  rr = remote -v
  ac = !git add -A && git commit
EOF

# htop settings for root
mkdir -p /root/.config/htop

cat << EOF > /root/.config/htop/htoprc
fields=0 48 17 18 38 39 40 2 46 47 49 1
sort_key=46
sort_direction=1
hide_threads=1
hide_kernel_threads=1
hide_userland_threads=1
shadow_other_users=0
show_thread_names=0
show_program_path=1
highlight_base_name=0
highlight_megabytes=1
highlight_threads=1
tree_view=1
header_margin=1
detailed_cpu_time=0
cpu_count_from_zero=0
update_process_names=0
account_guest_in_cpu_meter=0
color_scheme=0
delay=15
left_meters=LeftCPUs Memory Swap
left_meter_modes=1 1 1
right_meters=RightCPUs Tasks LoadAverage Uptime
right_meter_modes=1 2 2 2
EOF


# services
systemctl enable ssh
systemctl enable postfix
systemctl enable postgresql
systemctl disable cron.service

# cleanup
apt-get autoremove -qy
apt-get clean -qy

rm -rf /tmp/* /var/tmp/*
