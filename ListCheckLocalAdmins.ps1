$computers = get-content "c:\scripting\txt\list.txt"

ForEach($comp in $computers){Test-Connection $comp -quiet -count 2}


ForEach($comp in $computers){

    $ladmins = [adsi]"WinNT://$comp/Administrators"
    $Adminmembers = @($ladmins.psbase.invoke("Members"))
    
    foreach($amem in $adminmembers){
        $amem.GetType().InvokeMember("Name", 'GetProperty', $null, $amem, $null)
    }
}