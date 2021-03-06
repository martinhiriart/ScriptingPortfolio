
    $serversOuPath ='<DISTINGUISHED NAME OF OU WITH PHYSICAL SERVERS>'
    $servers = @()
    $servers += Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name

    $superMicros = @()
    $dells = @()
    $failures = @()
    $superMicroInfo =@()
    $dellInfo = @()
    $allServers =@()
    foreach($server in $servers)
    {
        $manufacturer = Get-WmiObject -ComputerName $server Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
        if($manufacturer -eq 'Supermicro')
        {
            $superMicros += $server
        }
        elseif($manufacturer -eq 'Dell Inc.')
        {
            $dells += $server
        }
        else{
            $failures += $server
        }

    }

    foreach ($supermicro in $superMicros)
    {
        $superMicroInfo += Get-WmiObject -ComputerName $supermicro Win32_ComputerSystem | Select-Object Name, Manufacturer, Model 
    }
    foreach ($dell in $dells)
    {
        $dellInfo += Get-WmiObject -ComputerName $dell Win32_ComputerSystem | Select-Object Name, Manufacturer, Model
    }
    $allServers = $dellInfo + $superMicroInfo | Sort-Object -Property Name -Descending
    $allServers | Export-Csv -Path "<FILE PATH FOR LIST OF ALL SERVERS>\PhysicalServers.csv" 
    $failures | Out-File -FilePath "<FILE PATH FOR LIST OF RPC FAILURES>\RPCFailures.txt"
    $CountOfDells = ($dells).count
    $CountofSuperMicros = ($superMicros).count
    Write-Host "==============================" -ForegroundColor Magenta
    Write-Host "Physical Server Audit Complete" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Magenta
    Write-Host "Number of Dell Servers:" -ForegroundColor Yellow
    Write-Host $CountOfDells
    Write-Host "Number of SuperMicro Servers:" -ForegroundColor Yellow
    Write-Host $CountofSuperMicros
    Write-Host "Would you like to view the CSV with all the servers?" -NoNewline -ForegroundColor Yellow
