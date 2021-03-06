$find = new-object system.directoryservices.directorysearcher
$find.pagesize = 10000

$inpath = Read-Host "Enter path to userlist"
$grpname = Read-Host "Enter group Name"

$find.filter = "(&(objectcategory=group)(name=$grpname))"
$grpname = $find.findone()
$grpname = [adsi]$grpname.path

$master = get-content $inpath

ForEach($obj in $master){
	$find.filter = "(&(objectcategory=user)(samaccountname=$obj))"
	$user = $find.findone()
	If($user -ne $null){
		$user = [adsi]$user.path
		$grpname.psbase.invoke("Add",$user.psbase.path)
	}
}