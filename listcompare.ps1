$prefix = Read-Host "Enter path to files"
$path1 = Read-Host "Enter first list name"
$path2 = Read-Host "Enter second list name"
$output = Read-Host "Enter output file name"

$list1 = Get-Content "$prefix\$path1"
$list2 = Get-Content "$prefix\$path2"

ForEach($item in $list1){
	if($list2 -notcontains $item){
		Add-Content $item -path "$prefix\$output"
	}
}