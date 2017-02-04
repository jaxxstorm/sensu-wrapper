FROM centos:7

RUN curl -L https://github.com/jaxxstorm/sensu-wrapper/releases/download/v0.3/sensu-wrapper_linux_amd64.tar.gz -o /tmp/sensu-wrapper_linux_amd64.tar.gz
RUN tar zxvf /tmp/sensu-wrapper_linux_amd64.tar.gz
RUN mv sensu-wrapper_linux_amd64 /usr/local/bin/sensu-wrapper

ENTRYPOINT ["/usr/local/bin/sensu-wrapper"]
