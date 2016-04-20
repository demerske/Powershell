$sroots = @(#array of LDAP connections for domains to search#)
$error.clear()

$find = new-object system.directoryservices.directorysearcher
$find.filter = "(&(objectcategory=computer)(operatingsystem=*Server*))"

ForEach($sroot in $sroots){
    $find.searchroot = $sroot

    $list = $find.findall()

    ForEach($itm in $list){
        $comp = [string]$itm.properties.name
        $cache = Gwmi -computer $comp -namespace "root\MicrosoftDNS" -Class "MicrosoftDNS_Cache"
        IF($error[0] -ne $null){
            Write-Host $comp, $error[0].exception.message.tostring()
            $error.clear()}
        Else{$cache.clearcache()}
    }
}