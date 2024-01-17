# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME=debian
ARG BASE_IMAGE_TAG=bookworm-slim

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} as builder

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get satisfy -y --no-install-recommends \
        "tzdata (>= 2023c-5)" \
        "ca-certificates (>= 20230311)" \
        "build-essential (>= 12.9)" \
        "git (>= 1:2.39.2-1.1)" \
        "cmake (>= 3.25.1-1)" \
        "gperf (>= 3.1-1)" \
        "zlib1g-dev (>= 1:1.2.13.dfsg-1)" \
        "libssl-dev (>= 3.0.11-1~deb12u2)" \
    ;

WORKDIR /brifli/src/telegram-bot-api
COPY CMakeLists.txt .
COPY td ./td
COPY telegram-bot-api ./telegram-bot-api

WORKDIR /brifli/build/telegram-bot-api
RUN mkdir -p /brifli/telegram-bot-api \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -s" \
        -DCMAKE_INSTALL_PREFIX:PATH=/brifli/telegram-bot-api \
        /brifli/src/telegram-bot-api \
    && cmake \
        --build . \
        --target install \
        -j $(nproc) \
    ;

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get satisfy -y --no-install-recommends \
        "tzdata (>= 2023c-5)" \
        "ca-certificates (>= 20230311)" \
        "zlib1g (>= 1:1.2.13.dfsg-1)" \
        "libssl3 (>= 3.0.11-1~deb12u2)" \
    ;

COPY --from=builder /brifli /brifli
COPY entrypoint.sh /

WORKDIR /brifli/telegram-bot-api

ENV PATH=${PATH}:/brifli/telegram-bot-api/bin

ENV TELEGRAM_BOT_API_HOME=/brifli/telegram-bot-api
ENV TELEGRAM_BOT_API_USER=telegram-bot-api
ENV TELEGRAM_BOT_API_TMPDIR=/tmp/brifli/telegram-bot-api
ENV TELEGRAM_BOT_API_VAR_LIB=/var/lib/brifli/telegram-bot-api

RUN useradd \
    --home-dir ${TELEGRAM_BOT_API_HOME} \
        --no-create-home \
        --shell /sbin/nologin \
        ${TELEGRAM_BOT_API_USER} \
    && mkdir -p ${TELEGRAM_BOT_API_TMPDIR} \
    && mkdir -p ${TELEGRAM_BOT_API_VAR_LIB} \
    && chown -R ${TELEGRAM_BOT_API_USER}:${TELEGRAM_BOT_API_USER} \
        ${TELEGRAM_BOT_API_HOME} \
        ${TELEGRAM_BOT_API_TMPDIR} \
        ${TELEGRAM_BOT_API_VAR_LIB} \
    ;
USER ${TELEGRAM_BOT_API_USER}:${TELEGRAM_BOT_API_USER}

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD [""]
