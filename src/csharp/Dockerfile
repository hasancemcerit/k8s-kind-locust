# https://hub.docker.com/_/microsoft-dotnet-sdk/
# build stage
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build

ARG BUILDPLATFORM
ARG TARGETPLATFORM
ARG TARGETARCH

RUN echo "Building on $BUILDPLATFORM, targeting for $TARGETPLATFORM"

WORKDIR /src

# copy csproj and restore for alpine/musl
COPY *.csproj ./

RUN dotnet restore --arch $TARGETARCH

# copy and publish app and libraries
COPY . .
RUN dotnet publish -c Release -p:PublishDir=/test-api --arch $TARGETARCH --self-contained false

# https://hub.docker.com/_/microsoft-dotnet
# app stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

WORKDIR /test-api
COPY --from=build /test-api .

# Enable globalization APIs
# https://github.com/dotnet/announcements/issues/20
ENV \
  DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true\
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8
  
# App specific Env. variables
ENV \
  ASPNETCORE_ENVIRONMENT=Docker \
  ASPNETCORE_HTTP_PORTS=80

EXPOSE 80

ENTRYPOINT [ "dotnet", "demo.dll" ]
