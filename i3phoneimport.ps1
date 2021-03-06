$find = new-object system.directoryservices.directorysearcher

$file = "path to import.csv"

$list = import-csv $file

ForEach($itm in $list){
	$name = $itm.name
	$find.filter = "(&(objectcategory=user)(samaccountname=$name))"
	$user = $find.findone()
	If($user -ne $null){
		$user = [adsi]$user.path
		$tel = $itm.DIN1 + "  (" + $itm.Extension + ")"
		$user.telephonenumber = $tel
		$user.setinfo()
	}
}