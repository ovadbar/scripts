# Installation #

Install kamailio and rtpengine on centos8.

## Kamailio ##

Kamailio (successor of former OpenSER and SER) is an Open Source SIP Server released under GPL, able to handle thousands of call setups per second. Kamailio can be used to build large platforms for VoIP and realtime communications – presence, WebRTC, Instant messaging and other applications.  Moreover, it can be easily used for scaling up SIP-to-PSTN gateways, PBX systems or media servers like Asterisk, FreeSWITCH or SEMS.

More info: <https://www.kamailio.org>

### Kamailio installation ###

```bash
dnf group install "Development Tools"
yum -y install redis mysql-server mysql mysql-devel
yum -y install mysql-libs make make-devel autoconf openssl-libs openssl-devel libcurl-devel libcurl libxml2 libxml2-devel pcre pcre-devel uuid libuuid libuuid-devel
yum -y install jansson jansson-devel libev libevent-devel
mkdir -p /usr/local/src/kamailio-5.3
cd /usr/local/src/kamailio-5.3
git clone --depth 1 --no-single-branch https://github.com/kamailio/kamailio kamailio
cd kamailio
git checkout -b 5.3 origin/5.3
make include_modules="db_mysql http_client http_async_client jansson tls uuid utils" cfg
make all
make install
make install-systemd-centos
```

## RTPENGINE ##

The Sipwise NGCP rtpengine is a proxy for RTP traffic and other UDP based media traffic. It's meant to be used with the Kamailio SIP proxy and forms a drop-in replacement for any of the other available RTP and media proxies.

More info: <https://github.com/sipwise/rtpengine>

### RTPENGINE installation ###

```bash
yum -y install dnf-plugins-core
yum config-manager --set-enabled PowerTools
dnf -y install https://download.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
dnf -y install --nogpgcheck https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
dnf -y install http://rpmfind.net/linux/epel/7/x86_64/Packages/s/SDL2-2.0.10-1.el7.x86_64.rpm
dnf -y install ffmpeg
dnf -y install ffmpeg-devel
yum -y install iptables-devel kernel-devel kernel-headers xmlrpc-c xmlrpc-c-client
yum -y install kernel-devel
yum -y install glib2 glib2-devel gcc zlib zlib-devel openssl openssl-devel pcre pcre-devel libcurl libcurl-devel xmlrpc-c-devel
yum -y install libevent-devel glib2-devel json-glib-devel gperf gperftools-libs gperftools gperftools-devel libpcap libpcap-devel git hiredis hiredis-devel redis perl-IPC-Cmd
yum -y install spandsp-devel spandsp
yum -y install epel-release
yum -y install elfutils-libelf-devel gcc-toolset-9-elfutils-libelf-devel
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
cd /usr/local/src
git clone https://github.com/sipwise/rtpengine.git
git checkout -b mr7.5.4 origin/mr7.5.4
cd /usr/local/src/rtpengine/daemon/
make
cp rtpengine /usr/sbin/rtpengine
cd /usr/local/src/rtpengine/iptables-extension
make all
cp libxt_RTPENGINE.so /usr/lib64/xtables/.
cd /usr/local/src/rtpengine/kernel-module
make
uname -a
cp xt_RTPENGINE.ko /lib/modules/4.18.0-147.8.1.el8_1.x86_64/extra/xt_RTPENGINE.ko
depmod -a
vi /etc/modules-load.d/rtpengine.conf
```

Add the following:

```bash
# load xt_RTPENGINE module
xt_RTPENGINE
```

```bash
modprobe xt_RTPENGINE
lsmod | grep xt_RTPENGINE
ls -l /proc/rtpengine/control
ls -l /proc/rtpengine/list
echo 'add 0' > /proc/rtpengine/control
iptables -I INPUT -p udp -j RTPENGINE --id 0
ip6tables -I INPUT -p udp -j RTPENGINE --id 0
```
