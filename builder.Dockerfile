# escape=`
FROM microsoft/dotnet-framework-build:3.5
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

RUN Install-PackageProvider -Name chocolatey -RequiredVersion 2.8.5.130 -Force;

RUN Install-Package nuget.commandline -RequiredVersion 3.5.0 -Force; `
    & C:\Chocolatey\bin\nuget install Microsoft.Data.Tools.Msbuild -Version 10.0.61026

ENV MSBUILD_PATH="C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"

RUN $env:PATH = $env:MSBUILD_PATH + ';' + $env:PATH; `
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)
