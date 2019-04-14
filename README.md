# docker-drachtio-freeswitch-base

A very minimal Freeswitch 1.8 image (129 MB) designed for applications that use only dialplan or event socket.  No lua, javascript or other scripting languages are commpiled into this image, and many of the less frequently-used modules are also not provided.

This is intended to be a base image that other Dockerfiles will reference, and was primarily developed for use by [drachtio/drachtio-freeswitch-mrf:latest](https://hub.docker.com/r/drachtio/drachtio-freeswitch-mrf.

Via ONBBUILD directives a Dockerfile can reference this image and bring in their own dialplans and sip profiles to customize the install.

