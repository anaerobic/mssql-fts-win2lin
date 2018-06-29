# mssql-win2lin (riffing on SQL Server Lab)

The SQL Server Developer image — [microsoft/mssql-server-windows-developer](https://github.com/Microsoft/mssql-docker/tree/master/windows/mssql-server-windows-developer) — lets you run a SQL Server database with Full-Text Search in a Docker container on Windows, without having SQL Server installed. All you need is Docker. 

## Prerequisites

You'll need [Docker for Windows](https://store.docker.com/editions/community/docker-ce-desktop-windows) running on Windows 10.

You'll need to enable Experimental Features in the Docker daemon to [simultaneously run Windows and Linux containers](https://blogs.msdn.microsoft.com/premier_developer/2018/04/20/running-docker-windows-and-linux-containers-simultaneously/)

## Run

```
./build.ps1
```
