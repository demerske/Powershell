$comp = Read-Host "Enter computername"
$outfile = Read-Host "Enter Outfile full path"
ri $outfile

$shares = gwmi Win32_Share -computername $comp

ForEach($share in $shares){
	$name = [string]$share.name
    $perms = get-acl \\$comp\$name
    ForEach($perm in $perms){
		$access = $perm.access
        ForEach($a in $access){
            $id = [string]$a.IdentityReference
            $rights = [string]$a.FileSystemRights
            $output = "\\$comp\$name`t" + $id + "`t" + $rights
            Write-Host $output
            Add-Content $output -path $outfile
        }
    }
}