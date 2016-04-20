$path = #path to clear

$folders = @()

ForEach($folder in (gci $path -recurse | ?{$_.psiscontainer})){
    $folders += new-object PSObject -property @{
        Object = $folder
        Depth = ($folder.fullname.split("\")).count
    }
}

$folders = $folders | Sort Depth -Descending

ForEach($folder in $folders){
    If($folder.object.getfilesysteminfos().count -eq 0){
        remove-item $folder.object.fullname -force
        Write-Host $folder.object.fullname
    }
}