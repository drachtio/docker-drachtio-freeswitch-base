FROM debian:bullseye-slim

COPY ./files/* /tmp/

RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done \
    && export FREESWITCH_VERSION=v1.10.10 \
    && export SPAN_DSP_VERSION=0d2e6ac \
    && export GRPC_VERSION=v1.57.0 \
    && export GOOGLE_API_VERSION=29374574304f3356e64423acc9ad059fe43f09b5 \
    && export AWS_SDK_VERSION=1.8.129 \
    && export LWS_VERSION=v4.3.2 \
    && export MODULES_VERSION=v0.8.2 \
    && echo "freeswitch version to install is ${FREESWITCH_VERSION}" \
    && echo "drachtio modules version to install is ${MODULES_VERSION}" \
    && echo "GRPC version to install is ${GRPC_VERSION}" \
    && echo "GOOGLE_API_VERSION version to install is ${GOOGLE_API_VERSION}" \
    && echo "AWS_SDK_VERSION version to install is ${AWS_SDK_VERSION}" \
    && echo "LWS_VERSION version to install is ${LWS_VERSION}" \
    && apt-get update && apt-get -y --quiet --allow-remove-essential upgrade \
    && apt-get install -y --quiet --no-install-recommends \
    python-is-python3 lsof gcc g++ make cmake build-essential git autoconf automake default-mysql-client redis-tools \
    curl telnet libtool libtool-bin libssl-dev libcurl4-openssl-dev libz-dev systemd-coredump liblz4-tool \
    libxtables-dev libip6tc-dev libip4tc-dev  libiptc-dev libavformat-dev liblua5.1-0-dev libavfilter-dev libavcodec-dev libswresample-dev \
    libevent-dev libpcap-dev libxmlrpc-core-c3-dev markdown libjson-glib-dev lsb-release \
    libhiredis-dev gperf libspandsp-dev default-libmysqlclient-dev htop dnsutils gdb libtcmalloc-minimal4 \
    gnupg2 wget pkg-config ca-certificates libjpeg-dev libsqlite3-dev libpcre3-dev libldns-dev \
    libspeex-dev libspeexdsp-dev libedit-dev libtiff-dev yasm valgrind libswscale-dev haveged libre2-dev \
    libopus-dev libsndfile-dev libshout3-dev libmpg123-dev libmp3lame-dev libopusfile-dev libgoogle-perftools-dev \
		&& export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH \
		&& export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH \
		&& cd /tmp \
		&& tar xvfz SpeechSDK-Linux-1.31.0.tar.gz \
		&& cd SpeechSDK-Linux-1.31.0 \
		&& cp -r include /usr/local/include/MicrosoftSpeechSDK \
		&& cp -r lib/ /usr/local/lib/MicrosoftSpeechSDK \
		&& cp /usr/local/lib/MicrosoftSpeechSDK/arm64/libMicrosoft.*.so /usr/local/lib/ \
		&& ls -lrt /usr/local/lib/ \
		&& cd /usr/local/src \
		&& git config --global pull.rebase true \
		&& git clone https://github.com/signalwire/freeswitch.git -b ${FREESWITCH_VERSION} \ 
		&& git clone https://github.com/warmcat/libwebsockets.git -b ${LWS_VERSION} \
		&& git clone https://github.com/drachtio/drachtio-freeswitch-modules.git -b ${MODULES_VERSION} \ 
		&& git clone https://github.com/grpc/grpc -b master && cd grpc && git checkout ${GRPC_VERSION} && cd ..\
    && cd freeswitch/libs \
    && git clone https://github.com/drachtio/nuance-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/riva-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/soniox-asr-grpc-api.git -b main \
    && git clone https://github.com/drachtio/cobalt-asr-grpc-api.git -b main \
    && git clone https://github.com/freeswitch/spandsp.git && cd spandsp && git checkout ${SPAN_DSP_VERSION} && cd .. \
    && git clone https://github.com/freeswitch/sofia-sip.git -b master \
    && git clone https://github.com/dpirch/libfvad.git \
    && git clone https://github.com/aws/aws-sdk-cpp.git -b ${AWS_SDK_VERSION} \
    && git clone https://github.com/googleapis/googleapis -b master \
    && cd googleapis && git checkout ${GOOGLE_API_VERSION} && cd .. \
    && git clone https://github.com/awslabs/aws-c-common.git \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_aws_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_azure_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_azure_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_aws_lex /usr/local/src/freeswitch/src/mod/applications/mod_aws_lex \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_cobalt_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_cobalt_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_deepgram_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_deepgram_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_ibm_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_ibm_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nuance_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nuance_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_nvidia_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_nvidia_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_soniox_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_soniox_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_jambonz_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_jambonz_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_tts /usr/local/src/freeswitch/src/mod/applications/mod_google_tts \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow \
    && cp /tmp/configure.ac.extra /usr/local/src/freeswitch/configure.ac \
    && cp /tmp/Makefile.am.extra /usr/local/src/freeswitch/Makefile.am \
    && cp /tmp/modules.conf.in.extra /usr/local/src/freeswitch/build/modules.conf.in \
    && cp /tmp/modules.conf.vanilla.xml.extra /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml \
    && cp /tmp/avmd.conf.xml /usr/local/src/freeswitch/conf/vanilla/autoload_configs/avmd_conf.xml \
    && cp /tmp/switch_rtp.c.patch /usr/local/src/freeswitch/src \
    && cp /tmp/switch_core_media.c.patch /usr/local/src/freeswitch/src \
    && cp /tmp/mod_avmd.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_avmd \
    && cp /tmp/mod_httapi.c.patch /usr/local/src/freeswitch/src/mod/applications/mod_httapi \
    && cd /usr/local/src/freeswitch/src \
    && echo patching switch_rtp \
    && patch < switch_rtp.c.patch \
    && echo patching switch_core_media \
    && patch < switch_core_media.c.patch \
    && cd /usr/local/src/freeswitch/src/mod/applications/mod_avmd \
    && echo patching mod_avmd \
    && patch < mod_avmd.c.patch \
    && cd /usr/local/src/freeswitch/src/mod/applications/mod_httapi \
    && echo patching mod_httapi \
    && patch < mod_httapi.c.patch \
    && echo building lws \
    && cd /usr/local/src/libwebsockets \
    && mkdir -p build && cd build && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && make install \
    && cd /usr/local/src/freeswitch/libs/libfvad \
    && echo building libfvad \
    && autoreconf -i && ./configure && make -j 4 && make install \
    && echo building spandsp \
    && cd /usr/local/src/freeswitch/libs/spandsp \
    && ./bootstrap.sh && ./configure && make -j 4 && make install \
    && echo building sofia \
    && cd /usr/local/src/freeswitch/libs/sofia-sip \
    && ./bootstrap.sh && ./configure && make -j 4 && make install \
    && echo building aws-c-common \
    && cd /usr/local/src/freeswitch/libs/aws-c-common \
    && mkdir -p build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter" \
    && make -j 4 && make install \
    && echo building aws-sdk-cpp \
    && cd /usr/local/src/freeswitch/libs/aws-sdk-cpp \
    && git submodule update --init --recursive \
    && mkdir -p build && cd build \
    && cmake .. -DBUILD_ONLY="lexv2-runtime;transcribestreaming" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-Wno-unused-parameter" \
    && make -j 4 && make install \
    && find /usr/local/src/freeswitch/libs/aws-sdk-cpp/ -type f -name "*.pc" | xargs cp -t /usr/local/lib/pkgconfig/ \
    && echo building grpc \
    && cd /usr/local/src/grpc \
    && git submodule update --init --recursive \
    && mkdir -p cmake/build \
    && cd cmake/build \
    && cmake -DBUILD_SHARED_LIBS=ON -DgRPC_SSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo ../.. \
    && make -j 4 \
    && make install \
    && echo building googleapis \
    && cd /usr/local/src/freeswitch/libs/googleapis \
    && echo "Ref: https://github.com/GoogleCloudPlatform/cpp-samples/issues/113" \
    && sed -i 's/\$fields/fields/' google/maps/routes/v1/route_service.proto \
    && sed -i 's/\$fields/fields/' google/maps/routes/v1alpha/route_service.proto \
    && LANGUAGE=cpp make -j 4 \
    && echo "building protobuf stubs for Nuance asr" \
    && cd /usr/local/src/freeswitch/libs/nuance-asr-grpc-api \
    && LANGUAGE=cpp make \
    && echo "building protobuf stubs for nvidia riva asr" \
    && cd /usr/local/src/freeswitch/libs/riva-asr-grpc-api \
    && LANGUAGE=cpp make \
    && echo "building protobuf stubs for soniox asr" \
    && cd /usr/local/src/freeswitch/libs/soniox-asr-grpc-api \
    && LANGUAGE=cpp make \
    && echo "building protobuf stubs for cobalt asr" \
    && cd /usr/local/src/freeswitch/libs/cobalt-asr-grpc-api \
    && LANGUAGE=cpp make \
    && echo "building freeswitch" \
    && cd /usr/local/src/freeswitch \
    && ./bootstrap.sh -j \
    && ./configure --enable-tcmalloc=yes --with-lws=yes --with-extra=yes --with-aws=yes \
    && make -j 4 \
    && make install \
    && make cd-sounds-install cd-moh-install \
    && cp /tmp/acl.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && cp /tmp/event_socket.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && cp /tmp/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && cp /tmp/conference.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && rm -Rf /usr/local/freeswitch/conf/dialplan/* \
    && rm -Rf /usr/local/freeswitch/conf/sip_profiles/* \
    && cp /tmp/mrf_dialplan.xml /usr/local/freeswitch/conf/dialplan \
    && cp /tmp/mrf_sip_profile.xml /usr/local/freeswitch/conf/sip_profiles \
    && cp /usr/local/src/freeswitch/conf/vanilla/autoload_configs/modules.conf.xml /usr/local/freeswitch/conf/autoload_configs \
    && echo "setting codecs in vars.xml" \
		&& sed -i -e 's/global_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/global_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml \
		&& sed -i -e 's/outbound_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8/outbound_codec_prefs=PCMU,PCMA,OPUS,G722/g' /usr/local/freeswitch/conf/vars.xml \
    && echo "clearing out build files" \
	  && cd /usr/local && rm -Rf src share include games etc \
    && cd /usr && rm -Rf games include \
    && cd /usr/share && rm -Rf freeswitch man \
		&& rm -Rf /tmp/* \
    && rm -Rf /var/log/* \
    && rm -Rf /var/lib/apt/lists/*

ONBUILD ADD dialplan /usr/local/freeswitch/conf/dialplan
ONBUILD ADD sip_profiles /usr/local/freeswitch/conf/sip_profiles
