
# Part 1 - build the dacpac
docker build -t assets-db-builder -f builder.Dockerfile .
rmdir -Force -Recurse out
mkdir out
docker run --rm -v $pwd\out:c:\bin -v $pwd\src:c:\src assets-db-builder

# Part 2 - build the SQL server image
docker build -t sql-server-fts -f sql-server.Dockerfile .

docker build -t assets-db -f v1.Dockerfile .

# docker run --rm --name assets-db --publish 1433 assets-db