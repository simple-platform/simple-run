FROM node:21.5.0

RUN apt-get update && apt-get install -y \
    lsof elixir erlang-dev erlang-xmerl erlang-os-mon && \
    mix local.hex && \
    mix local.rebar

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -p git \
    -p node \
    -p https://github.com/zsh-users/zsh-autosuggestions

RUN npm install -g pnpm && \
    SHELL=bash pnpm setup && \
    pnpm config set store-dir /root/.local/share/pnpm/store

RUN npm install -g turbo commitizen

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN code-server --install-extension bradlc.vscode-tailwindcss
RUN code-server --install-extension vscode-icons-team.vscode-icons
RUN code-server --install-extension ms-azuretools.vscode-docker
RUN code-server --install-extension PROxZIMA.sweetdracula
RUN code-server --install-extension streetsidesoftware.code-spell-checker
RUN code-server --install-extension dbaeumer.vscode-eslint
RUN code-server --install-extension rvest.vs-code-prettier-eslint
RUN code-server --install-extension esbenp.prettier-vscode
RUN code-server --install-extension elixir-lsp.elixir-ls

COPY ./.vscode/code-server.settings.json /root/.local/share/code-server/User/settings.json

EXPOSE 8080

CMD code-server --auth none --proxy-domain simple.local --bind-addr 0.0.0.0:8080 /workspace
