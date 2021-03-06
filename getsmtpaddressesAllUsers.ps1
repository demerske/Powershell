$erroractionpreference = "SilentlyContinue"

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=user)(objectclass=user))"

$list = $find.findall()

ForEach($itm in $list){
	$name = [string]$itm.properties.name
	$emails = $itm.properties.proxyaddresses
	ForEach($email in $emails){
		If($email.startswith("smtp:") -eq $true){
			$email = $email.replace("smtp:","")
			$output = $name + "`t" + $email
			Add-Content $output -path "$env:userprofile\desktop\smtpaddresses.txt"
		}
	}
}