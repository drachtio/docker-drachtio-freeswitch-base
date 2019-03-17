FROM debian:jessie-slim

# comment out unecessary modules
COPY ./*.patch /

RUN apt-get update && apt-get -y --quiet --force-yes upgrade \
    && apt-get install -y --quiet --no-install-recommends wget curl git cmake automake autoconf libtool libtool-bin build-essential pkg-config zlib1g-dev libjpeg-dev sqlite3 libsqlite3-dev libcurl4-gnutls-dev libpcre3-dev libspeex-dev libspeexdsp-dev libedit-dev libssl-dev yasm libopus-dev libsndfile-dev ca-certificates \
    && apt-get update \
    && wget  --no-check-certificate  -O - https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add - \
    && echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends freeswitch-all \
    && cd /usr/local/src \
    && git clone https://github.com/davehorton/drachtio-freeswitch-modules.git \
    && git clone https://freeswitch.org/stash/scm/fs/freeswitch.git -bv1.6 freeswitch \
    && cd freeswitch/libs \
    && git clone https://github.com/warmcat/libwebsockets.git  -b v3.1.0 \
    && cd libwebsockets && mkdir build && cd build && cmake .. && make && make install \
    && cd /usr/local/src/freeswitch \
    && patch < /configure.ac.patch \
    && patch < /Makefile.am.patch \
    && cd build && patch < /modules.conf.in.patch \
    && cp modules.conf.in /  \
    && cd ../conf/vanilla/autoload_configs \
    && patch < /modules.conf.vanilla.xml.patch \
    && cp modules.conf.xml /  \
    && cd /usr/local/src/freeswitch \
    && rm /Makefile.am.patch \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork \
    && ./bootstrap.sh -j && ./configure --with-lws=yes \
    && make && make install \ 
    && cd /usr/local/freeswitch \
    && rm -Rf log conf htdocs fonts images sounds recordings \
    && apt-get purge -y --quiet --force-yes  --auto-remove autoconf automake autotools-dev build-essential cmake cpp cpp-4.9 \
    git java-common javascript-common manpages manpages-dev openjdk-7-jre-headless:amd64 curl wget \
    freeswitch-mod-callcenter \
    freeswitch-mod-cdr-mongodb freeswitch-mod-cdr-sqlite freeswitch-mod-cidlookup freeswitch-mod-dahdi-codec freeswitch-mod-db \
    freeswitch-mod-dialplan-asterisk freeswitch-mod-dingaling freeswitch-mod-distributor freeswitch-mod-easyroute freeswitch-mod-enum \
    freeswitch-mod-esf freeswitch-mod-fifo freeswitch-mod-fsk freeswitch-mod-g729 \
    freeswitch-mod-java freeswitch-mod-json-cdr freeswitch-mod-kazoo freeswitch-mod-lcr freeswitch-mod-memcache \
    freeswitch-mod-nibblebill freeswitch-mod-perl freeswitch-mod-portaudio freeswitch-mod-portaudio-stream freeswitch-mod-python \
    freeswitch-mod-redis freeswitch-mod-rss freeswitch-mod-rtmp freeswitch-mod-shell-stream freeswitch-mod-skinny \
    freeswitch-mod-skypopen freeswitch-mod-sms freeswitch-mod-snapshot freeswitch-mod-snom freeswitch-mod-sonar freeswitch-mod-soundtouch \
    freeswitch-mod-spandsp freeswitch-mod-spy freeswitch-mod-stress freeswitch-mod-theora freeswitch-mod-valet-parking freeswitch-mod-verto \
    freeswitch-mod-voicemail freeswitch-mod-voicemail-ivr freeswitch-mod-xml-cdr freeswitch-mod-xml-curl freeswitch-mod-xml-rpc \
    freeswitch-mod-xml-scgi perl perl-modules  liblocale-gettext-perl libtext-charwidth-perl libtext-iconv-perl libtext-wrapi18n-perl \
    erlang erlang-asn1 erlang-base erlang-common-test erlang-corba erlang-crypto \
    erlang-debugger erlang-dev erlang-dialyzer erlang-diameter erlang-edoc \
    erlang-eldap erlang-erl-docgen erlang-et erlang-eunit erlang-gs erlang-ic \
    erlang-inets erlang-megaco erlang-mnesia erlang-observer erlang-odbc \
    erlang-os-mon erlang-parsetools erlang-percept erlang-public-key \
    erlang-reltool erlang-runtime-tools erlang-snmp erlang-ssh erlang-ssl \
    erlang-syntax-tools erlang-test-server erlang-tools erlang-typer \
    erlang-webtool erlang-wx erlang-xmerl \
    freeswitch-mod-lua freeswitch-conf-insideout freeswitch-conf-sbc freeswitch-conf-softphone \
    freeswitch-conf-vanilla freeswitch-mod-loopback freeswitch-mod-snmp freeswitch-mod-unimrcp \
    freeswitch-mod-tts-commandline freeswitch-sounds-en-us-callie freeswitch-music-default \
    tcl tcl8.6 tk tk8.6 ucf x11-common libavahi-client3 libavahi-common-data libavahi-common3 gcc-4.8-base \
    && cd /usr/local && rm -Rf src share include games etc \
    && cd /usr && rm -Rf games include \
    && cd /usr/share && rm -Rf freeswitch \
    && rm /usr/local/freeswitch/lib/libfreeswitch.a \
    && rm -Rf /var/log/* \
    && rm -Rf /var/lib/apt/lists/* 

ADD conf.tar.gz /usr/local/freeswitch

RUN cp /modules.conf.xml /usr/local/freeswitch/conf/autoload_configs

RUN groupadd -r freeswitch && useradd -r -g freeswitch freeswitch 

ONBUILD ADD dialplan /usr/local/freeswitch/conf/dialplan
ONBUILD ADD sip_profiles /usr/local/freeswitch/conf/sip_profiles
