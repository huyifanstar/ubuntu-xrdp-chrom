# 基础镜像
FROM ubuntu:18.04

# 环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    SIZE=1920x1080 \
    TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_CTYPE=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh:en_US:en

USER root
COPY xfce/  /root/
COPY windows/ /usr/share/fonts/windows/
COPY locale /etc/default/locale

# 设定密码
RUN echo 'root:$1$JNtOqGhO$ayinI1eVc0NPIukra3LFn0' | /usr/sbin/chpasswd -e && \
# apt源
sed -i 's/security.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list && sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list

# 安装
RUN apt-get -y update && \
    # Tools
    apt-get install -y  wget curl netcat vim inetutils-ping net-tools locales unzip  xrdp  ttf-mscorefonts-installer gedit gnupg xvfb openssh-server  language-pack-zh-hans   fonts-droid-fallback  && \
    # Google-Chrome
    cd /tmp/ &&   wget  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb  && \
    wget  https://dl.google.com/linux/linux_signing_key.pub && apt-key add /tmp/linux_signing_key.pub  && \
    apt-get install -y  -f  /tmp/google-chrome-stable_current_amd64.deb  && \
    # SSH
    mkdir -p /var/run/sshd && \
    sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    mkdir -p /root/.ssh && \
    #pinyin
    apt-get install -y fcitx-googlepinyin && \
    #Office
    apt-get install -y libreoffice libreoffice-l10n-zh-cn libreoffice-help-zh-cn && \
    # xrdp
    echo "xfce4-session" > ~/.xsession && \
    # xfce
    apt-get install -y xfce4 xfce4-terminal tango-icon-theme xfce4-notifyd && \
    apt-get purge -y pm-utils  xscreensaver* && \
    # clean
    apt-get -y clean &&  apt-get  autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /root


# 系统设置
RUN locale-gen zh_CN.UTF-8   && \ 
fc-cache -f -v  && \
cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime



# 在桌面创建chrom浏览器图标
COPY  startup.sh  /
COPY  fcitx/ /root/.config/fcitx/
COPY  google-chrome.desktop /root/Desktop/google-chrome.desktop
COPY  startwm.sh  /etc/xrdp/startwm.sh 
COPY  google-chrome/  /root/.config/google-chrome/

EXPOSE 22 3389

# 启动脚本
CMD ["/startup.sh"]
