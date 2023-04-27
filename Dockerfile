FROM ballerina/ballerina:2201.5.0

# install packages required to run the tests
USER root
RUN apk add --no-cache jq coreutils

# add ballerina libraries that would be pulled
RUN bal pull ballerinax/java.jdbc:1.5.0

WORKDIR /opt/test-runner

# copy necessary platform jars
RUN mkdir -p bin/platform-libs/com/h2database/h2/2.0.206 && wget https://repo1.maven.org/maven2/com/h2database/h2/2.0.206/h2-2.0.206.jar -P bin/platform-libs/com/h2database/h2/2.0.206

# copy shell script and json formatter
COPY bin/run.sh bin/run.sh
COPY bin/test-report-to-exercism-result bin/test-report-to-exercism-result
RUN bal build bin/test-report-to-exercism-result

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
