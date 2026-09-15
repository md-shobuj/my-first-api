FROM dart:stable

RUN apt-get update && apt-get install -y libsqlite3-0 libsqlite3-dev

WORKDIR /app
COPY pubspec.* .
RUN dart pub get
COPY . .
RUN dart pub get --offline

RUN dart pub global activate dart_frog_cli
ENV PATH="$PATH:/root/.pub-cache/bin"
RUN dart_frog build

WORKDIR /app/build
RUN dart pub get

EXPOSE 8080
CMD ["dart", "bin/server.dart"]