$list = "c:\scripting\txt\list.txt" #Read-Host "Input Listfile"
#$outfile = Read-Host "Enter Outfile"
$systems = Get-content $list

ForEach($system in $systems){
	If(test-connection $system -count 2 -quiet){$output = $system + "`tUp"}
	Else{$output = $system + "`tDown"}
	Write-Host $output
	Add-Content $output -path $outfile
}