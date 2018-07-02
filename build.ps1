
# Part 1 - build the dacpac
docker build -t sql-builder -f builder.Dockerfile .
rmdir -Force -Recurse out
mkdir out
docker run --rm -v $pwd\out:c:\bin -v $pwd\src:c:\src sql-builder

# Part 2 - build the SQL server image
docker build --memory 4g -t mssql-windows -f mssql-windows.Dockerfile .

docker build -t assets-db -f assets-db.Dockerfile .

docker build --platform=linux -t mssql-linux -f mssql-linux.Dockerfile .

# docker run --rm --name assets-db --publish 1433 assets-db

# docker container inspect --format '{{ .NetworkSettings.Networks.nat.IPAddress }}' assets-db

docker run --rm --name mssql-linux --publish 1433 -e "ACCEPT_EULA=Y" -e "MSSQL_PID=Developer" mssql-linux