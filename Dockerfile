FROM debian:jessie

# comment out unecessary modules
COPY ./modules.conf.patch /

RUN apt-get update && apt-get -y --quiet --force-yes upgrade \
    && apt-get install -y --quiet --no-install-recommends wget curl git automake autoconf libtool libtool-bin build-essential pkg-config zlib1g-dev libjpeg-dev sqlite3 libsqlite3-dev libcurl4-gnutls-dev libpcre3-dev libspeex-dev libspeexdsp-dev libedit-dev libssl-dev yasm libopus-dev libsndfile-dev ca-certificates \
    && apt-get update \
    && wget  --no-check-certificate  -O - https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add - \
    && echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends freeswitch-all \
    && cd /usr/local/src \
    && git clone https://freeswitch.org/stash/scm/fs/freeswitch.git -bv1.6 freeswitch \
    && cd freeswitch \
    && ./bootstrap.sh -j \
    && patch < /modules.conf.patch \
    && ./configure \
    && make \
    && make install \ 
    && make sounds-install moh-install \ 
    && cd /usr/local/freeswitch \
    && rm -Rf log conf htdocs font recordings \
    && rm -Rf /usr/local/src/freeswitch \ 
    && apt-get purge -y --quiet --force-yes  --auto-remove autoconf automake autotools-dev build-essential cpp cpp-4.9 \
    git java-common javascript-common manpages manpages-dev openjdk-7-jre-headless:amd64 curl wget \
    freeswitch-mod-callcenter freeswitch-mod-cdr-csv \
    freeswitch-mod-cdr-mongodb freeswitch-mod-cdr-sqlite freeswitch-mod-cidlookup freeswitch-mod-dahdi-codec freeswitch-mod-db \
    freeswitch-mod-dialplan-asterisk freeswitch-mod-dingaling freeswitch-mod-distributor freeswitch-mod-easyroute freeswitch-mod-enum \
    freeswitch-mod-esf freeswitch-mod-fifo freeswitch-mod-fsk freeswitch-mod-fsv freeswitch-mod-g729 \
    freeswitch-mod-java freeswitch-mod-json-cdr freeswitch-mod-kazoo freeswitch-mod-lcr freeswitch-mod-lua freeswitch-mod-memcache \
    freeswitch-mod-nibblebill freeswitch-mod-perl freeswitch-mod-portaudio freeswitch-mod-portaudio-stream freeswitch-mod-python \
    freeswitch-mod-redis freeswitch-mod-rss freeswitch-mod-rtc freeswitch-mod-rtmp freeswitch-mod-shell-stream freeswitch-mod-skinny \
    freeswitch-mod-skypopen freeswitch-mod-sms freeswitch-mod-snapshot freeswitch-mod-snom freeswitch-mod-sonar freeswitch-mod-soundtouch \
    freeswitch-mod-spandsp freeswitch-mod-spy freeswitch-mod-stress freeswitch-mod-theora freeswitch-mod-valet-parking freeswitch-mod-verto \
    freeswitch-mod-voicemail freeswitch-mod-voicemail-ivr freeswitch-mod-xml-cdr freeswitch-mod-xml-curl freeswitch-mod-xml-rpc \
    freeswitch-mod-xml-scgi perl perl-modules  liblocale-gettext-perl libtext-charwidth-perl libtext-iconv-perl libtext-wrapi18n-perl \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -Rf /var/log/* \
    && rm -Rf /var/lib/apt/lists/* 

ADD conf.tar.gz /usr/local/freeswitch

RUN groupadd -r freeswitch && useradd -r -g freeswitch freeswitch 

ONBUILD ADD dialplan /usr/local/freeswitch/conf/dialplan
ONBUILD ADD sip_profiles /usr/local/freeswitch/conf/sip_profiles

RUN chown -R freeswitch:freeswitch /usr/local/freeswitch

