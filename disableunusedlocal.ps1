$Path = Read-Host "Enter Listfile Path"
$safelist = @(#account names to ignore#)
$systems = Get-content $path

ForEach($system in $systems){$users = ([adsi] "WinNT://$system").psbase.children | ?{$user.SchemaClassName -match "user"}
	ForEach-Object{
		if(($safelist -notcontains $user.Name) -and ($user.psbase.properties.lastlogon -eq $null)){
			$user.psbase.invokeset("AccountDisabled", "True") 
			$user.setinfo()
			$output = $system + ", " + $user.name
			Add-Content $output -path "c:\scripting\txt\disabledacct.txt"
		}
	}
}