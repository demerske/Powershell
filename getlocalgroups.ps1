$server = Read-Host "Enter ServerName"
$outfile = Read-Host "Enter full output filepath"
$computer = [ADSI]"WinNT://$server,computer"

$info = $computer.psbase.children | where { $_.psbase.schemaClassName -eq 'group' }

ForEach($a in $info){
	$aname = [string]$a.name
    $sinfo = [adsi]$a.psbase.path
    $smems = $sinfo.psbase.Invoke("Members") | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
    ForEach($smem in $smems){
		$output = $aname + "`t" + $smem
        Write-Host $output
        Add-Content $output -path $outfile
    }
}