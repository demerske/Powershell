$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=user)(extensionattribute12=*))"
$find.pagesize = 1000000

$users = $find.findall()

ForEach($user in $users){
	$team = [string]$user.properties.extensionattribute12
	$name = [string]$user.properties.samaccountname
	Add-Content $name -path "$env:userprofile\desktop\teams\$team.txt"
}

$files = gci "$env:userprofile\desktop\teams"

ForEach($file in $files){
	$fname = $file.name.replace(".txt","")
	$count = get-content $file.fullname
	$count = $count.count
	If($count -eq $null){$count = 1}
	$output = $fname + "`t" + $count
	Write-Host $output
	Add-Content $output -path "$env:userprofile\desktop\teamcounts.txt"
}