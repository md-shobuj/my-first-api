FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* .
RUN dart pub get
COPY . .
RUN dart pub get --offline
RUN dart_frog build

FROM dart:stable
WORKDIR /app
COPY --from=build /app/build/bin/server.dart.snapshot ./
COPY --from=build /app/build/public ./public

EXPOSE 8080
CMD ["dart", "server.dart.snapshot"]