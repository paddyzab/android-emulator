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
RUN apt-get -y update && \
    apt-get -y install software-properties-common bzip2 ssh net-tools openssh-server socat curl unzip && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get -y install oracle-java8-installer && \
    rm -rf /var/lib/apt/lists/*

# Install android sdk
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip sdk-tools-linux-4333796.zip -d /usr/local/ && \
    mv /usr/local/tools /usr/local/android-sdk && \
    chown -R root:root /usr/local/android-sdk/

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH $PATH:$ANDROID_HOME
ENV PATH $PATH:$ANDROID_HOME/bin

RUN mkdir -p $ANDROID_HOME/licenses && \
    echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license && \
    echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

# Export JAVA_HOME variable
#ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

RUN echo "Install Google API 21" && \
    sdkmanager "add-ons;addon-google_apis-google-21" && \
    echo "y" && \
    echo "Install Google API 22" && \
    sdkmanager "add-ons;addon-google_apis-google-22" && \
    echo "y" && \
    echo "Install Google API 23" && \
    sdkmanager "add-ons;addon-google_apis-google-23" && \
    echo "Install Google API 24" && \
    echo "y" && \
    sdkmanager "add-ons;addon-google_apis-google-24" && \
    echo "Install android-21" && \
    echo "y" && \
    sdkmanager "platforms;android-21" && \
    echo "Install android-22" && \
    echo "y" && \
    sdkmanager "platforms;android-22" && \
    echo "Install android-23" && \
    echo "y" && \
    sdkmanager "platforms;android-23" && \
    echo "Install android-24" && \
    echo "y" && \
    sdkmanager "platforms;android-24" && \
    echo "Install android-25" && \
    echo "y" && \
    sdkmanager "platforms;android-25" && \
    echo "Install platform-tools" && \
    sdkmanager "platform-tools" && \
    echo "Install build-tools-21.1.2" && \
    sdkmanager "build-tools;21.1.2" && \
    echo "Install build-tools-22.0.1" && \
    sdkmanager "build-tools;22.0.1"  && \
    echo "Install build-tools-23.0.1" && \
    sdkmanager "build-tools;23.0.1" && \
    echo "Install build-tools-23.0.2" && \
    sdkmanager "build-tools;23.0.2" && \
    echo "Install build-tools-23.0.3" && \
    sdkmanager "build-tools;23.0.3" && \
    echo "Install build-tools-24.0.0" && \
    sdkmanager "build-tools;24.0.0" && \
    echo "Install build-tools-24.0.1" && \
    sdkmanager "build-tools;24.0.1" && \
    echo "Install build-tools-24.0.2" && \
    sdkmanager "build-tools;24.0.2" && \
    echo "Install build-tools-24.0.3" && \
    sdkmanager "build-tools;24.0.3" && \
    echo "Install build-tools-25.0.0" && \
    sdkmanager "build-tools;25.0.0" && \
    echo "Install build-tools-25.0.1" && \
    sdkmanager "build-tools;25.0.1" && \
    echo "Install build-tools-25.0.2" && \
    sdkmanager "build-tools;25.0.2" && \
    echo "Install build-tools-25.0.3" && \
    sdkmanager "build-tools;25.0.3" && \
    echo "Install extra-android-m2repository" && \
    sdkmanager "extras;android;m2repository" && \
    echo "Install extra-google-google_play_services" && \
    sdkmanager "extras;google;google_play_services" && \
    echo "Install extra-google-m2repository" && \
    sdkmanager "extras;google;m2repository" && \
    echo "Install Google Play APK Expansion library" && \
    sdkmanager "extras;google;market_apk_expansion" && \
    echo "Install Google Play Licensing Library" && \
    sdkmanager "extras;google;market_licensing" && \
    echo "Install Google Play Billing Library" && \
    sdkmanager "extras;google;play_billing" && \
    echo "Install SDK Patch Applier v4" && \
    sdkmanager "patcher;v4" && \
    echo "Install tools 26.0.2" && \
    sdkmanager "tools"

# Create fake keymap file
RUN mkdir /usr/local/android-sdk/tools/keymaps && \
    touch /usr/local/android-sdk/tools/keymaps/en-us

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
