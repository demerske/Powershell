$user = Read-Host "Enter user NT ID"

$AdObj = New-Object System.Security.Principal.NTAccount($user)
$strSID = $AdObj.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value