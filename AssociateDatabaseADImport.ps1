$inpath = #path to input csv file
$list = import-csv "$inpath"

ForEach($itm in $list){

	$name = $itm.name.split()
	$firstname = $name[0]
	$lastname = $name[1]
	$loc = $itm.location.split(",")
	$city = $loc[0]
	If($loc[1] -eq $null){$state = $null}
	Else{$state = $loc[1].trim()}
	$phone = $itm.officenumber
	$cell = $itm.mobile
	$pager = $itm.pager

	$output = $name + "`t" + $firstname + "`t" + $lastname + "`t" + $city + "`t" + $state + "`t" + $phone + "`t" + $cell + "`t" + $pager
	Write-Host $output

	$find = new-object system.directoryservices.directorysearcher
    $find.searchroot = #LDAP Search root
	$find.filter = "(&(givenName=$firstname)(sn=$lastname))"
	$users = $find.findall()

	ForEach($user in $users){
		If($user -ne $null){
			$user = [adsi] $user.path
			Write-Host $user.name
			If($city -ne ""){$user.l = $city}
			If($state -ne ""){$user.st = $state}
			If($cell -ne ""){$user.mobile = $cell}
			If($pager -ne ""){$user.pager = $pager}
			If($phone -ne ""){$user.telephoneNumber = $phone}
			$user.setinfo()
		}
		Else{
			Add-Content $itm.name -path "$env:userprofile\desktop\badaccountnames.txt"
		}
	}
}