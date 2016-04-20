$objWMIService = get-service
$conn = New-Object system.data.sqlclient.sqlconnection(#SQL Connection String#)
$conn.Open()
$cmd = $conn.CreateCommand()
#foreach ($i in $objWMIService) { write-host $i.Name, $i.Status }
foreach ($i in $objWMIService) {
	$cmd.CommandText = "INSERT INTO [dbo].[test_services] ([Name],[Status]) VALUES ('$($i.ServiceName)','$($i.Status)')"
	Try {$cmd.ExecuteNonQuery() }
	Catch { write-warning "$_" }
}
$conn.close()
