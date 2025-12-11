# By Matt Karwoski, last updated 7-28-25
# Create pingtargets.txt on desktop
$User = $env:username
$DesktopPath = "C:\users\$user\desktop"
$InputPath = "$DesktopPath\pingtargets.txt"
if (!(Test-Path $InputPath)) {
    New-Item $InputPath | Out-Null
}
# Open pingtargets.txt
notepad.exe $InputPath
do {
    Write-Host "Please confirm your ping targets in the file $InputPath`nCurrent list contents are displayed below:"
    Get-Content $InputPath
    $Answer1 = Read-Host "`nIf the above list is correct, enter 'y' to continue. Otherwise, update the file and enter 'n' to show file contents again."
} until ($Answer1 -eq "y")
# Set input file variable
$Targets = Get-Content $InputPath
# Ping the list, output results table
[array]$PingResults = @()
foreach ($T in $Targets) {
    $Result = (Test-NetConnection $T)
    [string]$RemoteAddress = $Result.RemoteAddress.IPAddressToString
    [string]$PingSucceeded = $Result.PingSucceeded
    [int]$RoundTripTime = $Result.PingReplyDetails.RoundtripTime
    $NewResult = [PSCustomObject]@{
        "Target" = "$T";
        "RemoteAddress"  = "$RemoteAddress";
        "PingSucceeded"  = "$PingSucceeded";
        "RoundTripTimeMS"  = "$RoundTripTime"
    }
    $PingResults += $NewResult
}
# Export table option
$Answer2 = Read-Host "Export results to CSV file on desktop? (Results will be output to console regardless) (y/n)"
if ($Answer2 -eq "y") {
    $PingResults | Export-CSV -Path "$DesktopPath\PingResults.csv"
}
Write-Host "Ping results:"
$PingResults
