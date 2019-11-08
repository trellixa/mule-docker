FROM openjdk:8-jdk-alpine

LABEL maintainer=trellixa@gmail.com

# Define environment variables.
ENV BASE_INSTALL_DIR=/opt \
   MULE_BASE=/opt/mule \
   MULE_HOME=/opt/mule \
   MULE_REPOSITORY=https://repository-master.mulesoft.org/nexus/content/repositories/releases \
   MULE_USER=mule \
   MULE_VERSION=4.2.1

COPY ./mule ${BASE_INSTALL_DIR}/mule-standalone-${MULE_VERSION}/

# Create Mule group and user
RUN addgroup -S ${MULE_USER} && adduser -S -g "Mule runtime user" ${MULE_USER} -G ${MULE_USER} && \
    chown -R ${MULE_USER}:${MULE_USER} ${BASE_INSTALL_DIR}/mule-standalone-${MULE_VERSION} && \
    ln -s ${BASE_INSTALL_DIR}/mule-standalone-${MULE_VERSION} ${MULE_HOME} 

# Default user
USER ${MULE_USER}

# Download and install mule-standalone
RUN set -ex && \
    cd ~ && \
    wget -q ${MULE_REPOSITORY}/org/mule/distributions/mule-standalone/${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz && \
    echo "`cat ${BASE_INSTALL_DIR}/mule-standalone-${MULE_VERSION}/mule-standalone-${MULE_VERSION}.tar.gz.md5`  mule-standalone-${MULE_VERSION}.tar.gz" | md5sum -c && \
    tar -xzf mule-standalone-${MULE_VERSION}.tar.gz -C ${BASE_INSTALL_DIR} && \
    mv ${MULE_HOME}/conf/log4j2.xml ${MULE_HOME}/conf/log4j2.xml.default && \
    mv ${MULE_HOME}/conf/mule-container-log4j2.xml ${MULE_HOME}/conf/log4j2.xml && \
    rm mule-standalone-${MULE_VERSION}.tar.gz ${MULE_HOME}/mule-standalone-${MULE_VERSION}.tar.gz.md5 && \
    rm -rf ${MULE_HOME}/lib/launcher ${MULE_HOME}/lib/boot/exec ${MULE_HOME}/lib/boot/libwrapper-* ${MULE_HOME}/lib/boot/wrapper-windows-x86-32.dll   

# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]

# Define working directory.
WORKDIR ${MULE_HOME}

# Default http port
EXPOSE 8081

# Run mule in console mode (needed by Docker)
ENTRYPOINT ["./bin/mule-container"]
CMD [""]
