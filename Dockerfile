FROM debian:stretch-slim

COPY ./*.patch /
COPY ./vars_diff.xml /

RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done \
    && apt-get update && apt-get -y --quiet --allow-remove-essential upgrade \
    && apt-get install -y --quiet --no-install-recommends gnupg2 wget curl git lsb-release cmake automake autoconf libtool libtool-bin \
		build-essential pkg-config ca-certificates  libswscale-dev libldns-dev libmp3lame-dev \
    && apt-get update \
    && wget  --no-check-certificate  -O - https://files.freeswitch.org/repo/deb/debian-unstable/freeswitch_archive_g0.pub | apt-key add - \
    && echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list \
    && echo "deb-src http://files.freeswitch.org/repo/deb/debian-unstable/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list \
    && apt-get update \
    && apt-get -y --quiet --no-install-recommends build-dep freeswitch \
    && cd /usr/local/src \
    && git clone https://github.com/dpirch/libfvad.git \
    && git clone https://github.com/davehorton/drachtio-freeswitch-modules.git -b v0.2.5 \
    && git clone https://github.com/davehorton/freeswitch.git -bv1.10.1 freeswitch \
    && cd freeswitch/libs \
    && git clone https://github.com/warmcat/libwebsockets.git  -b v3.2.0 \
    && cd libwebsockets && mkdir -p build && cd build && cmake .. && make && make install \
    && cd /usr/local/src/freeswitch/src \
		&& patch < /switch_core_media_break_2833.patch \
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
		&& cp /vars_diff.xml /usr/local/freeswitch/conf \
    && apt-get purge -y --quiet --allow-remove-essential  --auto-remove --ignore-missing \
  	autoconf automake autotools-dev binutils build-essential bzip2 \
  	cmake cmake-data cpp cpp-6 dpkg-dev file g++ g++-6 gcc \
  	gcc-6 git git-man gnupg gnupg-agent gnupg2 libarchive13 libasan3 libassuan0 \
  	libatomic1 libcc1-0 libcilkrts5 libexpat1 libgcc-6-dev \
  	libgdbm3 libglib2.0-0 libgmp10 libgnutls30 libgomp1 libgssapi-krb5-2 \
  	libhogweed4 libicu57 libidn11 libidn2-0 libisl15 libitm1 libjsoncpp1 \
  	libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libksba8 libldap-2.4-2 \
  	libldap-common liblsan0 liblzo2-2 libmagic-mgc libmagic1 libmpc3 libmpfr4 \
  	libmpx2 libnettle6 libnpth0 libp11-kit0 \
  	libperl5.24 libprocps6 libpsl5 libquadmath0 libreadline7 librtmp1 libsasl2-2 \
  	libsasl2-modules-db libsigsegv2 libssh2-1 \
  	libstdc++-6-dev libtasn1-6 libtool libtool-bin libtsan0 libubsan0 \
  	libunistring0 libuv1 libxml2 linux-libc-dev m4 make patch perl	\
	  adwaita-icon-theme autopoint bison bsdmainutils ca-certificates-java \
	  dconf-gsettings-backend dconf-service debhelper default-jdk \
	  default-jdk-headless default-jre default-jre-headless dh-autoreconf \
	  dh-python dh-strip-nondeterminism dh-systemd doxygen ecj ecj-gcj ecj1 \
	  erlang-base erlang-dev fastjar flite1-dev fontconfig fontconfig-config \
	  fonts-dejavu-core gcj-6 gcj-6-jdk gcj-6-jre gcj-6-jre-headless gcj-6-jre-lib \
	  gcj-jdk gcj-jre gcj-jre-headless gettext gettext-base gir1.2-atk-1.0 \
	  gir1.2-freedesktop gir1.2-gdkpixbuf-2.0 gir1.2-glib-2.0 gir1.2-gtk-2.0 \
	  gir1.2-pango-1.0 gir1.2-rsvg-2.0 glib-networking glib-networking-common \
	  glib-networking-services gnome-icon-theme groff-base \
	  gsettings-desktop-schemas gtk-update-icon-cache hicolor-icon-theme \
	  icu-devtools imagemagick-6-common intltool-debian java-common ladspa-sdk \
	  libantlr-java libarchive-zip-perl \
	  libasyncns0 libatk-bridge2.0-0 libatk-wrapper-java libatk-wrapper-java-jni \
	  libatk1.0-0 libatk1.0-data libatk1.0-dev libatspi2.0-0 \
		libbison-dev libbluray1 \
	  libbsd-dev libbsd0 libcairo-gobject2 libcairo-script-interpreter2 \
	  libcairo2 libcairo2-dev libcap2 libcdt5 libcgraph6 libchromaprint1 \
	  libclang1-3.9 libcolord2 libcroco3 libcrystalhd3 \
	  libcups2 libcv-dev libcvaux-dev libdatrie1 libdb-dev \
	  libdb5.3-dev libdbus-1-3 libdc1394-22 libdc1394-22-dev libdconf1 \
	  libdjvulibre-dev libdjvulibre-text libdjvulibre21 libdrm2 libecj-java \
	  libecj-java-gcj libegl1-mesa libelf1 libepoxy0 \
	  libexif-dev libexif12 libexpat1-dev libfftw3-double3 \
	  libfile-stripnondeterminism-perl \
	  libfontconfig1 libfontconfig1-dev libfontenc1 \
	  libgbm1 libgcj-bc libgcj-common libgcj17 libgcj17-awt libgcj17-dev libgd3 \
	  libgdbm-dev libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgdk-pixbuf2.0-dev \
	  libgif7 libgirepository-1.0-1 libgl1-mesa-glx libglapi-mesa libglib2.0-bin \
	  libglib2.0-data libglib2.0-dev libgme0 libgraphite2-3 libgraphite2-dev \
	  libgraphviz-dev libgsm1 libgtk-3-0 libgtk-3-common libgtk2.0-0 \
	  libgtk2.0-common libgtk2.0-dev libgts-0.7-5 libgvc6 libgvc6-plugins-gtk \
	  libgvpr2 libharfbuzz-dev libharfbuzz-gobject0 libharfbuzz-icu0 libharfbuzz0b \
	  libhashkit-dev libhashkit2 libhighgui-dev libhiredis-dev libhiredis0.13 \
	  libice-dev libice6 libicu-dev libilmbase-dev libilmbase12 libjack-dev \
	  libjack0 libjbig-dev libjbig0 libjpeg-dev libjpeg62-turbo \
	  libjpeg62-turbo-dev libjs-jquery libjson-glib-1.0-0 libjson-glib-1.0-common \
	  libks liblcms2-2 liblcms2-dev libldap2-dev libldns-fs-dev libldns2-fs \
	  libllvm3.9 liblqr-1-0 liblqr-1-0-dev libltdl-dev libltdl7 liblua5.2-0 \
	  liblua5.2-dev liblzma-dev libmagickcore-6-arch-config \
	  libmagickcore-6-headers libmagickcore-6.q16-3 libmagickcore-6.q16-3-extra \
	  libmagickcore-6.q16-dev libmagickcore-dev libmagickwand-6.q16-3 \
	  libmemcached-dev libmemcached11 libmemcachedutil2 libmono-2.0-dev \
	  libmono-corlib4.5-cil libmono-csharp4.0c-cil libmono-microsoft-csharp4.0-cil \
	  libmono-posix4.0-cil libmono-security4.0-cil \
	  libmono-system-configuration4.0-cil libmono-system-core4.0-cil \
	  libmono-system-security4.0-cil libmono-system-xml4.0-cil \
	  libmono-system4.0-cil libmonosgen-2.0-1 libmonosgen-2.0-dev libmp3lame-dev \
	  libmp3lame0 libmpdec2 libmpg123-0 libmpg123-dev libnspr4 \
	  libnss3 libnuma1 libopencv-calib3d-dev libopencv-calib3d2.4v5 \
	  libopencv-contrib-dev libopencv-contrib2.4v5 libopencv-core-dev \
	  libopencv-core2.4v5 libopencv-dev libopencv-features2d-dev \
	  libopencv-features2d2.4v5 libopencv-flann-dev libopencv-flann2.4v5 \
	  libopencv-gpu-dev libopencv-gpu2.4v5 libopencv-highgui-dev \
	  libopencv-highgui2.4-deb0 libopencv-imgproc-dev libopencv-imgproc2.4v5 \
	  libopencv-legacy-dev libopencv-legacy2.4v5 libopencv-ml-dev \
	  libopencv-ml2.4v5 libopencv-objdetect-dev libopencv-objdetect2.4v5 \
	  libopencv-ocl-dev libopencv-ocl2.4v5 libopencv-photo-dev \
	  libopencv-photo2.4v5 libopencv-stitching-dev libopencv-stitching2.4v5 \
	  libopencv-superres-dev libopencv-superres2.4v5 libopencv-ts-dev \
	  libopencv-ts2.4v5 libopencv-video-dev libopencv-video2.4v5 \
	  libopencv-videostab-dev libopencv-videostab2.4v5 libopencv2.4-java \
	  libopencv2.4-jni libopenexr-dev libopenexr22 libopenjp2-7 libopenjp2-7-dev \
	  libopenmpt0 libout123-0 libpango-1.0-0 libpango1.0-dev \
	  libpangocairo-1.0-0 libpangoft2-1.0-0 libpangoxft-1.0-0 libpathplan4 \
	  libpci-dev libpci3 libpcre16-3 libpcre3-dev libpcre32-3 libpcrecpp0v5 \
	  libpcsclite1 libperl-dev libpipeline1 libpixman-1-0 libpixman-1-dev \
	  libpng-dev libpng16-16 libportaudio2 libportaudiocpp0 libpq-dev libpq5 \
	  libproxy1v5 libpthread-stubs0-dev libpulse0 libpython-all-dev libpython-dev \
	  libpython-stdlib libpython2.7 libpython2.7-dev libpython2.7-minimal \
	  libpython2.7-stdlib libpython3-stdlib libpython3.5-minimal \
	  libpython3.5-stdlib librabbitmq-dev librabbitmq4 libraw1394-11 \
	  libraw1394-dev libreadline-dev librest-0.7-0 librsvg2-2 librsvg2-common \
	  librsvg2-dev libsasl2-dev libsensors4 libsensors4-dev libshine3 libshout3 \
	  libshout3-dev libsilk-dev libsilk1 libsm-dev libsm6 libsnappy1v5 \
	  libsoundtouch-dev \
	  libsoundtouch1 libsoup-gnome2.4-1 libsoup2.4-1 \
	  libswscale-dev libswscale4 \
	  libtbb2 libthai-data libthai0 libtheora-dev libtheora0 libtiff5 libtiff5-dev \
	  libtiffxx5 libtimedate-perl libtinfo-dev libtwolame0 libudev-dev \
	  libusb-1.0-0 libv4l-0 libv4lconvert0 libv8-6.1 libv8-6.1-dev libva-drm1 \
	  libva-x11-1 libva1 libvdpau1 libvlc-dev libvlc5 libvlccore9 libvorbis-dev \
	  libvorbis0a libvorbisenc2 libvorbisfile3 libvpx4 libwavpack1 \
	  libwayland-client0 libwayland-cursor0 libwayland-egl1-mesa \
	  libwayland-server0 libwebp6 libwebpmux2 libwmf-dev libwmf0.2-7 libwrap0 \
	  libwrap0-dev libx11-6 libx11-data libx11-dev libx11-xcb1 libx264-148 \
	  libx265-95 libxapian30 libxau-dev libxau6 libxaw7 libxcb-dri2-0 \
	  libxcb-dri3-0 libxcb-glx0 libxcb-present0 libxcb-render0 libxcb-render0-dev \
	  libxcb-shape0 libxcb-shm0 libxcb-shm0-dev libxcb-sync1 libxcb-xfixes0 \
	  libxcb1 libxcb1-dev libxcomposite-dev libxcomposite1 libxcursor-dev \
	  libxcursor1 libxdamage-dev libxdamage1 libxdmcp-dev libxdmcp6 libxdot4 \
	  libxext-dev libxext6 libxfixes-dev libxfixes3 libxft-dev libxft2 libxi-dev \
	  libxi6 libxinerama-dev libxinerama1 libxkbcommon0 libxml2-dev libxml2-utils \
	  libxmu6 libxmuu1 libxpm4 libxrandr-dev libxrandr2 libxrender-dev libxrender1 \
	  libxshmfence1 libxt-dev libxt6 libxtst6 libxv1 libxvidcore4 libxxf86dga1 \
	  libxxf86vm1 libyaml-0-2 libyaml-dev libzvbi-common libzvbi0 man-db \
	  mime-support mono-4.0-gac mono-gac mono-mcs mono-runtime mono-runtime-common \
	  mono-runtime-sgen openjdk-8-jdk \
	  openjdk-8-jdk-headless openjdk-8-jre openjdk-8-jre-headless po-debconf \
	  portaudio19-dev python python-all python-all-dev python-dev python-minimal \
	  python2.7 python2.7-dev python2.7-minimal python3 python3-minimal python3.5 \
	  python3.5-minimal shared-mime-info signalwire-client-c ucf \
	  uuid-dev x11-common x11-utils x11proto-composite-dev x11proto-core-dev \
	  x11proto-damage-dev x11proto-fixes-dev x11proto-input-dev x11proto-kb-dev \
	  x11proto-randr-dev x11proto-render-dev x11proto-xext-dev \
	  x11proto-xinerama-dev xkb-data xorg-sgml-doctools xtrans-dev yasm \
    && apt-get install -y --quiet --no-install-recommends sqlite3 unixodbc libfreetype6 libcurl4-openssl-dev libedit2 libsndfile1 \
    && cd /usr/local/freeswitch \
    && rm -Rf conf/diaplans/* conf/sip_profiles/* htdocs fonts images \
    && cd /usr/local && rm -Rf src share include games etc \
    && cd /usr && rm -Rf games include \
    && cd /usr/share && rm -Rf freeswitch man \
    && rm /usr/local/freeswitch/lib/libfreeswitch.a \
    && rm -Rf /var/log/* \
    && rm -Rf /var/lib/apt/lists/* 

ONBUILD ADD dialplan /usr/local/freeswitch/conf/dialplan
ONBUILD ADD sip_profiles /usr/local/freeswitch/conf/sip_profiles
