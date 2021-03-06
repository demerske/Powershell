#Check number of startup events in system log
(gwmi win32_ntlogevent -computer Computername -filter "Logfile='System' And EventCode='6009'" | where {(([system.management.managementdatetimeconverter]::ToDateTime($_.timewritten)) -le ((get-date).adddays(-30))) -eq $true}).count

#check number of errors in system log
(gwmi win32_ntlogevent -computer Computername -filter "Logfile='System' And Type='Error'" | where {(([system.management.managementdatetimeconverter]::ToDateTime($_.timewritten)) -le ((get-date).adddays(-30))) -eq $true}).count

#check drive free space
gwmi win32_logicaldisk -computer Computername | Where {$_.drivetype -eq 3} | ForEach-Object{Write-Host $_.deviceID, ((($_.freespace /1GB)/($_.size /1GB)) * 100).tostring().substring(0,2).replace(".","")}

#check last boot time
[system.management.managementdatetimeconverter]::ToDateTime((gwmi -computer Computername -class win32_operatingsystem).lastbootuptime)

#check service status
(gwmi win32_service -computer Computername -filter "Name='nameofservice'").status