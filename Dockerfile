FROM openjdk:8-jdk-alpine
#FROM ubuntu

LABEL maintainer=trellixa@gmail.com

# Define environment variables.
ENV BASE_INSTALL_DIR=/opt \
   MULE_HOME=/opt/mule \
   MULE_REPOSITORY=https://repository-master.mulesoft.org/nexus/content/repositories/releases \
   MULE_USER=mule \
   MULE_VERSION=4.2.1


#Intall custom glibc library needed by the Tunaki Java Wrapper
RUN set -ex && \
    apk -U upgrade && \
    apk --no-cache add bash

ADD ./mule/mule-standalone-${MULE_VERSION}.tar.gz.md5 .
# Download and install mule-standalone
RUN set -ex && \
    wget ${MULE_REPOSITORY}/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz && \
    echo "`cat ./mule-standalone-${MULE_VERSION}.tar.gz.md5`  mule-standalone-${MULE_VERSION}.tar.gz" | md5sum -c && \ 
    tar -xzf mule-standalone-${MULE_VERSION}.tar.gz -C ${BASE_INSTALL_DIR} && \ 
    rm mule-standalone-${MULE_VERSION}.tar.gz mule-standalone-${MULE_VERSION}.tar.gz.md5 && \ 
    ln -s ${BASE_INSTALL_DIR}/mule-standalone-${MULE_VERSION} ${MULE_HOME}
    
# Create Mule group and user
RUN addgroup -S ${MULE_USER} && adduser -S -g "Mule runtime user" ${MULE_USER} -G ${MULE_USER} && \
    chown -R ${MULE_USER}:${MULE_USER} ${BASE_INSTALL_DIR}/mule-standalone-${MULE_VERSION}

# Default user
USER ${MULE_USER}

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Define working directory.
WORKDIR ${MULE_HOME}

# Default http port
EXPOSE 8081

# Run mule in console mode (needed by Docker)
#ENTRYPOINT ["./bin/mule"]
#CMD [""]

# Run mule in console mode (needed by Docker)
CMD [ "/bin/bash" ]
