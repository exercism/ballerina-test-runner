FROM ballerina/ballerina:2201.2.3 AS build

# Pull any ballerina package and download dependencies
USER root
WORKDIR /home/ballerina
COPY tests/example-success/ .
RUN bal build

WORKDIR /opt/test-runner
# copy needed files
COPY bin/run.sh bin/run.sh
COPY test-report-to-exercism-result bin/test-report-to-exercism-result
# cache ballerina libraries
RUN cp -r $HOME/.ballerina/repositories/. bin/repo_cache

FROM ballerina/ballerina:2201.2.3 AS test

# install packages required to run the tests
USER root
RUN apk add --no-cache jq coreutils

WORKDIR /opt/test-runner
# copy shell script and json formatter
COPY --from=build /opt/test-runner/bin /opt/test-runner/bin
# copy ballerina repositories
RUN mkdir -p $HOME/.ballerina/repositories
RUN cp -r /opt/test-runner/bin/repo_cache/. $HOME/.ballerina/repositories

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]