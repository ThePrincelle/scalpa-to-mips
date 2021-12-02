FROM ubuntu:20.04

# Configure Timezone & tzdata
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Install requirements for testing
RUN apt-get install -y --no-install-recommends build-essential bison flex default-jre

# Clean image
RUN rm -rf /var/lib/apt/lists/*