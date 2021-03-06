$Path = Read-Host "Enter Listfile Path"
$safelist = @("safe", "account", "array", "goes", "here")
$systems = Get-content $path
ForEach($system in $systems){
	([adsi] "WinNT://$system").psbase.children | ?{$_.SchemaClassName -match "user"} | `
		ForEach-Object{
			if(($safelist -notcontains $_.Name) -and ($_.psbase.properties.lastlogon -eq $null)){
				([adsi] "WinNT://$system").psbase.children.remove("WinNT://$system" + "/" + $_.Name)
			}
		}
	}