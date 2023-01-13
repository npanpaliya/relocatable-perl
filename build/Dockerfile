ARG IMAGE
FROM $IMAGE
ARG IMAGE

#RUN if [[ $IMAGE = centos:centos6 ]]; then sed -i 's/^#baseurl=/baseurl=/g; s/^mirrorlist=/#mirrorlist=/g; s/http:\/\/mirror.centos.org/https:\/\/vault.centos.org/g' /etc/yum.repos.d/CentOS-Base.repo; fi
RUN yum install -y \
    gcc \
    make \
    tar \
    curl \
    patch \
    xz \
    perl-interpreter \
    perl
RUN mkdir -p \
    /lib \
    /lib/$(uname -m)-linux-gnu \
    /lib64 \
    /usr/lib \
    /usr/lib/$(uname -m)-linux-gnu \
    /usr/lib64 \
    /usr/local/lib \
    /usr/local/lib64
RUN mkdir /perl
#RUN curl -fsSL https://www.cpan.org/src/5.0/perl-5.36.0.tar.xz | tar xJf - --strip-components 1 -C /perl
RUN curl -fsSL --compressed -o /cpm https://raw.githubusercontent.com/skaji/cpm/main/cpm
COPY build/relocatable-perl-build build/cpm.yml BUILD_VERSION /
RUN /usr/bin/perl /cpm install -g
RUN /usr/bin/perl /relocatable-perl-build --perl_version $(cat /BUILD_VERSION) --prefix /opt/perl
RUN /opt/perl/bin/perl /cpm install -g App::cpanminus App::ChangeShebang
RUN /opt/perl/bin/change-shebang -f /opt/perl/bin/*
RUN set -eux; \
  cd /tmp; \
  _ARCHNAME=$(uname -m); \
  cp -r /opt/perl perl-linux-$_ARCHNAME; \
  tar cf perl-linux-$_ARCHNAME.tar perl-linux-$_ARCHNAME; \
  gzip -9 --stdout perl-linux-$_ARCHNAME.tar > /perl-linux-$_ARCHNAME.tar.gz; \
  xz   -9 --stdout perl-linux-$_ARCHNAME.tar > /perl-linux-$_ARCHNAME.tar.xz; \
  :
