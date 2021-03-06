$source = Read-Host "Enter source drive letter (c:\)"
$dest = Read-Host "Enter Destination drive letter (d:\)"
$old = gci $source -recurse
$source = $source.toupper()
$dest = $dest.toupper()

ForEach($itm in $old){
	$path = $itm.fullname
	$new = $path.replace("$source","$dest")
	$acl = get-acl $path
	Set-acl $new -aclobject $acl
	Write-Host $path, $new
}