$Path = Read-Host "Enter Listfile Path"
$safelist = @(#array of usernames to ignore#)
$systems = Get-content $path
ForEach($system in $systems){([adsi] "WinNT://$system").psbase.children | ?{$_.SchemaClassName -match "user"} | ForEach-Object{if(($safelist -notcontains $_.Name) -and ($_.psbase.properties.lastlogon -eq $null)){$_.psbase.invokeset("AccountDisabled", "False") 
$_.setinfo()}}}