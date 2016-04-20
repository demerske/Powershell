#$list = Get-Content "Something"
$list = @("$env:computername")
$DNS = "10.0.0.1","10.0.0.2","10.0.0.3"

ForEach($itm in $list){
	$NICs = gwmi win32_networkadapterconfiguration -computer $itm -filter "IPEnabled=TRUE"
	ForEach($nic in $nics){$nic.setdnsserversearchorder($dns)}
}