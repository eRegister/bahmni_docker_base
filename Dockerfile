# we're upgrading to from centos 6.9 to centos 7.6
FROM centos:centos7.6.1810
# install system packages
RUN yum install -y sudo yum-plugin-ovl policycoreutils selinux-policy-targeted ; \
    yum clean all 
#Prerequisite for the fresh installation of Bahmni
RUN yum install -y https://kojipkgs.fedoraproject.org//packages/zlib/1.2.11/19.fc30/x86_64/zlib-1.2.11-19.fc30.x86_64.rpm

# Install the bahmni command line program (we're installing 0.92).
RUN yum install -y https://dl.bintray.com/bahmni/rpm/rpms/bahmni-installer-0.92-155.noarch.rpm

# Added this to fix systemd related issues
RUN yum -y install systemd; yum clean all; \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# add inventory file (for ansible)
ADD local /etc/bahmni-installer/local

# set initial bahmni configs
RUN echo -e "selinux_state: disabled\ntimezone: Africa/Maseru\nimplementation_name: default\ndocker: yes " > /etc/bahmni-installer/setup.yml

# Set the inventory file name to local in BAHMNI_INVENTORY environment variable. This way you won't need to use the '-i local' switch every time you use the 'bahmni' command
#You can also configure custom inventory file instead of local.
RUN echo "export BAHMNI_INVENTORY=local" >> ~/.bashrc
RUN source ~/.bashrc

# install bahmni
RUN bahmni -i local install

# installing nano, an easier alternative to vi for editing files
RUN yum install -y nano
RUN yum install -y yum-plugin-versionlock

# Bahmni uses these during installation
RUN yum -y install openssh-server openssh-clients

# Also related systemd issues
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]



############## IMPORTANT TO NOTE ##########################################
# future developers who'll be working on future upgrades should note that
# the container built from this image did work. We did a lot of tweaks to
# to fnally have all components of Bahmni working