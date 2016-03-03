FROM alpine
MAINTAINER Sven Dowideit <SvenDowideit@home.org.au>

ADD bootstrap.sh /
ADD install /install

ENTRYPOINT ["/bootstrap.sh"]
