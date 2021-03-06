$find = new-object system.directoryservices.directorysearcher
$find.searchroot = $Null
$team = Read-Host "Enter Team"
$find.filter = "(&(objectcategory=group)(name=$team))"

$grp = $find.findone()
$grp = [adsi]$grp.path

$list = $grp.member

ForEach($itm in $list){$usr = [adsi]"LDAP://$itm"
    $mgr = $usr.manager
    $mgr = [adsi]"LDAP://$mgr"
    $mgr = $mgr.name
    $usr = $usr.name
    $output = $usr + "`t" + $mgr
    Write-Host $output
}