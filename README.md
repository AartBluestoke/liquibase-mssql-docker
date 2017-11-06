# liquibase-mssql-docker

[![](https://images.microbadger.com/badges/image/kilna/liquibase-postgres.svg)](https://microbadger.com/images/kilna/liquibase-postgres)
[![](https://img.shields.io/docker/pulls/kilna/liquibase-postgres.svg?style=plastic)](https://hub.docker.com/r/rubms/liquibase-mssql/)
[![](https://img.shields.io/docker/stars/kilna/liquibase-postgres.svg?style=plastic)](https://hub.docker.com/r/rubms/liquibase-mssql/)

This project is based in [liquibase-postgres-docker](https://github.com/kilna/liquibase-postgres-docker) by [Kilna](https://github.com/kilna).

**A lightweight Docker for running [Liquibase](https://www.liquibase.org) with [the SQL Server JDBC driver](https://github.com/Microsoft/mssql-jdbc)**

DockerHub: [liquibase-mssql](https://hub.docker.com/r/rubms/liquibase-mssql/) - GitHub: [liquibase-mssql-docker](https://github.com/rubms/liquibase-mssql-docker)

# Usage

## Using your own derived Dockerfile

You can use this image by creating your own `Dockerfile` which inherits using a FROM line:

```
FROM rubms/liquibase-mssql-docker
ENV LIQUIBASE_HOST=database.server
ENV LIQUIBASE_DATABASE=dbname
ENV LIQUIBASE_USERNAME=user
ENV LIQUIBASE_PASSWORD=pass
COPY changelog.xml /workspace
```

Make sure to create an appropriate [changelog.xml](http://www.liquibase.org/documentation/xml_format.html) in the same directory as your Dockerfile.

Then you can build your derived Dockerfile to an image tagged 'changelog-image':

```
$ docker build --tag changelog-image .
```

Since the working directory within the container is /workspace, and since the entrypoint generates a a liquibase.properties file using the provided environment variables, it will know to look for _changelog.xml_ by default and apply the change. You can specify the name of your changelog via the `LIQUIBASE_CHANGELOG` environment variable. See the environment variables below.

Any time you make changes to the example project, you'll need to re-run the `docker build` command above, or you can using docker volumes as described below to sync local filesystem changes into the container. To run liquibase using the new image you can:

```
$ docker run changelog-image liquibase updateTestingRollback
```

## Using the image directly with a mounted docker volume

If you'd like to apply a changelog to a SQL Server database without deriving your own container, run the contiainer
appropriate to your database like so... where _/local/path/to/changelog/_ is the directory where a valid [changelog.xml](http://www.liquibase.org/documentation/xml_format.html) exists:

```
$ docker run -e LIQUIBASE_HOST=database.server -e LIQUIBASE_USERNAME=user -e LIQUIBASE_PASSWORD=pass \
    -e LIQUIBASE_DATABASE=dbname -v /local/path/to/changelog/:/workspace/ rubms/liquibase-mssql \
    liquibase updateTestingRollback
```

# Environment Variables and liquibase.properties

This docker image has a working Liquibase executable in the path, and an entrypoint which auto-generates a [liquibase.properties](http://www.liquibase.org/documentation/liquibase.properties.html) file.

In order to create the liquibase.properties file, it uses the follow environment variables when the image is started with 'docker run':

| Environment Variable | Purpose | Default |
|----------------------|---------|---------|
| LIQUIBASE_HOST       | Database host to connect to | db |
| LIQUIBASE_PORT       | Database port to connect to | 1433 |
| LIQUIBASE_DATABASE   | Database name to connect to | liquibase |
| LIQUIBASE_USERNAME   | Username to connect to database as | liquibase |
| LIQUIBASE_PASSWORD   | Password for username | liquibase |
| LIQUIBASE_CHANGELOG  | Default changelog filename to use | changelog.xml |
| LIQUIBASE_LOGLEVEL   | Log level as defined by Liquibase <br> _Valid values: debug, info, warning, severe, off_ | info |
| LIQUIBASE_CLASSPATH  | JDBC driver filename | /opt/jdbc/mssql-jdbc.jar |
| LIQUIBASE_DRIVER     | JDBC object path | com.microsoft.sqlserver.jdbc.SQLServerDriver |
| LIQUIBASE_URL        | JDBC URL for connection | jdbc:sqlserver://${HOST};database=${DATABASE} |
| LIQUIBASE_DEBUG      | If set to 'yes', when _docker run_ is executed, will show the values of all LIQUIBASE_* environment variables and describes any substitutions performed on _liquibase.properties_ | _unset_ |

The generated _liquibase.properties_ file is loaded into the default working dir _/workspace_ (which is also shared as a docker volume). The _/workspace/liquibase.properties_ file will have any variables substituted each time a 'docker run' command is performed...  so you can load your own _/workspace/liquibase.properties_ file and put `${HOST}` in it, and it will be replaced with the LIQUIBASE_HOST environment variable.

If you want to see what the contents of the generated _liquibase.properties_ file are, you can:

```
$ docker run image-name cat liquibase.properties
```

