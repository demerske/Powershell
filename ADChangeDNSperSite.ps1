#$outfile = Read-Host "Enter output filepath"
$site1dns = @()
$site2dns = @()
$site3dns = @()
$site4dns = @()

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$find.searchroot = "LDAP://OU=Servers,DC=yourdSite3in,DC=com"
$systems = $find.findall()

#$output = "Server`tIP Address`tAdapter Description`tSubnet Mask`tGateway`tMAC Address`tDNS1 DNS2 DNS3 DNS4 DNS5`tWINS Primary`tWINS Secondary"
#Add-Content $output -path $outfile

ForEach($system in $systems){$comp = [string]$system.properties.name
    $adapters = gwmi Win32_networkadapterconfiguration -computer $comp
    if($error[0].exception -ne $null){
        $output = $comp + "`t" + $error[0].exception.message.tostring()
        Write-Host $output
        #Add-Content $output -path $outfile
        $error.clear()
    }
    
    Else{
        ForEach($adapter in $adapters){
            if(($adapter.ipenabled -eq "true") -and ($adapter.dnsserversearchorder -ne $null)){
                if(($adapter.dnsserversearchorder[0] -eq "") -or `
                    ($adapter.dnsserversearchorder[0] -eq "") -or `
                    ($adapter.dnsserversearchorder[0] -eq "")){
                        #$adapter.setdnsserversearchorder($Site1dns)
                        #If($adapter.WINSPrimaryServer -ne $null){
                            #$adapter.setWinsServer("")
                        #}
                        Write-Host $comp, "Site1"
                }
                if(($adapter.dnsserversearchorder[0] -eq "") -or `
                    ($adapter.dnsserversearchorder[0] -eq "")){
                        #$adapter.setdnsserversearchorder($Site2dns)
                        #If($adapter.WINSPrimaryServer -ne $null){
                            #$adapter.setWinsServer("")
                        #}
                        Write-Host $comp, "Site2"
                }
                if(($adapter.dnsserversearchorder[0] -eq "") -or `
                    ($adapter.dnsserversearchorder[0] -eq "") -or `
                    ($adapter.dnsserversearchorder[0] -eq "") -or `
                    ($adapter.dnsserversearchorder[0] -eq "")){
                        #$adapter.setdnsserversearchorder($Site3dns)
                        #If($adapter.WINSPrimaryServer -ne $null){
                            #$adapter.setWinsServer("")
                        #}
                        Write-Host $comp, "Site3"
                }
                Else{
                    If($adapter.WINSPrimaryServer -ne $null){
                        #$adapter.setWinsServer("")
                        Write-Host $comp, "WINS Only"
                    }
                }         
            }
        }
    }
}