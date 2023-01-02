FROM ubuntu:22.04
LABEL maintainer="Hugo Josefson <hugo@josefson.org> (https://www.hugojosefson.com/)"

ENV DEBIAN_FRONTEND=noninteractive
RUN  apt-get update \
    && apt-get install -y apt-utils \
    && apt-get dist-upgrade --purge -y \
    && apt-get autoremove --purge -y \
    && apt-get install -y \
    curl                   $(: 'required by these setup scripts') \
    wget                   $(: 'required by these setup scripts') \
    jq                     $(: 'required by these setup scripts') \
    gosu                   $(: 'for better process signalling in docker') \
    sudo                   $(: 'useful') \
    neovim                 $(: 'useful') \
    unzip                  $(: 'required by deno install.sh')

RUN apt-get install -y build-essential
RUN apt-get install -y git
RUN apt-get install -y default-jre-headless
RUN apt-get install -y bsdextrautils
RUN apt-get install -y emscripten
RUN apt-get install -y curl
RUN apt-get install -y wget

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

COPY src/container-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "bash" ]
RUN apt-get install -y cmake
COPY src/closure-compiler* /usr/local/bin/

ARG DENO_VERSION
RUN (test ! -z "${DENO_VERSION}" && exit 0 || echo "--build-arg DENO_VERSION must be supplied to docker build." >&2 && exit 1)
ENV DENO_INSTALL="/usr/local"
RUN curl -fsSL https://deno.land/install.sh | sh -s "${DENO_VERSION}"
RUN deno --version

ARG CLOSURE_COMPILER_VERSION
RUN (test ! -z "${CLOSURE_COMPILER_VERSION}" && exit 0 || echo "--build-arg CLOSURE_COMPILER_VERSION must be supplied to docker build." >&2 && exit 1)
RUN curl -s --fail https://repo1.maven.org/maven2/com/google/javascript/closure-compiler/${CLOSURE_COMPILER_VERSION}/closure-compiler-${CLOSURE_COMPILER_VERSION}.jar -o /usr/local/bin/closure-compiler.jar