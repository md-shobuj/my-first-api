FROM dart:stable AS build

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
RUN dart compile exe bin/server.dart -o bin/server

FROM dart:stable
WORKDIR /app
COPY --from=build /app/build/bin/server ./bin/server
COPY --from=build /app/build/public ./public

EXPOSE 8080
CMD ["./bin/server"]