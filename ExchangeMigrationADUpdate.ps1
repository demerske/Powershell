$erroractionpreference = "Continue"

$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000

$outfile = "$env:userprofile\desktop\ExchangeReportCurrent.txt"
$outfile2 = "$env:userprofile\desktop\ExchangeReportChanged.txt"
ri $outfile
ri $outfile2
$error.clear()

$ohomeMTA = "Old homeMTA value here"
$ohomeMDB = "old homeMDB value here"
$omsExchHomeServerName = "old msExchHomeServerName here"

$nhomeMTA = "Put new homeMTA value here"
$nhomeMDB = "Put new homeMDB value here"
$nmsExchHomeServerName = "Put new msExchHomeServerName value here"

$change = $false #Change $false to $true to make changes. 

$find.filter = "(&(&(homemta=$ohomemta)(homeMDB=$ohomeMDB)(msexchhomeservername=$omsexchhomeservername)))"

$list = $find.findall()

ForEach($itm in $list){
	$itm = [adsi]$itm.path
	$name = $itm.name
	$MDB = $itm.homeMDB
	$MTA = $itm.homeMTA
	$EHSN = $itm.msExchHomeServerName
	$output = [string]$name + "`t" + $MDB + "`t" + $MTA + "`t" + $EHSN
	Write-Host $output
	Add-Content $output -path $outfile
	If($change -eq $true){
		$itm.homeMDB = $nhomeMDB
		$itm.homeMTA = $nhomeMTA
		$itm.msExchHomeServerName = $nmsExchHomeServerName
		$itm.setinfo()
		If($error[0].exception -ne $null){
			$output = [string]$name + "`tFailed`t" + $error[0].exception.message.tostring()
			$error.clear()
		}
		Else{
			$itm = [adsi]$itm.path
			$name = $itm.name
			$MDB = $itm.homeMDB
			$MTA = $itm.homeMTA
			$EHSN = $itm.msExchHomeServerName
			$output = [string]$name + "`t" + $MDB + "`t" + $MTA + "`t" + $EHSN
		}
		Write-Host $output
		Add-Content $output -path $outfile2
	}
}