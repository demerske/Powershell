$outfile = Read-Host "Enter output file path"
$search = new-object system.directoryservices.directorysearcher
$search.filter = "(&(&(&(samAccountType=805306369)(!(primaryGroupId=516)))(objectCategory=computer)(operatingSystem=Windows Server*)))"
$SystemDN = $search.findall()
foreach($object in $SystemDN){$systems = $systems + $object.properties.name}
foreach($system in $systems){$users = ([adsi] "WinNT://$system").psbase.children | ?{$_.SchemaClassName -match "user"}
	If($error[0].exception -ne $null){
		$output = $system + "`t" + $error[0].exception.message.tostring()
		Add-Content $output -path $outfile
		$error.clear()
	}
	Else{
		ForEach($user in $users){
			$output = $system + "`t" + $user.Name + "`t" + $user.psbase.properties.lastlogin
			Add-Content $output -path $outfile
		}
	}
}