Function Remove-CompellentServer 

{

    param( 
        [Parameter(Mandatory=$True)]
        $comhost,
        [Parameter(Mandatory=$True)]
        $user,
        [Parameter(Mandatory=$True)]
        $password,
        [Parameter(Mandatory=$True)]
        $server,
        [switch]$doit
    )

    Begin {
        If($doit.ispresent){$rprt = $false}
        Else{$rprt = $true}
    }

    Process {
        Add-PSSnapin Compellent.StorageCenter.PSSnapin

        $pw = convertto-securestring -string $password -asplaintext -force

        $cnx = get-scconnection -host $chost -user $user -password $pw

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