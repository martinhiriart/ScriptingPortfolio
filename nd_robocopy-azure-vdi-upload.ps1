function transfers{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Transfer","Differential")]$RoboCopyType,
        [Parameter(Mandatory)]
        [string]$CustomerName,
        [Parameter(Mandatory)]
        [string]$SourceAddr,
        [Parameter(Mandatory)]
        [string]$DestAddr,
        [Parameter(Mandatory)]
        [int]$ThreadCount
    )
    if($RoboCopyType -eq "Transfer"){
        $dynFlags = @("/e", "/z", "/r:1", "/w:0")
    }
    else {
        $days = Read-Host "Enter the Number of Days For Differential Copy"
        $maxLad = "/maxlad:" + $days
        $maxAge = "/maxage:" + $days
        $dynFlags = @("/e", "/z", "$maxLad", "$maxAge", "/r:1", "/w:0")
    }

    ################################################
    #   RoboCopy Arguments and Log File Creation   #
    ################################################
        $logName = $CustomerName + " " + "$(Get-Date -f MM-dd-yyyy)" + ".log"
        $threads = "/mt:" + $ThreadCount
        $logFile = "C:\RoboCopyLogs\NeedlesAzureUploads\" + $logName
        $log = "/log:" + $logFile
        $fixedFlags = @("$threads", "$log")
        $cmdArgs = @("$SourceAddr", "$DestAddr", $dynFlags, $fixedFlags)

    #############################
    #   SMTP Relay Information  #
    #############################
    $From = 'robocopy@trialworks.com'
    while(($null -eq $To) -or ($To -eq ''))
    {
        $To = Read-Host "Who do I notify when the transfer is complete? (Enter Email Address)"
    }
    $Subject = $customerName + ' RoboCopy Job Completed on ' + $(Get-Date)
    $Body = 'Attached below is the log for the RoboCopy transfer of ' + $customerName + "'s data"
    $Attachment = $logFile
    $SMTPServer = 'smtp-relay.gmail.com'
    $SMTPPort = '587'

    robocopy @cmdArgs
    Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -Attachments $Attachment
}
transfers