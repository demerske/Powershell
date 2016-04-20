$os = gwmi win32_operatingsystem | Select caption

$safe = @('Administrator','Default','Default user','Public')
$upaths03 = @('\local settings\temp','\local settings\temporary internet files','\cookies')

$cleanpaths = @('c:\temp','c:\windows\temp','c:\recycler')

If($os.caption.contains('2008')){
    $ufold = gci 'c:\users'
    ForEach($uf in $ufold){
        If($safe -notcontains $uf.name){
            $temp = $uf.fullname + "\appdata\local\temp"
            gci $temp | ForEach-Object{ri $_.fullname -recurse -force -confirm:$false -erroraction silentlycontinue}
        }
    }
}

If($os.caption.contains('2003')){
    $ufold = gci 'c:\documents and settings'
    ForEach($uf in $ufold){
        If($safe -notcontains $uf.name){
            ForEach($suf in $upaths03){
                $path = $uf.fullname + $suf
                gci $path | foreach-object{ri $_.fullname -recurse -force -confirm:$false -erroraction silentlycontinue}
            }
        }
    }
}

ForEach($a in $cleanpaths){
    $subs = gci $a
    $subs | ForEach-Object{ri $_.fullname -recurse -force -confirm:$false -erroraction silentlycontinue}
}

If($os.caption.contains('2003'){
    $oldpatches = gci $env:windir | ?{$_.name.contains('ntuninstall')}
    $date = get-date
    ForEach($b in $oldpatches){
        $age = new-timespan $b.lastwritetime $date
        If($age.days -gt 90){
            ri $b.fullname -recurse -force -confirm:$false -erroraction silentlycontinue
        }
    }
}