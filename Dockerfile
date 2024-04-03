FROM debian:bullseye-slim

SHELL ["/bin/bash", "-c"]

ENV PATH="/usr/local/bin:${PATH}"

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
		&& cd /usr/local/src \
    && which cmake && cmake --version \
    && apt-get remove --purge -y cmake \
    && export CMAKE_VERSION=3.28.3 \
    && ARCH=$(uname -m) && CMAKE_ARCH=$(case "$ARCH" in x86_64) echo "linux-x86_64" ;; arm64|aarch64) echo "linux-aarch64" ;; *) echo "Unsupported architecture: $ARCH" && exit 1 ;; esac) \
    && echo "Preparing to build cmake for ${ARCH}" \
    && wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-${CMAKE_ARCH}.sh \
    && chmod +x cmake-${CMAKE_VERSION}-${CMAKE_ARCH}.sh \
    && ./cmake-${CMAKE_VERSION}-${CMAKE_ARCH}.sh --skip-license --prefix=/usr/local \
    && ln -s /usr/local/bin/cmake /usr/bin/cmake \
    && rm -f cmake-${CMAKE_VERSION}-${CMAKE_ARCH}.sh \
    && cmake --version \
    && echo "copy azure speech sdk" \
    && ARCH=$(uname -m) && AZURE_ARCH=$(case "$ARCH" in x86_64) echo "x86" ;; arm64|aarch64) echo "arm64" ;; *) echo "Unsupported architecture: $ARCH" && exit 1 ;; esac) \
    && export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib \
		&& cd /tmp \
		&& tar xvfz SpeechSDK-Linux-1.36.0.tar.gz \
		&& cd SpeechSDK-Linux-1.36.0 \
		&& cp -r include /usr/local/include/MicrosoftSpeechSDK \
		&& cp -r lib/ /usr/local/lib/MicrosoftSpeechSDK \
    && echo "copying azure speech sdk from usr/local/lib/MicrosoftSpeechSDK/${AZURE_ARCH}/libMicrosoft.*.so" \
		&& cp /usr/local/lib/MicrosoftSpeechSDK/${AZURE_ARCH}/libMicrosoft.*.so /usr/local/lib/ \
		&& ls -lrt /usr/local/lib/ \
    && cd /usr/local/src \
    && git config --global http.postBuffer 524288000  \
  	&& git config --global https.postBuffer 524288000 \
		&& git config --global pull.rebase true \
		&& git clone https://github.com/signalwire/freeswitch.git -b v1.10.10 \
		&& git clone https://github.com/warmcat/libwebsockets.git -b v4.3.3 \
		&& git clone https://github.com/jambonz/freeswitch-modules.git -b main \
		&& git clone https://github.com/grpc/grpc -b master && cd grpc && git checkout v1.57.0 && cd .. \
    && cd freeswitch/libs \
    && git clone https://github.com/drachtio/nuance-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/riva-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/soniox-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/cobalt-asr-grpc-api.git -b main \
    && git clone https://github.com/freeswitch/spandsp.git && cd spandsp && git checkout 0d2e6ac && cd .. \
    && git clone https://github.com/freeswitch/sofia-sip.git -b master \
    && git clone https://github.com/dpirch/libfvad.git \
    && git clone https://github.com/aws/aws-sdk-cpp.git -b 1.11.283 \
    && git clone https://github.com/googleapis/googleapis -b master \
    && cd googleapis && git checkout d81d0b9e6993d6ab425dff4d7c3d05fb2e59fa57 && cd .. \
    && git clone https://github.com/awslabs/aws-c-common.git \
    && cp -r /usr/local/src/freeswitch-modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork \
    && cp -r /usr/local/src/freeswitch-modules/mod_aws_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_aws_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_assemblyai_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_assemblyai_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_azure_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_azure_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_azure_tts /usr/local/src/freeswitch/src/mod/applications/mod_azure_tts \
    && cp -r /usr/local/src/freeswitch-modules/mod_aws_lex /usr/local/src/freeswitch/src/mod/applications/mod_aws_lex \
    && cp -r /usr/local/src/freeswitch-modules/mod_cobalt_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_cobalt_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_deepgram_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_deepgram_transcribe \
    && cp -r /usr/local/src/freeswitch-modules/mod_dub /usr/local/src/freeswitch/src/mod/applications/mod_dub \
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
    && cp /tmp/ax_check_compile_flag.m4 /usr/local/src/freeswitch/ax_check_compile_flag.m4 \
    && cp /tmp/modules.conf.in.extra /usr/local/src/freeswitch/build/modules.conf.in \
    && cp /tmp/modules.conf.vanilla.xml.extra /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml \
    && cp /tmp/avmd.conf.xml /usr/local/src/freeswitch/conf/vanilla/autoload_configs/avmd_conf.xml \
    && cp /tmp/switch_rtp.c.patch /usr/local/src/freeswitch/src \
    && cp /tmp/switch_core_media.c.patch /usr/local/src/freeswitch/src \
    && cp /tmp/mod_avmd.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_avmd \
    && cp /tmp/mod_httapi.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_httapi \
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
    && cd /usr/local/src/freeswitch/libs/libfvad && cp /tmp/configure.ac.libfvad configure.ac \
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
    && cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_FLAGS="-Wno-unused-parameter -Wno-error=nonnull -Wno-error=deprecated-declarations -Wno-error=uninitialized -Wno-error=maybe-uninitialized" \
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
    && LANGUAGE=cpp FLAGS+='--experimental_allow_proto3_optional' make \
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
