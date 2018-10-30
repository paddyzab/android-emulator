# Android development environment for ubuntu.
# version 0.0.5

FROM ubuntu

MAINTAINER tracer0tong <yuriy.leonychev@gmail.com>

# Specially for SSH access and port redirection
ENV ROOTPASSWORD android

# Expose ADB, ADB control and VNC ports
EXPOSE 22
EXPOSE 5037
EXPOSE 5554
EXPOSE 5555
EXPOSE 5900
EXPOSE 80
EXPOSE 443

ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# Update packages
# we are adding i386 to have more freedom in creating AVDs
RUN apt-get -y update && \
    dpkg --add-architecture i386 && \
    apt-get -y install software-properties-common bzip2 ssh net-tools openssh-server socat curl unzip && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get -y install libpulse0:i386 && \
    apt-get update && \
    apt-get -y install oracle-java8-installer && \
    rm -rf /var/lib/apt/lists/* 

# Install android sdk
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip sdk-tools-linux-4333796.zip -d /usr/local/android-sdk && \
    rm sdk-tools-linux-4333796.zip && \
    chown -R root:root /usr/local/android-sdk/

#Gets rid of the sdkmanager warning 
RUN cd /root && mkdir .android && \ 
    touch .android/repositories.cfg

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:$ANDROID_HOME/bin
ENV PATH $PATH:$ANDROID_HOME/tools/bin

RUN yes | sdkmanager --licenses

#Platform Tools
RUN sdkmanager "emulator" "tools" "platform-tools"

# The `yes` is for accepting all non-standard tool licenses.
RUN yes | sdkmanager \
    "platforms;android-28" \
    "platforms;android-27" \
    "platforms;android-26" \
    "platforms;android-25" \
    "platforms;android-24" \
    "platforms;android-23" \
    "platforms;android-22" \
    "platforms;android-21" \
    "build-tools;28.0.0" \
    "build-tools;27.0.3" \
    "build-tools;27.0.2" \
    "build-tools;27.0.1" \
    "build-tools;26.0.2" \
    "build-tools;26.0.1" \
    "build-tools;25.0.3" \
    "system-images;android-28;google_apis;x86" \
    "system-images;android-27;google_apis;x86" \
    "system-images;android-26;google_apis;x86" \
    "system-images;android-28;google_apis;x86" \
    "system-images;android-21;google_apis;x86" \
    "system-images;android-21;google_apis;x86" \
    "system-images;android-21;google_apis;x86" \
    "system-images;android-21;google_apis;x86" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    "add-ons;addon-google_apis-google-21"

# Create fake keymap file
RUN cd $ANDROID_HOME && \
    mkdir tools && mkdir tools/keymaps && \
    touch tools/keymaps/en-us

# Run sshd
RUN mkdir /var/run/sshd && \
    echo "root:$ROOTPASSWORD" | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

ENV NOTVISIBLE "in users profile"

# Add entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
