FROM ballerina/ballerina:2201.14.1
USER root

ARG H2DB_VER=2.5.252
ADD "https://search.maven.org/remotecontent?filepath=com/h2database/h2/${H2DB_VER}/h2-${H2DB_VER}.jar" "/opt/test-runner/bin/platform-libs/com/h2database/h2/${H2DB_VER}/h2-${H2DB_VER}.jar"

RUN apk add --no-cache jq coreutils perl
RUN bal pull ballerinax/java.jdbc:1.15.1

WORKDIR /opt/test-runner

COPY bin/run.sh bin/run.sh
COPY bin/test-report-to-exercism-result bin/test-report-to-exercism-result

RUN bal build bin/test-report-to-exercism-result

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
