$find = new-object system.directoryservices.directorysearcher
$list = import-csv "$env:userprofile\desktop\massavreport.csv"
$dom = Read-Host "Enter domain"

ForEach($itm in $list){
	If($itm.domain.tolower() -eq $dom){
		$comp = $itm.system
		$bo = $itm.businessowner
		$to = $itm.technicalowner
		$find.filter = "(&(objectcategory=computer)(name=$comp))"
		$comp = $find.findone()
		$comp = [adsi]$comp.path
		If($bo -ne ""){$comp.givenname = $bo}
		If($to -ne ""){$comp.middlename = $to}
		$comp.setinfo()
	}
}