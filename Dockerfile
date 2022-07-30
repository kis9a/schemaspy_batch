FROM openjdk:17-alpine3.14

ARG APP_PATH=/app
WORKDIR /

USER root

ENV LC_ALL=C
ENV APP_PATH=${APP_PATH}
ENV MYSQL_VERSION=8.0.28
ENV POSTGRESQL_VERSION=42.3.5
ENV SCHEMASPY_VERSION=6.1.0
ENV SCHEMASPY_DRIVERS=/drivers_inc
ENV SCHEMASPY_OUTPUT=${APP_PATH}/outputs

# copy sources
COPY . ${APP_PATH}

# install pkgs
RUN apk update && \
   apk add --no-cache \
   bash \
   jq \
   curl \
   unzip \
   mysql-client \
   binutils \
   alpine-baselayout \
   apk-tools \
   coreutils \
   graphviz \
   fontconfig

# install schemaspy
RUN mkdir -p /usr/local/lib/schemaspy && \
  curl -sLJ https://github.com/schemaspy/schemaspy/releases/download/v${SCHEMASPY_VERSION}/schemaspy-${SCHEMASPY_VERSION}.jar \
  > /usr/local/lib/schemaspy/schemaspy.jar

# install drivers
RUN adduser java -h / -D && \
    set -x && \
    fc-cache -fv && \
    mkdir -p ${SCHEMASPY_DRIVERS} && \
    cd ${SCHEMASPY_DRIVERS} && \
    curl -JLO http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/$MYSQL_VERSION/mysql-connector-java-$MYSQL_VERSION.jar && \
    curl -JLO http://search.maven.org/remotecontent?filepath=org/postgresql/postgresql/$POSTGRESQL_VERSION/postgresql-$POSTGRESQL_VERSION.jar && \
    mkdir -p ${SCHEMASPY_OUTPUT} && \
    chown -R java ${SCHEMASPY_DRIVERS} && \
    chown -R java ${SCHEMASPY_OUTPUT}

# install glibc
ENV GLIBC_VER=2.34-r0
RUN curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
  apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk

# install awscliv2
RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
  unzip -q awscliv2.zip && \
  aws/install

# add assets
ADD docker/open-sans.tar.gz /usr/share/fonts/
ADD docker/schemaspy.sh /usr/local/bin/schemaspy

# cmd
CMD ["tail", "-f", "/dev/null"]
