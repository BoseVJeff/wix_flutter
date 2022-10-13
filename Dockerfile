# Use for general Linux dev
FROM ubuntu:latest

# Use if making Snaps
# Taken from https://stackoverflow.com/a/50052151
# FROM snapcore/snapcraft:stable

RUN apt-get update && apt-get install -y bash curl file git unzip xz-utils zip clang cmake ninja-build pkg-config libgtk-3-dev

# Use if building Flatpak
# Taken from https://docs.flatpak.org/en/latest/first-build.html and other links in it
#
# RUN apt install flatpak
# RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# RUN flatpak install flathub org.freedesktop.Platform//21.08 org.freedesktop.Sdk//21.08

RUN mkdir devbin && cd devbin && git clone https://github.com/flutter/flutter.git -b stable
ENV PATH="${PATH}:/devbin/flutter/bin/"
RUN flutter doctor
RUN flutter precache --linux
