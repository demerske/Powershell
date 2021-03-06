Function Remove-CompellentServer 

{
<#
.SYNOPSIS
Remove-CompellentServer removes unmapped servers under a parent server in the compellent environment.
.DESCRIPTION
Remove-CompellentServer creates a session to the specified Compellent Host using the supplied credentials.
It then uses the Parent Server specified to search all sub Servers for items with no maps. Depending on whether the -Doit flag is present
it either reports on what Servers match this criteria or actually removes the servers.
.PARAMETER comhost
The Compellent Host name. Default Value=$null
.PARAMETER user
Compellent Username
.PARAMETER pserv
Parent Server to search under
.PARAMETER doit
A flag for running in active mode. Omitting this flag will run in report mode.
.EXAMPLE
Remove-CompellentServer -comhost omacmlprd00 -user xxx_xxx -pserv OMAVIEW01

This will list the servers only.
.EXAMPLE
Remove-CompellentServer -comhost omacmlprd00 -user xxx_xxx -pserv OMAVIEW01 -doit

This will remove them.
#>

    param( 
        [Parameter(Mandatory=$True)]
        [string]$comhost,
        [Parameter(Mandatory=$True)]
        [string]$user,
        [Parameter(Mandatory=$True)]
        [string]$pserv,
        [switch]$doit
    )

    Begin {
        $pw = Read-Host "Enter Password" -assecurestring 

        If($doit.ispresent){$rprt = $false}
        Else{$rprt = $true}
    }

    Process {
        Add-PSSnapin Compellent.StorageCenter.PSSnapin

        $cnx = get-scconnection -host $comhost -user $user -password $pw

        $mservers = get-scserver -connection $cnx
        $servers = $mservers | ?{$_.parentserver -eq $pserv}

        If($servers -ne $null){
        ForEach($server in $servers){
            $sname = $server.name
            $pfolder = $server.parentfolder
            $pserver = $server.parentserver
            $maps = get-scvolumemap -servername $sname -connection $cnx
            If($maps -eq $null){
                If($rprt -eq $true){$output = $sname + "`tTo Remove"}
                ElseIf($rprt -eq $false){$output = $sname + "`tRemoved"
                Remove-SCServer -SCServer $server -connection $cnx -Confirm:$false}
            }
            Write-Host $output
        }
        }
        Else{Write-Host "No Servers Found"}
    }
}