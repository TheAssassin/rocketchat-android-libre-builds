FROM ubuntu:21.10

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y npm nodejs yarnpkg curl wget zip unzip openjdk-11-jre-headless nano && \
    apt-get clean -y && \
    apt-get autoremove -y

ARG ANDROID_COMPILE_SDK=30
ARG ANDROID_BUILD_TOOLS=30.0.2

# find version number on https://developer.android.com/studio#downloads 
ARG ANDROID_COMMANDLINE_TOOLS=7583922

# needed so we can source the edited bashrc
SHELL ["/bin/bash", "-l", "-x", "-c"]

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMANDLINE_TOOLS}_latest.zip && \
    unzip commandlinetools-linux-${ANDROID_COMMANDLINE_TOOLS}_latest.zip && \
    rm commandlinetools-linux-${ANDROID_COMMANDLINE_TOOLS}_latest.zip && \
    mkdir -p /opt/android/cmdline-tools && \
    mv cmdline-tools /opt/android/cmdline-tools/latest && \
    echo 'export ANDROID_HOME=/opt/android' >> /etc/profile && \
    echo 'export ANDROID_SDK_ROOT="$ANDROID_HOME"' >> /etc/profile && \
    echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"' >> /etc/profile && \
    tail /etc/profile && \
    . /etc/profile && \
    echo "PATH=$PATH" && \
    sdkmanager --list && \
    sdkmanager --update && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-${ANDROID_COMPILE_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}" && \
    chmod -Rv a+rw /opt/android

CMD ["/bin/bash", "-l"]

# create some fake home dir, accessible by any user, so we can use -u with the calling user's user id
RUN install -m 0777 -d /home/user
ENV HOME=/home/user
