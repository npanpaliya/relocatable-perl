FROM centos:6.4
MAINTAINER Shoichi Kaji <skaji@cpan.org>

RUN yum install -y gcc make perl
RUN mkdir /tmp/build /artifact

ADD relocatable-perl-build /tmp/build/relocatable-perl-build
RUN /usr/bin/perl /tmp/build/relocatable-perl-build --perl_version 5.20.0 --prefix /opt/perl

RUN wget --no-check-certificate -q -O - http://cpanmin.us | /opt/perl/bin/perl - -qn App::cpanminus
RUN /opt/perl/bin/cpanm -nq App::ChangeShebang
RUN /opt/perl/bin/change-shebang -f /opt/perl/bin/*

RUN cp -r /opt/perl /tmp/perl-`/opt/perl/bin/perl -MConfig -e 'print qq($^V-$Config{archname})'`
RUN cd /tmp && tar czf /artifact/perl-`/opt/perl/bin/perl -MConfig -e 'print qq($^V-$Config{archname})'`.tar.gz perl-`/opt/perl/bin/perl -MConfig -e 'print qq($^V-$Config{archname})'`

RUN rm -rf /tmp/perl-`/opt/perl/bin/perl -MConfig -e 'print qq($^V-$Config{archname})'`
RUN rm -rf /tmp/build

CMD ["sleep", "infinity"]
