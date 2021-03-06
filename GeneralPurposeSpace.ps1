$find = new-object system.directoryservices.directorysearcher
$list = get-content "$env:userprofile\desktop\list.txt"

ForEach($itm in $list){
	$find.filter = "(&(objectcategory=group)(name=$itm))"
	$itm = $find.findone()
	$itm = [adsi]$itm.path
	$mems = $itm.member
	
	ForEach($mem in $mems){
		$name = ([adsi] "LDAP://$mem").name
		$output = [string]$itm.name + "`t" + $itm.description + "`t" + $name + "`t" + $mem
		Write-Host $output
		#Add-Content $output -path "$env:userprofile\desktop\oldgroups.txt"
		$itm.remove("LDAP://$mem")
	}
}

#ForEach($itm in $list){
#$find.filter = "(&(objectcategory=group)(name=$itm))"
#$itm = $find.findone()
#$itm = [adsi]$itm.path
#$itm.deleteobject(0)}


$sqlconn = new-object System.Data.SqlClient.SqlConnection
$sqlconn.ConnectionString = "server='Den-334737D';database='FileScanner';trusted_connection=true;"
$sqlconn.open()
$cmd = new-object System.Data.SqlClient.SqlCommand
$cmd.connection = $sqlconn

$cmd.commandtext = "Select Distinct Herp from Terble Where Host like '$env:computername'"
$herps = @()
$reader = $cmd.executereader()
$counter = $reader.FieldCount

while($reader.read()){
    For($i = 0; $i -lt $counter; $i++){
        $herps += $reader.getvalue($i)
    }
}

$sqlconn.close()