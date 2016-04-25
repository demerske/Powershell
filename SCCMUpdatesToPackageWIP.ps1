$ContentID = @()
$ContentPath = @()
$comp = $env:computername
$nsp = "root\sms\site_Name"

Import-Module bitsTransfer

$path = '\\SCCMServer\C$\Temp\'

$ul = Get-WmiObject -ComputerName $comp -Namespace $nsp -Class SMS_AuthorizationList -Filter "CI_ID = '64296'"
$ul = [wmi]$ul.__PATH
$list = $ul.updates
ForEach($itm in $list){
	$objCI = Get-WmiObject -ComputerName $comp -Namespace $nsp -Class SMS_CIToContent -Filter "CI_ID = '$itm'"
	$ciContentID = $objCI.ContentID
	$ContentUniqueID = $objCI.ContentUniqueID

	$objContent = Get-WmiObject -ComputerName $comp -Namespace $nsp -Class SMS_CIContentFiles -Filter "ContentID = '$ciContentID'"

	$ciContentPath = $path + $ContentUniqueID
	New-Item -Path $path -Name $ContentUniqueID -ItemType directory

	$url = $objContent.SourceURL
	$file = $ciContentPath + "\" + $objContent.FileName
	start-bitsTransfer -Source $url -Destination $file
	
	$ContentPath += "$ciContentPath"
	$ContentID += $ciContentID
}

$pkg = gwmi -Class SMS_SoftwareUpdatesPackage -computer $comp -Namespace $nsp -Filter "PackageID = 'OMA001BA'"
$pkg = [wmi]$pkg.__PATH
$pkg.AddUpdateContent($ContentID,$ContentPath,$true)
Remove-Item -path "$path*" -recurce