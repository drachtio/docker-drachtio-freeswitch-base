FROM debian:bullseye-slim

COPY ./files/* /tmp/

RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done \
    && apt-get update && apt-get -y --quiet --allow-remove-essential upgrade \
    && apt-get install -y --quiet --no-install-recommends \
    python-is-python3 lsof gcc g++ make cmake build-essential git autoconf automake default-mysql-client redis-tools \
    curl telnet libtool libtool-bin libssl-dev libcurl4-openssl-dev libz-dev liblz4-tool \
    libxtables-dev libip6tc-dev libip4tc-dev  libiptc-dev libavformat-dev liblua5.1-0-dev libavfilter-dev libavcodec-dev libswresample-dev \
    libevent-dev libpcap-dev libxmlrpc-core-c3-dev markdown libjson-glib-dev lsb-release libpq-dev php-dev \
    libhiredis-dev gperf libspandsp-dev default-libmysqlclient-dev htop dnsutils gdb libtcmalloc-minimal4 \
    gnupg2 wget pkg-config ca-certificates libjpeg-dev libsqlite3-dev libpcre3-dev libldns-dev libboost-all-dev \
    libspeex-dev libspeexdsp-dev libedit-dev libtiff-dev yasm libswscale-dev haveged libre2-dev \
    libopus-dev libsndfile-dev libshout3-dev libmpg123-dev libmp3lame-dev libopusfile-dev libgoogle-perftools-dev \
    && export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib \
		&& cd /tmp \
		&& tar xvfz SpeechSDK-Linux-1.34.0.tar.gz \
		&& cd SpeechSDK-Linux-1.34.0 \
		&& cp -r include /usr/local/include/MicrosoftSpeechSDK \
		&& cp -r lib/ /usr/local/lib/MicrosoftSpeechSDK \
		&& cp /usr/local/lib/MicrosoftSpeechSDK/x64/libMicrosoft.*.so /usr/local/lib/ \
		&& ls -lrt /usr/local/lib/ \
		&& cd /usr/local/src \
    && export CMAKE_VERSION=3.28.3 \
    && wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh \
    && chmod +x cmake-${CMAKE_VERSION}-linux-x86_64.sh \
    && ./cmake-${CMAKE_VERSION}-linux-x86_64.sh --skip-license --prefix=/usr/local \
    && rm -f cmake-${CMAKE_VERSION}-linux-x86_64.sh \
    && cmake --version \
    && cd /usr/local/src \
    && git config --global http.postBuffer 524288000  \
  	&& git config --global https.postBuffer 524288000 \
		&& git config --global pull.rebase true \
		&& git clone https://github.com/signalwire/freeswitch.git -b v1.10.10 \
		&& git clone https://github.com/warmcat/libwebsockets.git -b v4.3.3 \
		&& git clone https://github.com/jambonz/freeswitch-modules.git -b 1.0.8 \
		&& git clone https://github.com/grpc/grpc -b master && cd grpc && git checkout v1.57.0 && cd .. \
    && cd freeswitch/libs \
    && git clone https://github.com/drachtio/nuance-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/riva-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/soniox-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/cobalt-asr-grpc-api.git -b main \
    && git clone https://github.com/freeswitch/spandsp.git && cd spandsp && git checkout 0d2e6ac && cd .. \
    && git clone https://github.com/freeswitch/sofia-sip.git -b master \
    && git clone https://github.com/dpirch/libfvad.git \
    && git clone https://github.com/aws/aws-sdk-cpp.git -b 1.8.129 \
    && git clone https://github.com/googleapis/googleapis -b master \
    && cd googleapis && git checkout 29374574304f3356e64423acc9ad059fe43f09b5 && cd .. \
    && git clone https://github.com/awslabs/aws-c-common.git \
    && cp -r /usr/local/src/freeswitch-modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork \
    && cp -r /usr/local/src/freeswitch-modules/mod_aws_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_aws_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_assemblyai_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_assemblyai_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_azure_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_azure_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_aws_lex /usr/local/src/freeswitch/src/mod/applications/mod_aws_lex \
    && cp -r /usr/local/src/freeswitch-modules/mod_cobalt_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_cobalt_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_deepgram_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_deepgram_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_ibm_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_ibm_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_nuance_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nuance_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_nvidia_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nvidia_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_soniox_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_soniox_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_jambonz_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_jambonz_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow \
    && cp -r /usr/local/src/freeswitch-modules/mod_elevenlabs_tts /usr/local/src/freeswitch/src/mod/applications/mod_elevenlabs_tts \
    && cp -r /usr/local/src/freeswitch-modules/mod_whisper_tts /usr/local/src/freeswitch/src/mod/applications/mod_whisper_tts \
    && cp /tmp/configure.ac.extra /usr/local/src/freeswitch/configure.ac \
    && cp /tmp/Makefile.am.extra /usr/local/src/freeswitch/Makefile.am \
    && cp /tmp/modules.conf.in.extra /usr/local/src/freeswitch/build/modules.conf.in \
    && cp /tmp/modules.conf.vanilla.xml.extra /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml \
    && cp /tmp/avmd.conf.xml /usr/local/src/freeswitch/conf/vanilla/autoload_configs/avmd_conf.xml \
    && cp /tmp/switch_rtp.c.patch /usr/local/src/freeswitch/src \
    && cp /tmp/switch_core_media.c.patch /usr/local/src/freeswitch/src \
    && cp /tmp/mod_avmd.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_avmd \
    && cp /tmp/mod_httapi.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_httapi \
    && cp /tmp/switch_core.h /usr/local/src/freeswitch/src/include \
    && cp /tmp/switch_core_session.c /usr/local/src/freeswitch/src \
    && cd /usr/local/src/freeswitch/src \
    && patch < switch_rtp.c.patch \
    && patch < switch_core_media.c.patch \
    && cd /usr/local/src/freeswitch/src/mod/applications/mod_avmd \
    && patch < mod_avmd.c.patch \
    && cd /usr/local/src/freeswitch/src/mod/applications/mod_httapi \
    && patch < mod_httapi.c.patch \
    && cd /usr/local/src/freeswitch/src \
    && cp /tmp/switch_event.c . \
    && cd /usr/local/src/libwebsockets \
    && mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && make install \
    && cd /usr/local/src/freeswitch/libs/libfvad \
    && autoreconf -i && ./configure && make && make install \
    && cd /usr/local/src/freeswitch/libs/spandsp \
    && ./bootstrap.sh && ./configure && make && make install \
    && cd /usr/local/src/freeswitch/libs/sofia-sip \
    && ./bootstrap.sh && ./configure && make && make install \
    && cd /usr/local/src/freeswitch/libs/aws-c-common \
    && mkdir -p build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter" \
    && make && make install \
    && cd /usr/local/src/freeswitch/libs/aws-sdk-cpp \
    && git submodule update --init --recursive \
    && mkdir -p build && cd build \
    && cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter" \
    && make && make install \
    && find /usr/local/src/freeswitch/libs/aws-sdk-cpp/ -type f -name "*.pc" | xargs cp -t /usr/local/lib/pkgconfig/ \
    && echo building grpc \
    && cd /usr/local/src/grpc \
    && git submodule update --init --recursive \
    && mkdir -p cmake/build \
    && cd cmake/build \
    && cmake -DBUILD_SHARED_LIBS=ON -DgRPC_SSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ../.. \
    && make \
    && make install \
    && cd /usr/local/src/freeswitch/libs/googleapis \
    && echo "Ref: https://github.com/GoogleCloudPlatform/cpp-samples/issues/113" \
    && sed -i 's/\$fields/fields/' google/maps/routes/v1/route_service.proto \
    && sed -i 's/\$fields/fields/' google/maps/routes/v1alpha/route_service.proto \
    && LANGUAGE=cpp make \
    && cd /usr/local/src/freeswitch/libs/nuance-asr-grpc-api \
    && LANGUAGE=cpp make \
    && cd /usr/local/src/freeswitch/libs/riva-asr-grpc-api \
    && LANGUAGE=cpp make \
    && cd /usr/local/src/freeswitch/libs/soniox-asr-grpc-api \
    && LANGUAGE=cpp make \
    && cd /usr/local/src/freeswitch/libs/cobalt-asr-grpc-api \
    && LANGUAGE=cpp make \
    && sed -i '/#ifndef cJSON_AS4CPP__h/i #ifndef cJSON__h\n#define cJSON__h' /usr/local/include/aws/core/external/cjson/cJSON.h \
    && echo '#endif' >> /usr/local/include/aws/core/external/cjson/cJSON.h \
    && cd /usr/local/src/freeswitch \
    && ./bootstrap.sh -j \
    && ./configure --enable-tcmalloc=yes --with-lws=yes --with-extra=yes --with-aws=yes \
    && make \
    && make install \
    && make cd-sounds-install cd-moh-install \
    && cp /tmp/acl.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && cp /tmp/event_socket.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && cp /tmp/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && cp /tmp/conference.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && rm -Rf /usr/local/freeswitch/conf/dialplan/* \
    && rm -Rf /usr/local/freeswitch/conf/sip_profiles/* \
    && cp /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml /usr/local/freeswitch/conf/autoload_configs \
		&& sed -i -e 's/global_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/global_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml \
		&& sed -i -e 's/outbound_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/outbound_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml \
	  && cd /usr/local && rm -Rf src share include games etc \
    && cd /usr && rm -Rf games include \
    && cd /usr/share && rm -Rf freeswitch man \
		&& rm -Rf /tmp/* \
    && rm -Rf /var/log/* \
    && rm -Rf /var/lib/apt/lists/*

ONBUILD ADD dialplan /usr/local/freeswitch/conf/dialplan
ONBUILD ADD sip_profiles /usr/local/freeswitch/conf/sip_profiles
