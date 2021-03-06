$outfile = "$env:userprofile\desktop\nomemberdeletions.txt" #Read-Host "Enter outfile"
Remove-Item $outfile
$find = new-object system.directoryservices.directorysearcher
$find.searchroot = $null #LDAP string to domain OU for groups to find
$find.filter = "(objectcategory=group)"
$find.pagesize = 10000
$list = $find.findall()

$output = "Name`tDescription`tManager`tCreated`tModified`tType`tValidated`tComments"
Add-content $output -path $outfile

ForEach($itm in $list){

	$name = [string] $itm.properties.name
	$mgr = [string] $itm.properties.managedby
	If($mgr -ne ""){$mgr = [adsi] "LDAP://$mgr"
		$mgr = $mgr.properties.name
	}
	$desc = [string] $itm.properties.description
	$desc = $desc.replace("`n"," ")
	$created = $itm.properties.whencreated
	$modified = $itm.properties.whenchanged
	$valid = $itm.properties.extensionattribute10
	$mems = $itm.properties.member
	If($itm.properties.samaccounttype -eq "268435456"){$type = "Security"}
	If($itm.properties.samaccounttype -eq "268435457"){$type = "Distribution"}
	
	$output = [string]$name + "`t" + $desc + "`t" + $mgr + "`t" + $created + "`t" +  $modified + "`t" + $type + "`t" + $valid

	#Write-Host $output
	If($mems -eq $null){$itm = [adsi]$itm.path
		Write-Host $output
		#$itm.deleteobject(0)
		add-content $output -path $outfile
	}
}

$file = $outfile
$excelApp = New-Object -ComObject Excel.Application
$objWorkbook = $excelApp.Workbooks.Open($file)
$excelapp.worksheets.item(1).usedrange.entirecolumn.autofilter()
$excelapp.worksheets.item(1).usedrange.entirecolumn.autofit()
$excelapp.activewindow.splitcolumn = 1
$excelapp.activewindow.splitrow = 1
$excelapp.activewindow.freezepanes = $true
$file = $file.Substring(0, $file.Length - 3) + "xls"
Remove-Item $file
$error.clear()
$objWorkbook.SaveAs($file, 1)
$objWorkbook.Close
$excelapp.quit()
Remove-Variable excelapp
[gc]::collect()