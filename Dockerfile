FROM alpine
MAINTAINER Sven Dowideit <SvenDowideit@home.org.au>

ADD install /install

CMD /install/bootstrap.sh
