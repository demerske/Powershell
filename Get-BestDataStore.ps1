Function Get-BestDataStore {
    param ([parameter(Mandatory=$true)]
            $cluster
    )

    Begin {
        Add-PSSnapin vmware.vimautomation.core
        connect-viserver omvcsprd50
        $stores = get-datastore -name *$cluster*
        $disks = @()
    }

    Process {

        ForEach($store in $stores){$view = get-view -viobject $store
            $cap = $view.summary.capacity
            $free = $view.summary.freespace
            $uncom = $view.summary.uncommitted

            $props = @{Name = $view.summary.name ;
                Capacity = $cap /1GB ;
                FreeSpace = $free /1GB ;
                Uncommitted = $uncom /1GB
                Index = ($free - $uncom) / 1GB
            }

            $disk = new-object psobject -property $props

            $disks += $disk
        }

        $disks = $disks | Sort Index -descending
        $opt = $disks[0]
    }
    
    End {
        Write-Host $opt.name
        Disconnect-viserver
    }

}