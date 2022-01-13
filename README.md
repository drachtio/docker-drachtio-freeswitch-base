# docker-drachtio-freeswitch-base

A Freeswitch 1.10.5 image designed that includes all the plugins found [here](https://github.com/drachtio/drachtio-freeswitch-modules)

This is intended to be a base image that other Dockerfiles will reference, and was primarily developed for use by [drachtio/drachtio-freeswitch-mrf:latest](https://hub.docker.com/r/drachtio/drachtio-freeswitch-mrf)-based applications as well as [jambonz](https://jambonz.org)

Via ONBBUILD directives a Dockerfile can reference this image and bring in their own dialplans and sip profiles to customize the install.

