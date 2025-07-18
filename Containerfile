FROM registry.redhat.io/openshift4/microshift-bootc-rhel9:v4.19

ARG USHIFT_VER=4.19
RUN dnf config-manager \
        --set-enabled rhocp-${USHIFT_VER}-for-rhel-9-$(uname -m)-rpms \
        --set-enabled fast-datapath-for-rhel-9-$(uname -m)-rpms \
        --set-enabled gitops-1.16-for-rhel-9-x86_64-rpms

RUN dnf install -y mkpasswd rhc insights-client microshift-gitops tuned && \
    dnf clean all && \
    systemctl enable tuned

# TODO: do user mgmt. better
#configure bootc-user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

# Allow traffic in through the firewall
RUN firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 \
    firewall-cmd --permanent --zone=trusted --add-source=169.254.169.1 \
    firewall-cmd --permanent --zone=public --add-port=6443/tcp \
    firewall-cmd --permanent --zone=public --add-port=443/tcp \
    firewall-cmd --permanent --zone=public --add-port=80/tcp

RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint