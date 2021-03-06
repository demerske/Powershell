Add-PSSnapin Compellent.StorageCenter.PSSnapin

$user = Read-Host "Username"
$pw = Read-Host -assecurestring "Password"
$chost = Read-Host "Compellent Server"
$sname = Read-Host "Server Name"

$cnx = Get-SCConnection -host $chost -user $user -password $pw -save def

$server = Get-SCServer -name $sname -connection $cnx

Write-Host "Name:`t" + $server.name
Write-Host "Parent Server:`t" + $server.parentserver
Write-Host "Parent Folder:`t" + $server.parentfolder

$answer = Read-Host "Continue with Removal? (Y/N)"

If($answer.tolower() -eq "y"){
    Remove-SCServer -SCServer $server -connection $cnx -confirm
}
Else{Write-Host "Nothing Done"}