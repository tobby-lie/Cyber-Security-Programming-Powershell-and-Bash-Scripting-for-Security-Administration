$shell_folders1 = Get-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"

$finalText1 = ""

$shell_folders1_array = $Shell_folders1 -split '; '
foreach ($shell_folder in $shell_folders1_array){
    $temp_location = $shell_folder -split '='
    if ($temp_location[0] -eq "Startup")
    {
        $contents = Get-ChildItem -Path $temp_location[1]
        $finalText1 += $contents
    }
}

"$finalText1" | Out-File shell_logs1.txt

# Create Timer Instance
$timer = New-Object System.Timers.Timer

# Setup the Timer instance to fire events
# every 5 minutes = 300000 seconds
$timer.Interval = 300000
$timeout = 0
$global:counter = 1

$action = {
    $shell_folders2 = Get-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"

    $finalText2 = ""

    $shell_folders2_array = $Shell_folders2 -split '; '
    foreach ($shell_folder in $shell_folders2_array){
        $temp_location = $shell_folder -split '='
        if ($temp_location[0] -eq "Startup")
        {
            $contents = Get-ChildItem -Path $temp_location[1]
            $finalText2 += $contents
        }
    }

    "$finalText2" | Out-File shell_logs2.txt

    write-host "SCAN: " $counter
    $global:counter++
    }

$start = Register-ObjectEvent -InputObject $timer -EventName Elapsed `
-SourceIdentifier TimerElapsed -Action $action

$timer.Start()
$execute_flag = $true

$count = 0
while ($execute_flag -eq $true)
{
    Start-Sleep -second 1
    $count++
    Write-Host "[+]" $count "second(s)"
    if($count%300 -eq 0)
    {
        $areEqual = {@(Compare-Object $finalText1 $finalText2 -sync 0).Length -eq 0}
        write-host "$finalText1"
        Write-Host "$finalText2"
        if (Compare-Object "$finalText1" "$finalText2")
        {
            Add-Content log_file.txt "A change has not occured and a program has NOT been added to start up!"
        }
        else
        {
            Add-Content log_file.txt "A change has occured and a program HAS been added to start up!"
        }
    }
}

$timer.Stop()
Unregister-Event TimerElapsed