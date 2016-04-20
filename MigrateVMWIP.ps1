$error.clear()
add-pssnapin VMWare.VIMAutomation.Core
connect-viserver omvcsprd50

[Reflection.Assembly]::LoadWithPartialName(”System.Web”) | Out-Null
$plen = 16

$pwdmatch = $false
While($pwdmatch -eq $false){
    $pwd = [System.Web.Security.Membership]::GeneratePassword($plen,2)
    $pwdmatch = ($pwd -match “^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{$plen,$plen}$”)
}

$dstore = #datastore
$vhost = #vmhost
$nback = #network
$ngw = #gateway
$nmask = #netmask
$ndns = #dnsservers
$acct = "Administrator"
$pwd = Read-Host "Password"


$name = "tstw2k3x86flx"
$vm = get-vm $name
$fqdn = (get-vmguest -vm $vm).hostname
$nic = get-networkadapter -vm $vm
$back = $nic.networkname

#$bind = [adsi] "WinNT://$fqdn"
#$user = $bind.create("User",$acct)
#$user.setpassword($pwd)
#$user.setinfo()
#$user.fullname = $acct
#$user.setinfo()
#$user = [adsi]"WinNT://$fqdn/$acct,user"
#$admin = [adsi]"WinNT://$fqdn/Administrators,group"
#$admin.add($user.path)


shutdown-vmguest -vm $vm -confirm:$false

$pend = $Null
While($pend -ne "PoweredOff"){$pend = (get-vm $vm).powerstate}

move-vm -vm $vm -destination $vhost -datastore $dstore -confirm:$false

set-vm -vm $vm -version v8 -confirm:$false

start-vm -vm $vm

$up = $null
While($up -eq $null){$up = (get-vmguest -vm $vm).OSFullName}

update-tools -vm $vm

$up = $null
While($up -eq $null){$up = (get-vmguest -vm $vm).OSFullName}

$net = get-vmguestnetworkinterface -vm $vm -guestuser $acct -guestpassword $pwd

set-networkadapter $nic -type vmxnet3 -networkname $nback -connected $true -startconnected $true -confirm:$false

$nnet = get-vmguestnetworkinterface -vm $vm -guestuser $acct -guestpassword $pwd

Set-VMGuestNetworkInterface -vmguestnetworkinterface $nnet -guestuser $acct -guestpassword $pwd `
    -Ip $net.ip -netmask $net.subnetmask -gateway $net.defaultgateway -dnspolicy static -dns $net.dns `
    -winspolicy $net.winspolicy -wins $net.wins