# mule-docker
Docker image of **Mule Runtime Engine Community Edition** (aka Kernel) 4 (current version is 4.2.1) intended to implement microservices and REST APIs with Mule.


# Quick reference
-	**Where to get help**:  
    - [Mule Runtime 4.2](https://docs.mulesoft.com/mule-runtime/4.2/)
-	**Where to report problems**:  
	- [GitHub](https://github.com/trellixa/mule-docker/issues)
-	**Supported architectures**:  
	- amd64


# Overview

Mule Runtime is a lightweight Enterprise Service Bus (ESB) used for Integrations, building APIs,
implementing Microservices, Data extraction, and Transformation.

This image supports any Mule App requiring Mule Runtime engine version 4 Kernel. However, our primary purpose is to implement
microservices and REST APIs in Mule. Also, with optimization for running in Cloud with Kubernetes clusters
and/or Istio, Service Mesh, or similar technologies.


## JDK version and Linux distro

Mule Runtime requires JDK 8 and since version 4.2.0, is also supporting JDK 11. Support for JDK 11 is coming in a future version. 

Currently, two Linux distros are supported: Ubuntu Bionic (18.04), and Alpine. See the image section for further details. 


## JVM Memory limits and Docker Container support

Since Jdk8u191, the JVM has been updated to be aware that is running within a Docker container. JVM now includes the option `-XX:+UseContainerSupport` which is enabled by default. For this reason, usual JVM options for memory heap such as -Xms and -Xmx are not set in the image and it is recommended that you define the memory limits in the Docker container instead. For example, this command will run a container limited to 1GB of RAM:

```console
docker run --rm -m 1g --name mymule-service -p 8081:8081 trellixa/mule
```

To gain more fine grained control over the memory used for Java Heap within the Docker container, JVM also defines three new options:

 - -XX:InitialRAMPercentage
 - -XX:MaxRAMPercentage
 - -XX:MinRAMPercentage

The Mule Container is started using these options for the heap: 

```console
-XX:+UseContainerSupport -XX:MinRAMPercentage=50.0 -XX:MaxRAMPercentage=60.0
```


## Mule Expose ports

The image exposes a single port, **port 8081**, for Mule Applications to use.


## Volumes

Four volumes are defined in the image to allow easy installation and configuration of your Mule apps: **logs, conf, apps, domains**.

All mount points are relative to the $MULE_HOME environment variable as show below: 

```dockerfile
# Define mount points.
VOLUME ["${MULE_HOME}/logs", "${MULE_HOME}/conf", "${MULE_HOME}/apps", "${MULE_HOME}/domains"]
```

Where MULE_HOME value is */opt/mule*.


## Why the Tanuki wrapper is not used

Vanilla installations of Mule standalone use Tanuki Wrapper to start the Mule Container either as a Windows or Linux service. Also, to monitor the health of the Runtime and automatically restart it if needed.
However, in this image, the Mule Container is started without using the Wrapper script. Indeed,
using the Wrapper with Docker container would be redundant, Docker already provides Container level support to control Mule successfully. Furthermore, in a Microservice architecture, it is likely that the containers are managed by Kubernetes or similar, or are part of a Service Mesh using Istio, Consul, Kong, or similar. 

On the other hand, Tanuki Wrapper depends on GNU glibc library which is normally not provided in Linux Alpine distro. So, by not using the wrapper, we are removing the dependency of the image with this library.

Finally, to facilitate the migration of any existing Mule deployment that you might have, the **wrapper.conf** file is still processed and all
the Java parameters `wrapper.java.additional.*` are used when launching the JVM with MuleContainer.

# Images

There are tree types of images supported, all with the same Mule Runtime version 4.2.1 and OpenJDK 8 (HotSpot) version:

|Image                     | Tag                         | Description                                      |
|--------------------------|-----------------------------|--------------------------------------------------|
|Official AdoptOpenJDK     | latest, 4.2.1, 4.2.1-bionic | Image based on Docker Official [AdoptOpenJDK](https://hub.docker.com/_/adoptopenjdk) image                       |
|AdoptOpenJDK Ubuntu slim  | 4.2.1-ubuntu-slim           | Image based on [AdoptOpenJDK/openjdk8](https://hub.docker.com/r/adoptopenjdk/openjdk8) Ubuntu slim image  |
|AdoptOpenJDK Alpine slim  | 4.2.1-alpine-slim           | Image based on [AdoptOpenJDK/openjdk8](https://hub.docker.com/r/adoptopenjdk/openjdk8) Alpine slim image  |


---
**Note:** Alpine is not officially supported by Mulesoft but Ubuntu 18.04 is supported. See: [Software requirements](https://docs.mulesoft.com/release-notes/studio/anypoint-studio-7.3-with-4.2-runtime-update-site-5-release-notes#software-requirements)

---




# How to use this image

1. **Starting a container**

	To start a new container using this image, run:

	```console
	docker run --rm -m 1g --name mymule-service -p 8081:8081 trellixa/mule
	```

	This will create a new container named *mymule-service* with 1GB of memory for the container mapped to port 8081.

    1. **Starting a container based on Linux Alpine slim image**

		To start a new container with alpine-slim image, run:

		```console
		docker run --rm -m 1g --name mymule-service -p 8081:8081 trellixa/mule:4.2.1-alpine-slim
		```

		This will create a new container named *mymule-service* with 1GB of memory for the container mapped to port 8081 based on Linux Alpine and OpenJDK slim version. Image size is ~254MB.

    2. **Starting a container based on Ubuntu slim image**

		To start a new container with ubuntu-slim image, run:

		```console
		docker run --rm -m 1g --name mymule-service -p 8081:8081 trellixa/mule:4.2.1-ubuntu-slim
		```

		This will create a new container named *mymule-service* with 1GB of memory for the container mapped to port 8081 based on Ubuntu and OpenJDK slim version. Image size is ~354MB. Ie. 100MB bigger than Alpine image but smaller by ~100MB with respect to the default Ubuntu image.


2. **Deploying a Mule App**

	After starting the Container, copy the Mule app into the $MULE_HOME/apps folder.

	```console
	docker cp my-mule-application.jar mymuleapp:/opt/mule/apps/.
	```

	This will deploy the Mule app *my-mule-application.jar* into the *mymule-service* container previously created.

	In addition, the container can have the **apps** volume mounted with the Mule app(s) already in it.

	```console
	docker run --rm -m 1g --name mymule-service -p 8081:8081 -v my-vol-with-mule-apps:/opt/mule/apps trellixa/mule
	```

	In this way, there is no need to copy the application to the container after running the container.


3. **Deploying a Mule App from new Docker image**

	Another option, you can create a new image containing you Mule app and using this image as base. 

	```dockerfile
	FROM trellixa/mule
	COPY mymuleapp.jar $MULE_HOME/apps
	# Uncomment to pass any extra Java or Application parameter. For instance, the 'env' variable
	#CMD ["-Denv=qa"]
	```

4. **Passing extra parameters**

	Any extra argument od the docker run command will be used as parameter to the Mule container. So, the command:

	```console
	docker run --rm -m 1g --name mymule-service -p 8081:8081 trellixa/mule -Denv=qa
	```

	will set the *env* variable to 'qa' for Mule.

5. **Getting the logs**
	
	You can mount a volume with the logs when running the container. For example:

	```console
	docker run --rm -m 1g --name mymule-service -p 8081:8081 -v my-mule-logs:/opt/mule/logs trellixa/mule
	```


6. **Changing the configuration**
	
	To change Mule Container configuration, edit or copy the *$MULE_HOME/conf/mule-container.conf* file. Note that the *conf* folder is also one of the mount points defined in the image. So, Mule can be configured using:
	
	```console
	docker run --rm -m 1g --name mymule-service -p 8081:8081 -v my-mule-conf:/opt/mule/conf trellixa/mule
	```



# License

View [license information](https://github.com/trellixa/mule-docker/blob/master/LICENSE) for the Dockerfile(s) and associated scripts which are licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

Licenses for the products installed within the image:

- Mule Runtime Kernel edition is licensed by Mulesoft under the [Common Public Attribution License](https://developer.mulesoft.com/licensing-mule-esb) (CPAL).

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
