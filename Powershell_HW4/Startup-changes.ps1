# last modified @ 10/20 1:18AM

$HKCU_1 = Get-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$HKLM_1 = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

$finalText1 = ""

$HKCU1_array = $HKCU_1 -split '; '
$HKLM1_array = $HKLM_1 -split '; '

foreach ($HKCU in $HKCU1_array){
    $temp_location = $HKCU -split '='

    $finalText1 += $temp_location[0]
    $finalText1 += ";"
}

foreach ($HKLM in $HKLM1_array){
    $temp_location = $HKLM -split '='

    $finalText1 += $temp_location[0]
    $finalText1 += ";"
}

$finalText1 = $finalText1 -replace '[{]',''
$finalText1 = $finalText1 -replace '[@]', ''
"$finalText1" | Out-File log_file1.txt

# Create Timer Instance
$timer = New-Object System.Timers.Timer

# Setup the Timer instance to fire events
# every 5 minutes = 300000 millseconds
$timer.Interval = 300000
$timeout = 0
$global:counter = 1
$global:finalText2 = ""

$action = {
    $HKCU_2 = Get-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $HKLM_2 = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

    #$finalText2 = ""

    $HKCU2_array = $HKCU_2 -split '; '
    $HKLM2_array = $HKLM_2 -split '; '

    foreach ($HKCU in $HKCU2_array){
        $temp_location = $HKCU -split '='
   
        $global:finalText2 += $temp_location[0]
        $global:finalText2 += ";"
    }

    foreach ($HKLM in $HKLM2_array){
        $temp_location = $HKLM -split '='

        $global:finalText2 += $temp_location[0]
        $global:finalText2 += ";"
    }

    $global:finalText2 = $global:finalText2 -replace '[{]',''
    $global:finalText2 = $global:finalText2 -replace '[@]', ''
    "$global:finalText2" | Out-File log_file2.txt

    #write-host $global:finalText2

    write-host "SCAN: " $global:counter
    $global:counter++
    }

$start = Register-ObjectEvent -InputObject $timer -EventName Elapsed `
-SourceIdentifier TimerElapsed -Action $action

$timer.Start()
$execute_flag = $true

$count = 0
$startTime = (Get-Date).Second
while ($execute_flag -eq $true)
{
    Start-Sleep -second 1
    $count++
    Write-Host "[+]" $count "second(s)"
    if($count%300 -eq 0)
    {
        if ($finalText1 -eq $global:finalText2)
        {
            $curTime = (Get-Date).Second
            $elapsed = ($endTime - $startTime)
            Add-Content compare_logFile.txt "$elapsed seconds: A change has not occured and a program has NOT been added to start up!"
        }
        else
        {
            $curTime = (Get-Date).Second
            $elapsed = ($endTime - $startTime)
            Add-Content compare_logFile.txt "$elapsed seconds: A change has occured and at least one program HAS been added to start up!"

            $init_arr = "$finalText1" -split ";"

            $fin_arr = "$finalText2" -split ";"

            foreach($element in $fin_arr)
            {
                if (!$init_arr.Contains("$element"))
                {
                    $curTime = (Get-Date).Second
                    $elapsed = ($endTime - $startTime)
                    Add-Content compare_logFile.txt "$elapsed seconds: $element has been added!"
                }
            }
        }
    }
} 

$timer.Stop()
Unregister-Event TimerElapsed 

