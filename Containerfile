FROM registry.redhat.io/openshift4/microshift-bootc-rhel9:v4.19

ARG USHIFT_VER=4.19
RUN dnf config-manager \
        --set-enabled rhocp-${USHIFT_VER}-for-rhel-9-$(uname -m)-rpms \
        --set-enabled fast-datapath-for-rhel-9-$(uname -m)-rpms \
        --set-enabled gitops-1.16-for-rhel-9-x86_64-rpms

RUN dnf install -y mkpasswd rhc insights-client microshift-gitops && dnf clean all

# TODO: do user mgmt. better
#configure bootc-user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint