$Path = Read-Host "Enter Listfile Path"
$outfile = Read-Host "Enter outfile path"
$systems = Get-content $path

ForEach($system in $systems){$users = ([adsi] "WinNT://$system").psbase.children | ?{$_.SchemaClassName -match "user"}
	ForEach$user in $users){$output = $system + "`t" + $_.Name + "`t" + $_.psbase.properties.lastlogin
		Add-Content $output -path $outfile
	}
}