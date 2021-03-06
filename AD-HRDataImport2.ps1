$erroractionpreference = "Continue"
$mgrlog = "$env:temp\fixmanagers.txt"
$allpeople = "$env:temp\allusers.txt"
$faillog = "$env:temp\hremployeeimportfailures.txt"
ri $mgrlog
ri $allpeople
ri $faillog

$date = (get-date).toshortdatestring().replace("/","-")
$date = $date.split("-")
$date = $date[2] + "-" + $date[0] + "-" + $date[1]

$file = #path to import csv file

$list = import-csv $file
$find = new-object system.directoryservices.directorysearcher
$find.searchroot = "LDAP://OU=User Accounts,DC=yourdomain,DC=com"
$error.clear()

ForEach($itm in $list){

	$logon = $itm.domain
	$logon = $logon.split("\")
	$domain = $logon[0]
	$logon = $logon[1]

	If(($domain -eq "YourDomain") -or ($domain -eq "")){

		$firstname = $itm.first_name
		$lastname = $itm.last_name
		$mi = $itm.middle_initial
		if($mi -eq "Null"){$mi = ""}
		$listout = $firstname + "`t" + $lastname
		Add-Content $listout -path $allpeople
		$eid = $itm."clock_#"
		$dept = $itm.Department
		$cc = $itm.cost_center
		$div = $cc.substring(0,2)
		$comp = $itm.company
		$hrtype = $itm.HR_Status
		$title = $itm.title
		$loc = $itm.location
		$nlev = $itm.nelnet_level
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
		If($users -eq $null){
			$output = $firstname + "`t" + $lastname + "`tNot Found"
			Add-Content $output -path "$env:temp\usersnotfound.txt"
		}

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
				If([string]$nlev -ne ""){$user.employeenumber = $nlev}
				$user.setinfo()
				If($error[0].exception -ne $null){
					$output = $user.name + "`t" + $error[0].exception.message.tostring()
					Add-Content $output -path $faillog
					$error.clear()
				}
			}
			Else{Add-Content $output -path $faillog}
		}
	}
}

$fixmgr = get-content $mgrlog
$fixmgr = $fixmgr | select -unique
remove-item $mgrlog
Add-Content $fixmgr -path $mgrlog

$oldoutfile = #path to old file

ri $oldoutfile
$content = get-content $file
ri $file
Add-Content $content -path $oldoutfile


$logs = gci "c:\scriptlib\tempspace\adsynclogs"

$smtpserver = "smtprelay.yourdomain.com"
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = “scripted@yourdomain.com”
$msg.To.Add("user@yourdomain.com")
$msg.Subject = "Vista to AD Sync logs"
$msg.Body = "logs attached."

ForEach($log in $logs){$log = $log.fullname
	$att = new-object Net.Mail.Attachment($log)
	$msg.Attachments.Add($att)
}

$smtp.Send($msg)

$att.dispose()
$msg.dispose()