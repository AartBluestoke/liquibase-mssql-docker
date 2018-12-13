FROM kilna/liquibase
LABEL maintainer="Ruben Martínez ruben.martinez1@gmail.com"

ARG jdbc_driver_version
ENV jdbc_driver_version=${jdbc_driver_version:-6.2.2}
ENV jdbc_driver_download_url=https://github.com/Microsoft/mssql-jdbc/releases/download/v${jdbc_driver_version}/mssql-jdbc-${jdbc_driver_version}.jre8.jar\
    LIQUIBASE_PORT=${LIQUIBASE_PORT:-1433}\
    LIQUIBASE_CLASSPATH=${LIQUIBASE_CLASSPATH:-/opt/jdbc/mssql-jdbc-${jdbc_driver_version}.jre8.jar}\
    LIQUIBASE_DRIVER=${LIQUIBASE_DRIVER:-com.microsoft.sqlserver.jdbc.SQLServerDriver}\
    LIQUIBASE_URL=${LIQUIBASE_URL:-'jdbc:sqlserver://${HOST};database=${DATABASE}'}

RUN set -x -e -o pipefail;\
    echo "JDBC DRIVER VERSION: $jdbc_driver_version";\
    cd /opt/jdbc;\
    curl -SOLs ${jdbc_driver_download_url};

