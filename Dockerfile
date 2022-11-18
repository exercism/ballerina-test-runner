FROM ballerina/ballerina:2201.2.3 AS build

# Pull any ballerina package and download dependencies
USER root
WORKDIR /home/ballerina
COPY bin/dep-cache.sh bin/dep-cache.sh
RUN ./bin/dep-cache.sh

FROM ballerina/ballerina:2201.2.3 AS runner

# install packages required to run the tests
USER root
RUN apk add --no-cache jq coreutils

# copy cached ballerina libraries
COPY --from=build /root/.ballerina/repositories /root/.ballerina/repositories

WORKDIR /opt/test-runner

# copy shell script and json formatter
COPY bin/run.sh bin/run.sh
COPY test-report-to-exercism-result bin/test-report-to-exercism-result

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]