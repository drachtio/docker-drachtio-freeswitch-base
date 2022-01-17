FROM debian:buster-slim

COPY ./files/* /tmp

RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done \
    && apt-get update && apt-get -y --quiet --allow-remove-essential upgrade \
    && apt-get install -y --quiet --no-install-recommends python lsof gcc g++ make cmake build-essential git autoconf automake  \
		curl telnet libtool libtool-bin libssl-dev libcurl4-openssl-dev libz-dev php php-common \
		iptables-dev libavformat-dev liblua5.1-0-dev libavfilter-dev libavcodec-dev libswresample-dev \
		libevent-dev libpcap-dev libxmlrpc-core-c3-dev markdown libjson-glib-dev lsb-release \
		libhiredis-dev gperf libspandsp-dev default-libmysqlclient-dev htop dnsutils \
		gnupg2 wget pkg-config ca-certificates libjpeg-dev libsqlite3-dev libpcre3-dev libldns-dev \
		libspeex-dev libspeexdsp-dev libedit-dev libtiff-dev yasm libswscale-dev haveged \
		libopus-dev libsndfile-dev libshout3-dev libmpg123-dev libmp3lame-dev libopusfile-dev \
		&& export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib \
		&& cd /tmp \
		&& tar xvfz SpeechSDK-Linux-1.19.0.tar.gz \
		&& cd SpeechSDK-Linux-1.19.0 \
		&& cp -r include /usr/local/include/MicrosoftSpeechSDK \
		&& cp -r lib/ /usr/local/lib/MicrosoftSpeechSDK \
		&& ln -s /usr/local/lib/MicrosoftSpeechSDK/x64/libMicrosoft.CognitiveServices.Speech.core.so /usr/local/lib/libMicrosoft.CognitiveServices.Speech.core.so \
		&& cd /usr/local/src \
		&& git config --global http.postBuffer 524288000  \
  	&& git config --global https.postBuffer 524288000 \
		&& git clone https://github.com/signalwire/freeswitch.git -b v1.10.5 \ 
		&& git clone https://github.com/warmcat/libwebsockets.git -b v3.2.3 \
		&& git clone https://github.com/drachtio/drachtio-freeswitch-modules.git -b v0.5.2 \ 
		&& git clone https://github.com/grpc/grpc -b master \
    && cd  /usr/local/src/grpc \
    && git checkout c66d2cc \
		&& cd /usr/local/src/freeswitch/libs \
		&& git clone https://github.com/freeswitch/spandsp.git -b master \ 
		&& git clone https://github.com/freeswitch/sofia-sip.git -b master \ 
		&& git clone https://github.com/dpirch/libfvad.git \ 
		&& git clone https://github.com/aws/aws-sdk-cpp.git -b 1.8.129 \ 
		&& git clone https://github.com/googleapis/googleapis -b master \
		&& cd googleapis \
		&& git checkout e9da6f8b469c52b83f900e820be30762e9e05c57 \
		&& cd .. \
		&& git clone https://github.com/awslabs/aws-c-common.git \ 
		&& cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork \
		&& cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_aws_transcribe \
		&& cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_azure_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_azure_transcribe \
		&& cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_lex /usr/local/src/freeswitch/src/mod/applications/mod_aws_lex \
		&& cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe \
		&& cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_tts /usr/local/src/freeswitch/src/mod/applications/mod_google_tts \
		&& cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow \
		&& cp /tmp/configure.ac.extra /usr/local/src/freeswitch/configure.ac \
		&& cp /tmp/Makefile.am.extra /usr/local/src/freeswitch/Makefile.am \
		&& cp /tmp/modules.conf.in.extra /usr/local/src/freeswitch/build/modules.conf.in \
		&& cp /tmp/modules.conf.vanilla.xml.extra /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml \
		&& cp /tmp/switch_rtp.c.patch /usr/local/src/freeswitch/src \ 
		&& sed -i -r -e 's/(.*AM_CFLAGS\))/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am \
		&& sed -i -r -e 's/(.*-std=c++11)/\1 -g -O0/g' /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork/Makefile.am \
		&& cd /usr/local/src/libwebsockets \
		&& mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && make install \
		&& cd /usr/local/src/freeswitch/libs/libfvad \
		&& autoreconf -i && ./configure && make -j 4 &&make install \
		&& cd /usr/local/src/freeswitch/libs/spandsp \
		&& ./bootstrap.sh && ./configure && make -j 4 && make install \
		&& cd /usr/local/src/freeswitch/libs/sofia-sip \
		&& ./bootstrap.sh && ./configure && make -j 4 && make install \
		&& cd /usr/local/src/freeswitch/libs/aws-c-common \
		&& mkdir -p build && cd build \
		&& cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter" \
		&& make -j 4 && make install \
		&& cd /usr/local/src/freeswitch/libs/aws-sdk-cpp \
		&& mkdir -p build && cd build \
		&& cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter" \
		&& make -j 4 && make install \
		&& cd /usr/local/src/grpc \
		&& git submodule update --init --recursive \
		&& mkdir -p cmake/build \
		&& cd cmake/build \
		&& cmake -DBUILD_SHARED_LIBS=ON -DgRPC_SSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ../.. \
		&& make -j 4 && make install \
		&& cd /usr/local/src/freeswitch/libs/googleapis \
		&& sed -i 's/\$fields/fields/' google/maps/routes/v1/route_service.proto \
		&& sed -i 's/\$fields/fields/' google/maps/routes/v1alpha/route_service.proto \
		&& LANGUAGE=cpp make -j 4 \
		&& cd /usr/local/src/freeswitch/src \
		&& patch < switch_rtp.c.patch \
		&& cd /usr/local/src/freeswitch \
		&& echo "bootstrap freeswitch" \
		&& ./bootstrap.sh -j \
		&& echo "configuring freeswitch" \
		&& ./configure --with-lws=yes --with-extra=yes \
		&& echo "building freeswitch" \
		&& make -j 4 \
		&& make install \
		&& cp /tmp/acl.conf.xml /usr/local/freeswitch/conf/autoload_configs \
		&& cp /tmp/event_socket.conf.xml /usr/local/freeswitch/conf/autoload_configs \
		&& cp /tmp/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs \
		&& cp /tmp/conference.conf.xml /usr/local/freeswitch/conf/autoload_configs \
		&& rm -Rf /usr/local/freeswitch/conf/dialplan/* \
		&& rm -Rf /usr/local/freeswitch/conf/sip_profiles/* \
		&& cp /tmp/mrf_dialplan.xml /usr/local/freeswitch/conf/dialplan \
		&& cp /tmp/mrf_sip_profile.xml /usr/local/freeswitch/conf/sip_profiles \
		&& cp /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml /usr/local/freeswitch/conf/autoload_configs \
		&& sed -i -e 's/global_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/global_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml \
		&& sed -i -e 's/outbound_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/outbound_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml \
	  && cd /usr/local && rm -Rf src share include games etc \
    && cd /usr && rm -Rf games include \
    && cd /usr/share && rm -Rf freeswitch man \
		&& rm -Rf /tmp/* \
    && rm -Rf /var/log/* \
    && rm -Rf /var/lib/apt/lists/* \
		&& rm /usr/local/freeswitch/lib/libfreeswitch.a 


ONBUILD ADD dialplan /usr/local/freeswitch/conf/dialplan
ONBUILD ADD sip_profiles /usr/local/freeswitch/conf/sip_profiles
