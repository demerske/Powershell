$path = Read-Host "Enter listfile"

$list = Get-Content $path

ForEach($itm in $list){

	$stop = "psexec \\$itm net stop wuauserv"
	$start = "psexec \\$itm net start wuauserv"
	$reg = "psexec \\$itm reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v susclientid"

	Invoke-expression $stop
	Invoke-expression $reg
	Invoke-expression $start
}

ForEach($itm in $list){
	$reset = "psexec \\$itm wuauclt /resetauthorization /detectnow"

	Invoke-Expression $reset
}