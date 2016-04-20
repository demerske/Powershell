$DateToCompare = (Get-date).AddYears(-7)
Get-Childitem C:\ –recurse | where-object {$_.lastwritetime –lt $DateToCompare} | Out-File "$env:userprofile\desktop\Output.txt"