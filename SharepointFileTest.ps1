$wc = new-object System.Net.WebClient
#$wc.credentials = get-credential
#$wc.Credentials = [System.Net.CredentialCache]::DefaultCredentials
$wc.usedefaultcredentials = $true
$file = "c:\scripting\txt\list.txt"
$uploadname = "#sharepoint web path#"
$wc.uploadfile($uploadname,"PUT",$file)