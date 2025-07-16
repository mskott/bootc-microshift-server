FROM registry.redhat.io/openshift4/microshift-bootc-rhel9:v4.19

RUN dnf install rhc insights-client microshift-gitops && dnf clean all

# TODO: do user mgmt. better
#configure bootc-user
RUN pass=$(mkpasswd --method=SHA-512 --rounds=4096 redhat) && useradd -m -G wheel bootc-user -p $pass

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

RUN rm /var/{cache,lib}/dnf /var/lib/rhsm /var/cache/ldconfig -rf
RUN bootc container lint