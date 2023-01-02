FROM ubuntu:22.04
LABEL maintainer="Hugo Josefson <hugo@josefson.org> (https://www.hugojosefson.com/)"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get full-upgrade --purge -y \
    && apt-get autoremove --purge -y

RUN apt-get install -y build-essential
RUN apt-get install -y bsdextrautils         # `column` command, for `make help`
RUN apt-get install -y gosu                  # for /entrypoint.sh
RUN apt-get install -y emscripten            # `emcc` command, for compiling to WebAssembly
RUN apt-get install -y git                   # for `git clone`:ing yoga source code
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y unzip                 # for `deno` installation
RUN apt-get install -y sudo
RUN apt-get install -y tree
RUN apt-get install -y neovim

COPY src/container-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "bash" ]

ARG DENO_VERSION
RUN (test ! -z "${DENO_VERSION}" && exit 0 || echo "--build-arg DENO_VERSION must be supplied to docker build." >&2 && exit 1)
ENV DENO_INSTALL="/usr/local"
RUN curl -fsSL https://deno.land/install.sh | sh -s "${DENO_VERSION}"
RUN deno --version
