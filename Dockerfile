FROM ubuntu

ENV LANG C.UTF-8

RUN echo "fs.inotify.max_user_watches=524288" > /etc/sysctl.d/40-max-user-watches.conf

# install node
# ARG NODE_MAJOR_VERSION=16
ARG NODE_MAJOR_VERSION=lts

# install node_version, and other tools
RUN apt-get update \
  && apt-get install -y adduser curl sudo git \
  && curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean all

# ensure we have all the tools
RUN git --version \
  && node -v \
  && npm -v

# create user
ARG USERNAME

RUN adduser --shell /bin/bash --disabled-password \
  ${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}-no-pass

# install prompt helper
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

ENV USER_HOME /home/$USERNAME

# file permissions
VOLUME [ "${USER_HOME}/code" ]
VOLUME [ "${USER_HOME}/.vscode-server" ]

RUN echo "eval \"\$(starship init bash)\"" >> ${USER_HOME}/.bashrc

RUN mkdir -p ${USER_HOME}/code ${USER_HOME}/.vscode-server \
  && chown -R ${USERNAME}:${USERNAME} ${USER_HOME}

USER ${USERNAME}
SHELL [ "/bin/bash", "-lc" ]
# confirm installation
RUN echo "User: $(whoami) Node: $(node -v) NPM: $(npm -v)" > ${USER_HOME}/installed_node_info.txt

RUN sudo rm -rf /var/cache/apt

# install global tools
# RUN npm install -g typescript ts-node nodemon

CMD ["/bin/bash", "-c", "--", "while sleep 86400; do echo Running; done"]