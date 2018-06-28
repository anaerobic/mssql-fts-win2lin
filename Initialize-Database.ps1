# The script sets the sa password and start the SQL Service
# Also it attaches additional database from the disk
# The format for attach_dbs

param(
[Parameter(Mandatory=$false)]
[string]$sa_password,

[Parameter(Mandatory=$false)]
[string]$ACCEPT_EULA,

[Parameter(Mandatory=$false)]
[string]$attach_dbs
)

#if($ACCEPT_EULA -ne "Y" -And $ACCEPT_EULA -ne "y")
#{
#	Write-Verbose "ERROR: You must accept the End User License Agreement before this container can start."
#	Write-Verbose "Set the environment variable ACCEPT_EULA to 'Y' if you accept the agreement."

#    exit 1
#}

# start the service
Write-Verbose "Starting SQL Server"
start-service MSSQLSERVER

if($sa_password -ne "_")
{
    Write-Verbose "Changing SA login credentials ($($sa_password))"
    $sqlcmd = "ALTER LOGIN sa with password=" +"'" + $sa_password + "'" + ";ALTER LOGIN sa ENABLE;"
    & sqlcmd -Q $sqlcmd
}

# attach data files if they exist: 
$attach_dbs_cleaned = $attach_dbs.TrimStart('\\').TrimEnd('\\')

$dbs = $attach_dbs_cleaned | ConvertFrom-Json

if ($null -ne $dbs -And $dbs.Length -gt 0)
{
    Write-Verbose "Attaching $($dbs.Length) database(s)"
	    
    Foreach($db in $dbs) 
    {            
        $files = @();
        Foreach($file in $db.dbFiles)
        {
            $files += "(FILENAME = N'$($file)')";           
        }

        $files = $files -join ","
        $sqlcmd = "IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '" + $($db.dbName) + "') BEGIN EXEC sp_detach_db [$($db.dbName)] END;CREATE DATABASE [$($db.dbName)] ON $($files) FOR ATTACH;"

        Write-Verbose "Invoke-Sqlcmd -Query $($sqlcmd)"
        & sqlcmd -Q $sqlcmd
        
        # deploy or upgrade the database:
        $SqlPackagePath = 'C:\Program Files (x86)\Microsoft SQL Server\130\DAC\bin\SqlPackage.exe'
        & $SqlPackagePath  `
            /sf:Assets.Database.dacpac `
            /a:Script /op:create.sql /p:CommentOutSetVarDeclarations=true `
            /tsn:.\SQLEXPRESS /tdn:$db.dbName /tu:sa /tp:$sa_password 

        $SqlCmdVars = "DatabaseName=$($db.dbName)", "DefaultFilePrefix=$($db.dbName)", "DefaultDataPath=c:\database\", "DefaultLogPath=c:\database\"  
        Invoke-Sqlcmd -InputFile create.sql -Variable $SqlCmdVars -Verbose

	}
}

Write-Verbose "Started SQL Server."

# relay SQL event logs to Docker

$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) 
{ 
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message	 
    $lastCheck = Get-Date 
    Start-Sleep -Seconds 2 
}