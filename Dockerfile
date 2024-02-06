FROM public.ecr.aws/lambda/provided:al2023

RUN \
    dnf install --assumeyes findutils \
        cmake \
        gcc \
        g++ \
        gmp-devel \
        gmp-static \
        glibc-static \
        zlib-devel \
        zlib-static \
        vim \
        sudo \
        jq \
        git

ARG USER_NAME=factor
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Creating the workspace user
RUN /usr/sbin/groupadd --gid ${USER_GID} ${USER_NAME} \
    && /usr/sbin/useradd --uid ${USER_UID} --gid ${USER_GID} --no-log-init --create-home -m ${USER_NAME} -s /usr/bin/bash \
    && /bin/echo ${USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME}

USER ${USER_NAME}

WORKDIR /home/${USER_NAME}

RUN git clone git://factorcode.org/git/factor.git

RUN cd /home/factor/factor && ./build.sh update

RUN /bin/echo -e "\nalias factor=/home/${USER_NAME}/factor/factor\n" >> /home/${USER_NAME}/.bashrc

CMD [ "sleep", "infinity" ]
