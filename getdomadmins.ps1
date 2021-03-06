$find = new-object system.directoryservices.directorysearcher
$tempout = "c:\scripting\output\daout.txt"

$find.filter = "(&(objectcategory=group)(name=Domain Admins))"

$da = $find.findone()

$da = [adsi]$da.path

$members = $da.member

ForEach($mem in $members){Add-Content $mem -path $tempout}

$i = 0
While($i -le 10){
	$list = get-content $tempout
	$list = $list | Select -unique

	ForEach($itm in $list){$itm = [adsi]"LDAP://$itm"
		$members = $itm.member
		ForEach($mem in $members){Add-Content $mem -path $tempout}
	}
	$i++
}

$list = get-content $tempout

$list = $list | Select -Unique

ri $tempout
Add-Content $list -path $tempout