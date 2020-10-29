# we're upgrading to from centos 6.9 to centos 7.6
FROM centos:centos7.6.1810
# install system packages
RUN yum install -y sudo yum-plugin-ovl policycoreutils selinux-policy-targeted ; \
    yum clean all 
# install EPEL repository for packages bahmni depends on
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# install packages bahmni depends on
RUN yum install -y python-pip ; \
    pip install --upgrade pip ; \
    yum install -y git openssh-server openssh-clients tar wget ; \
    yum clean all
# install bahmni installer
RUN yum install -y https://dl.bintray.com/bahmni/rpm/rpms/bahmni-installer-0.92-155.noarch.rpm
# add inventory file (for ansible)
ADD local /etc/bahmni-installer/local
# set initial bahmni configs
RUN echo -e "selinux_state: disabled\ntimezone: Africa/Maseru\nimplementation_name: default\ndocker: yes " > /etc/bahmni-installer/setup.yml
# Set the inventory file name to local in BAHMNI_INVENTORY environment variable. This way you won't need to use the '-i local' switch every time you use the 'bahmni' command
#You can also configure custom inventory file instead of local.
RUN echo "export BAHMNI_INVENTORY=local" >> ~/.bashrc
RUN source ~/.bashrc
# install bahmni
RUN bahmni install

#installing nano, an easier alternative to vi for editing files
RUN yum install -y nano

ENTRYPOINT /bin/bash