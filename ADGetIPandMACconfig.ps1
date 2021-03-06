$outfile = Read-Host "Enter output filepath"
$search = new-object system.directoryservices.directorysearcher
$search.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"
$systems = $search.findall()

$output = "Server`tIP Address`tAdapter Description`tSubnet Mask`tGateway`tMAC Address`tDNS1 DNS2 DNS3 DNS4 DNS5`tWINS Primary`tWINS Secondary"
Add-Content $output -path $outfile

ForEach($system in $systems){
	$system = [string]$system.Properties.name
	$adapters = gwmi Win32_networkadapterconfiguration -computer $system
	if($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Write-Host $output
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		ForEach($adapter in $adapters){
			if($adapter.ipenabled -eq "true"){
				$mac = [string]$adapter.macaddress
				$desc = [string]$adapter.description
				$IP = [string]$adapter.ipaddress
				$DNS = [string]$adapter.dnsserversearchorder
				$mask = [string]$adapter.ipsubnet[0]
				$gw = [string]$adapter.defaultipgateway
				$wins1 = [string]$adapter.winsprimaryserver
				$wins2 = [string]$adapter.winssecondaryserver
				
				$output = $system + "`t" + $ip + "`t" + $desc + "`t" + $mask + "`t" + $gw + "`t" + $mac + "`t" + $dns + "`t" + $wins1 + "`t" + $wins2
				Write-Host $output
				Add-Content $output -path $outfile
			}
		}
	}
}