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

ARG NVM_VERSION
ARG NODE_VERSION
ARG NPM_VERSION
ARG YARN_VERSION

RUN (test ! -z "${NVM_VERSION}" && exit 0 || echo "--build-arg NVM_VERSION must be supplied to docker build." >&2 && exit 1)
RUN (test ! -z "${NODE_VERSION}" && exit 0 || echo "--build-arg NODE_VERSION must be supplied to docker build." >&2 && exit 1)
RUN (test ! -z "${NPM_VERSION}" && exit 0 || echo "--build-arg NPM_VERSION must be supplied to docker build." >&2 && exit 1)
RUN (test ! -z "${YARN_VERSION}" && exit 0 || echo "--build-arg YARN_VERSION must be supplied to docker build." >&2 && exit 1)

RUN echo NVM_VERSION=${NVM_VERSION}
RUN echo NODE_VERSION=${NODE_VERSION}
RUN echo NPM_VERSION=${NPM_VERSION}
RUN echo YARN_VERSION=${YARN_VERSION}

ENV NVM_DIR="/opt/nvm"
COPY src/etc-profile.d-nvm /etc/profile.d/nvm.sh
RUN groupadd --system nvm \
    && usermod --append --groups nvm root
RUN mkdir -p "${NVM_DIR}/{.cache,versions,alias}" \
    && chown -R :nvm "${NVM_DIR}" \
    && chmod -R g+ws "${NVM_DIR}"
RUN curl "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | PROFILE=/etc/bash.bashrc bash
RUN . "${NVM_DIR}/nvm.sh" && nvm install --lts
RUN . "${NVM_DIR}/nvm.sh" && nvm install "${NODE_VERSION}"
RUN . "${NVM_DIR}/nvm.sh" && nvm exec --lts             -- npm install --location=global "npm@${NPM_VERSION}"
RUN . "${NVM_DIR}/nvm.sh" && nvm exec "${NODE_VERSION}" -- npm install --location=global "npm@${NPM_VERSION}"
RUN . "${NVM_DIR}/nvm.sh" && nvm exec --lts             -- npm install --location=global "yarn@${YARN_VERSION}"
RUN . "${NVM_DIR}/nvm.sh" && nvm exec "${NODE_VERSION}" -- npm install --location=global "yarn@${YARN_VERSION}"
RUN . "${NVM_DIR}/nvm.sh" && nvm alias default "${NODE_VERSION}"
RUN . "${NVM_DIR}/nvm.sh" && nvm use default
RUN . "${NVM_DIR}/nvm.sh" && npm install -g esy
