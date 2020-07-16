$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$filePath = "C:\Automation\DedicatedRDPVMResourceReport-" + "$(Get-Date -f MM-dd-yyyy)" + ".txt"
Clear-Content -LiteralPath $filePath
foreach($pc in $RDPServers)
{
    $disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -computername $pc
    $results = foreach ($disk in $disks)
            {
                if ($disk.Size -gt 0)
                {
                    $size = [math]::round($disk.Size/1GB,2)
                    $free = [math]::round($disk.FreeSpace/1GB,2)
                    $total = ($free/$size)
                    $baseline = 0.05
                    if($total -lt $baseline)
                    {
                    "`n`tDrive",$disk.Name, "{0:N2} GB" -f $free 

                    }
                    else
                    {
                        "`n`tDrive",$disk.Name, "{0:N2} GB" -f $free
                    }

                }
            }
    $memory = Invoke-Command -HideComputerName $pc { Get-WmiObject Win32_OperatingSystem -Property FreePhysicalMemory | Select-Object -ExpandProperty FreePhysicalMemory}
    $freeMemory = "`t{0} GB" -f ([math]::round(($memory / 1024 /1024), 2))

    '==================='| Out-File -Append -LiteralPath  $filePath
    $pc| Out-File -Append -LiteralPath  $filePath
    '==================='| Out-File -Append -LiteralPath  $filePath
    'Free Disk Space:' | Out-File -Append -LiteralPath $filePath
    $results | Out-File -Append -LiteralPath $filePath
    'Available Memory:' | Out-File -Append -LiteralPath $filePath
    $freeMemory | Out-File -Append -LiteralPath $filePath

}