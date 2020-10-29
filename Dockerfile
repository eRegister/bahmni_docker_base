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
RUN yum install -y https://dl.bintray.com/bahmni/rpm/rpms/:bahmni-erp-0.92-149.noarch.rpm
# add inventory file (for ansible)
ADD local /etc/bahmni-installer/local
# set initial bahmni configs
RUN echo -e "selinux_state: disabled\ntimezone: Africa/Maseru\nimplementation_name: default\ndocker: yes " > /etc/bahmni-installer/setup.yml
# install bahmni
RUN bahmni -ilocal install

#installing nano, an easier alternative to vi for editing files
RUN yum install nano

ENTRYPOINT /bin/bash
