#========================================================================
# Created with: SAPIEN Technologies, Inc., PowerShell Studio 2012 v3.0.2
# Created on:   05/14/2012 4:08 PM
# Created by:   kdemers
# Organization: Nelnet, Inc.
# Filename:     ServerInfoUpdate.ps1
#========================================================================

$erroractionpreference = "SilentlyContinue"

$find = New-Object system.directoryservices.directorysearcher
$patchdays = @("1st cycle","2nd cycle","3rd cycle","4th cycle","Skip")
$1stcyc = @("3am","4am","5am","6am","7pm","8pm","Skip")
$2ndcyc = @("10pm","11pm","Skip")
$3rdcyc = @("1pm","10pm","11pm","Skip")
$4thcyc = @("4am","Skip")
$rebootset = @("Normal","NoReboot","Skip")
$exemptset = @("Normal","Exempt","Skip")
$platforms = @("Physical","Virtual Machine","Cisco UCS","Skip")

Write-Host "This script updates the Active Directory attributes of the server specified.`nIf the information is unknown leave blank."

$overloop = $true
while($overloop -eq $true){

	$valid = $false
	while($valid -eq $false){
		$name = Read-Host "Enter server name"
		if($name -ne ""){$find.filter = "(&(objectcategory=computer)(name=$name))"
			$comp = $find.findone()
			if($comp -ne $null){$valid = $true}
		}
	}

	$desc = Read-Host "Enter Description"

	$loop = $true
	while($loop -eq $true){
		Remove-Variable $a1
		Write-Host "Select Platform:"
		$i = 0
		while($i -le ($platforms.count - 1)){
			Write-Host $i $platforms[$i]
			$i++
		}
		[int]$a1 = Read-Host "Selection:"
		If(($a1 -is [int]) -and ($a1 -le ($platforms.count -1))){$plat = $platforms[$a1]
			$loop = $false
		}
	}
	
	$eco = Read-Host "Enter Ecosystem (See Server Info sheet for examples.)"

	$sub = Read-Host "Enter Subset (Archetype or Customer)"

	$env = Read-Host "Enter Environment (PROD, DEV, TEST,...):"

	$loop = $true
	while($loop -eq $true){
		Remove-Variable a2
		$i = 0
		Write-Host "Select Patch Day"
		while($i -le ($patchdays.count - 1)){
			Write-Host $i $patchdays[$i]
			$i++
		}
		[int]$a2 = Read-Host "Selection:"
		If(($a2 -is [int]) -and ($a2 -le ($patchdays.count - 1))){$pday = $patchdays[$a2]
			$loop = $false
		}
	}

	$loop = $true
	while($loop -eq $true){
		If($pday -ne ""){
			Remove-Variable a3
			If($pday -eq "1st cycle"){
				Write-Host "Select Time:"
				$i = 0
				while($i -le ($1stSun.count - 1)){
					Write-Host $i $1stSun[$i]
					$i++
				}
				[int]$a3 = Read-Host "Selection:"
				If(($a3 -is [int]) -and ($a3 -le ($1stSun.count -1))){$ptm = $1stSun[$a3]
					$loop = $false
				}
			}
			If($pday -eq "2nd cycle"){
				Write-Host "Select Time:"
				$i = 0
				while($i -le ($2ndThur.count - 1)){
					Write-Host $i $2ndThur[$i]
					$i++
				}
				[int]$a3 = Read-Host "Selection:"
				If(($a3 -is [int]) -and ($a3 -le ($2ndThur.count -1))){$ptm = $2ndThur[$a3]
					$loop = $false
				}
			}
			If($pday -eq "3rd cycle"){
				Write-Host "Select Time:"
				$i = 0
				while($i -le ($3rdThur.count - 1)){
					Write-Host $i $3rdThur[$i]
					$i++
				}
				[int]$a3 = Read-Host "Selection:"
				If(($a3 -is [int]) -and ($a3 -le ($3rdThur.count -1))){$ptm = $3rdThur[$a3]
					$loop = $false
				}
			}
			If($pday -eq "4th cycle"){
				Write-Host "Select Time:"
				$i = 0
				while($i -le ($4thSun.count - 1)){
					Write-Host $i $4thSun[$i]
					$i++
				}
				[int]$a3 = Read-Host "Selection:"
				If(($a3 -is [int]) -and ($a3 -le ($4thSun.count -1))){$ptm = $4thSun[$a3]
					$loop = $false
				}
			}
		}
	}
		

	$loop = $true
	while($loop -eq $true){
		Remove-Variable a4
		Write-Host "Select Reboot Option:"
		$i = 0
		while($i -le ($rebootset.count - 1)){
			Write-Host $i $rebootset[$i]
			$i++
		}
		[int]$a4 = Read-Host "Selection:"
		If(($a4 -is [int]) -and ($a4 -le ($rebootset.count - 1))){$rbt = $rebootset[$a4]
			$loop = $false
		}
	}

	$loop = $true
	while($loop -eq $true){
		Remove-Variable a5
		Write-Host "Select Exemption Option:"
		$i = 0
		while($i -le ($exemptset.count - 1)){
			Write-Host $i $exemptset[$i]
			$i++
		}
		[int]$a5 = Read-Host "Selection:"
		If(($a5 -is [int]) -and ($a5 -le ($exemptset.count - 1))){$exempt = $exemptset[$a5]
			$loop = $false
		}
	}

	$rloc = Read-Host "Enter Rack Location (R##C##U##)"

	$loop = $true
	while($loop -eq $true){
		$bown = Read-Host "Enter Business Owner: (Last, First)"
		if($bown -ne ""){$bown = $bown.split(",")
			$bf = $bown[1].trim()
			$bl = $bown[0].trim()
			$find.filter = "(&(sn=$bl)(givenname=$bf))"
			$bown = $find.findone()
			$bname = [string]$bown.properties.name
			$bown = [string]$bown.properties.distinguishedname
			if($bown -ne ""){$loop = $false}
		}
		Else{$loop = $false}
	}

	$loop = $true
	while($loop -eq $true){
		$town = Read-Host "Enter Technical Owner: (Last, First)"
		if($town -ne ""){$town = $town.split(",")
			$tf = $town[1].trim()
			$tl = $town[0].trim()
			$find.filter = "(&(sn=$tl)(givenname=$tf))"
			$town = $find.findone()
			$tname = [string]$town.properties.name
			$town = [string]$town.properties.distinguishedname
			if($town -ne ""){$loop = $false}
		}
		Else{$loop = $false}
	}

	Write-Host "You Entered the following values:"
	Write-Host "Name: $name"
	Write-Host "Description: $desc"
	Write-Host "Platform: $plat"
	Write-Host "Ecosystem: $eco"
	Write-Host "Subset: $sub"
	Write-Host "Environment: $env"
	Write-Host "Patch Group: $pday $ptm"
	Write-Host "Patch Reboot: $rbt"
	Write-Host "Patch Exemption: $exempt"
	Write-Host "Rack Location: $rloc"
	Write-Host "Business Owner: $bname"
	Write-Host "Technical Owner: $tname"
	
	$loop = $true
	while($loop -eq $true){
		$confirm = Read-Host "Is this correct? (Y/N):"
		$confirm.tolower()
		
		if($confirm -eq "y"){
			$find.filter = "(&(objectcategory=computer)(name=$name))"
			$comp = $find.findone()
			$comp = [adsi]$comp.path
			if($desc -ne ""){$comp.description = $desc}
			if($plat -ne "Skip"){$comp.employeetype = $plat}
			if($eco -ne ""){$comp.department = $eco}
			if($sub -ne ""){$comp.departmentnumber = $sub}
			if($env -ne ""){$comp.businesscategory = $env}
			if($pday -ne "Skip"){$comp.extensionattribute1 = $pday}
			if($ptm -ne "Skip"){$comp.extensionattribute2 = $ptm}
			if($rbt -ne "Skip"){$comp.extensionattribute3 = $rbt}
			if($exempt -ne "Skip"){$comp.extensionattribute4 = $exempt}
			if($rloc -ne ""){$comp.physicaldeliveryofficename = $rloc}
			if($bown -ne ""){$comp.managedby = $bown}
			if($town -ne ""){$comp.manager = $town}
			$comp.setinfo()
			$loop = $false
			$overloop = $false
		}

		elseif($confirm -eq "n"){$loop = $false}
	}
}
