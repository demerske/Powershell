$outfile = "c:\windows\temp\DomainAdminGroupMembers.txt"
Remove-Item $outfile
$error.clear()

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(memberof=CN=Domain Admins,DC=yourdomain,DC=com)"
$members = $find.findall()
$grouproot = "Domain Admins"

ForEach($member in $members){

	If($member.properties.objectcategory -match "CN=Person*"){$type = "user"}
	ElseIf($member.properties.objectcategory -match "CN=Group*"){$type = "group"}

	$output = [string] $grouproot + "`t" + $member.properties.name + "`t" + $type

	Write-Host $output
	Add-Content $output -path $outfile
}

ForEach($member in $members){

	If($member.properties.objectcategory -match "CN=Group*"){

		Add-Content "" -path $outfile

		$find2 = new-object system.directoryservices.directorysearcher
		$sdn = $member.properties.distinguishedname
		$groupname = $member.properties.name
		$find2.Filter = "(memberof=$sdn)"
		$submembers = $find2.findall()

		ForEach($sub in $submembers){

			If($sub.properties.objectcategory -match "CN=Person*"){$type = "user"}
			ElseIf($sub.properties.objectcategory -match "CN=Group*"){$type = "group"}

			$output = [string] $groupname + "`t" + $sub.properties.name + "`t" + $type

			Write-Host $output
			Add-Content $output -path $outfile
		}
	}
}

$filename = $outfile
$smtpServer = "smtprelay.yourdomain.com"

$msg = new-object Net.Mail.MailMessage
$att = new-object Net.Mail.Attachment($filename)
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$msg.From = "scripted@yourdomain.com"
$msg.To.Add("user@yourdomain.com")
$msg.Subject = "Domain Admins Members and submembers"
$msg.Body = "This is a list of the direct and 1 sublevel indirect members of the Domain Admins group for the domain"
$msg.Attachments.Add($att)

$smtp.Send($msg)

$att.dispose()
$msg.dispose()