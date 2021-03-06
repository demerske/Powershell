$erroractionpreference = "Continue"
$mgrlog = "$env:temp\fixmanagers.txt"
$allpeople = "$env:temp\allusers.txt"
$faillog = "$env:temp\hremployeeimportfailures.txt"
ri $mgrlog
ri $allpeople
ri $faillog

$file = "$env:userprofile\desktop\ActiveDirectoryFile.xls"
#$file = $file.fullname
$fout = "$env:temp\adtemp.csv"

$excelapp = new-object -com Excel.Application
$excelapp.displayalerts = $false
$excelapp.visible = $true
$excelapp.workbooks.open($file)
$sheet = $excelapp.worksheets.item(1)
$i = 1
While($i -le 13){
	$a1 = $sheet.cells.item(1,$i).value()
	$a1n = $a1.replace(" ","").replace("#","")
	$sheet.cells.item(1,$i).replace($a1,$a1n)
	$i = $i + 1
}
$sheet.saveas($fout,6)
$excelapp.quit()
[gc]::collect()


$list = import-csv $fout
$find = new-object system.directoryservices.directorysearcher
$error.clear()

ForEach($itm in $list){

	$logon = $itm.domain
	$logon = $logon.split("\")
	$logon = $logon[1]
	
	$firstname = $itm.firstname
	$lastname = $itm.lastname
	$mi = $itm.middleinitial
	if($mi -eq "Null"){$mi = ""}
	$listout = $firstname + "`t" + $lastname
	Add-Content $listout -path $allpeople
	$eid = $itm.clock
	$dept = $itm.Department
	$cc = $itm.costcenter
	$div = $cc.substring(0,2)
	$comp = $itm.company
	$hrtype = $itm.HRStatus
	$title = $itm.title
	$loc = $itm.location
	If($itm.supervisor -ne ""){
		$sup = $itm.Supervisor
		$sup = $sup.split(",")
		$a = $sup[0]
		$b = $sup[1]
		$b = $b.trim()
		$b = $b.split()
		$b = $b[0]
		$find.filter = "(&(sn=$a)(givenname=$b))"
		$mgr = $find.findone()
		$mgr = [string] $mgr.properties.distinguishedname}
	Else{$mgr = ""}
	
	If($mgr -eq ""){Add-Content $itm.supervisor -path $mgrlog}
	
	$output = $firstname + "`t" + $lastname + "`t" + $dept + "`t" + $cc + "`t" + $hrtype + "`t" + $mgr + "`t" + $title + "`t" + $div
	#Write-Host $output
	#Add-Content $output -path "$env:temp\temp.txt"}
		
	$find.filter = "(employeeid=$eid)"
	#$find.filter = "(&(sn=$lastname)(givenname=$firstname))"

	$users = $find.findall()

	ForEach($user in $users){
		If($user -ne $null){
			$user = [adsi] $user.path
			#Write-Host $user.name
			If([string]$lastname -ne ""){$user.sn = $lastname}
			If([string]$firstname -ne ""){$user.givenname = $firstname}
			If([string]$mi -ne ""){$user.initials = $mi}
			If([string]$comp -ne ""){$user.company = $comp}
			If([string]$dept -ne ""){$user.department = $dept}
			If([string]$cc -ne ""){$user.departmentnumber = $cc}
			If([string]$div -ne ""){$user.division = $div}
			If([string]$hrtype -ne ""){$user.EmployeeType = $hrtype}
			If([string]$title -ne ""){$user.title = $title}
			If([string]$mgr -ne ""){$user.manager = $mgr}
			If([string]$loc -ne ""){$user.physicaldeliveryofficename = $loc}
			$user.setinfo()
			If($error[0].exception -ne $null){
				Write-Host $user.name, $error[0].exception.message.tostring()
				$error.clear()
			}
		}
		Else{Add-Content $output -path $faillog}
	}
}

$fixmgr = get-content $mgrlog
$fixmgr = $fixmgr | select -unique
remove-item $mgrlog
Add-Content $fixmgr -path $mgrlog

#ri $file
ri $fout