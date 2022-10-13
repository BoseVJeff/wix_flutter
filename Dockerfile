FROM ubuntu:latest

RUN apt-get update && apt-get install -y bash curl file git unzip xz-utils zip clang cmake ninja-build pkg-config libgtk-3-dev
RUN mkdir devbin && cd devbin && git clone https://github.com/flutter/flutter.git -b stable
# RUN export PATH="$PATH:devbin/flutter/bin"
ENV PATH="${PATH}:/devbin/flutter/bin/"
# RUN devbin/flutter/bin/flutter doctor
RUN flutter doctor
RUN flutter precache --linux
# COPY . ./app/
# WORKDIR /app
# RUN flutter clean && flutter pub get && flutter build linux
