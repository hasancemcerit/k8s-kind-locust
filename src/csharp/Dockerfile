# https://hub.docker.com/_/microsoft-dotnet-sdk/
# build stage
ARG VERSION=9.0-alpine
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:${VERSION} AS build

ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH

RUN echo "Building on $BUILDPLATFORM targeting $TARGETPLATFORM"

WORKDIR /src

# copy csproj and restore for alpine/musl
COPY *.csproj ./

RUN dotnet restore --arch "$TARGETARCH"

# copy and publish app and libraries
COPY . .
RUN dotnet publish -c Release -p:PublishDir=/cs-api --arch "$TARGETARCH" --self-contained false

# https://hub.docker.com/_/microsoft-dotnet
# app stage
FROM mcr.microsoft.com/dotnet/aspnet:${VERSION} AS runtime

WORKDIR /cs-api
COPY --from=build /cs-api .

# Enable globalization APIs
# https://github.com/dotnet/announcements/issues/20
ENV \
  DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true\
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8

# app runtime specific Env. variables
ENV \
  ASPNETCORE_ENVIRONMENT=Docker \
  ASPNETCORE_HTTP_PORTS=5000

EXPOSE $ASPNETCORE_HTTP_PORTS

ENTRYPOINT [ "dotnet", "demo.dll" ]
