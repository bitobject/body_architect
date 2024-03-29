# Update the VARIANT arg in docker-compose.yaml to pick an Elixir version: 1.9, 1.10, 1.10.4
# ARG VARIANT=latest
ARG VARIANT=1.14.4-erlang-25.3.1-ubuntu-focal-20230126
FROM hexpm/elixir:${VARIANT}

# This Dockerfile adds a non-root user with sudo access. Update the “remoteUser” property in
# devcontainer.json to use it. More info: https://aka.ms/vscode-remote/containers/non-root-user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Options for common package install script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"
ARG COMMON_SCRIPT_SOURCE="https://raw.githubusercontent.com/microsoft/vscode-dev-containers/v0.245.0/script-library/common-debian.sh"
# ARG COMMON_SCRIPT_SHA="68a72c1e2c34d34a0de5e129be9d2c9c6de81f6858eed5e75bbe1f660cfa2f84"
ARG COMMON_SCRIPT_SHA="dev-mode"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
RUN apt-get update -y\
  && export DEBIAN_FRONTEND=noninteractive \
  && apt install bash-completion \
  && echo "source /etc/profile.d/bash_completion.sh" >> ~/.bashrc \
  && apt-get -y install --no-install-recommends curl neovim ca-certificates 2>&1 \
  && curl -sSL ${COMMON_SCRIPT_SOURCE} -o /tmp/common-setup.sh \
  && ([ "${COMMON_SCRIPT_SHA}" = "dev-mode" ] || (echo "${COMMON_SCRIPT_SHA} */tmp/common-setup.sh" | sha256sum -c -)) \
  && /bin/bash /tmp/common-setup.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
  #
  # Install dependencies
  && apt-get install -y build-essential \
  #
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && git config --global --add safe.directory /app \
  && rm -rf /var/lib/apt/lists/* /tmp/common-setup.sh /tmp/node-setup.sh


# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends pcscd openssl dnsutils lldpd inotify-tools

# Add to group for execute lldpcli
RUN addgroup vscode adm

USER vscode

RUN mix local.hex --force \
  && mix local.rebar --force 

RUN echo 'PATH=~/.mix/escripts:$PATH' >> ~/.profile

ENV LANG C.UTF-8
