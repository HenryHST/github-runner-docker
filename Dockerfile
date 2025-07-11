FROM ubuntu:24.04

ARG RUNNER_VERSION="2.325.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
RUN apt-get install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip


RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

LABEL org.opencontainers.image.description="github runner docker image for selfhost infra"
LABEL org.opencontainers.image.authors="h.stadthagen@me.com"
LABEL org.opencontainers.image.title="github-runner-docker"
LABEL org.opencontainers.image.url="https://github.com/HenryHST/github-runner-docker"
LABEL org.opencontainers.image.licenses="MIT"

HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD curl -f http://localhost/health || exit 1

ENTRYPOINT ["./start.sh"]