# last modified @ 10/23 5:00PM

# start time 
$startTime = $(Get-Date)
# keep looping
while ($true)
{
    # Get items in registry locations
    $HKCU_1 = Get-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $HKLM_1 = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

    # initialize to empty string
    $finalText1 = ""

    # split strings by semicolon and put into arrays
    $HKCU1_array = $HKCU_1 -split '; '
    $HKLM1_array = $HKLM_1 -split '; '

    # for every element in each array add to a final string to save results
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

    # replace unique characters with empty 
    $finalText1 = $finalText1 -replace '[{]',''
    $finalText1 = $finalText1 -replace '[@]', ''
    "$finalText1" | Out-File log_file1.txt

    # get elapsed time in seconds
    $curTime = $(Get-Date)
    $elapsed = ($curTime - $startTime)
    Write-Host "[+]" $elapsed.TotalSeconds "second(s)"

    # sleep for 5 minutes before scanning again
    Start-Sleep -second 300

    # scan registry locations again
    $HKCU_2 = Get-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    $HKLM_2 = Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

    $HKCU2_array = $HKCU_2 -split '; '
    $HKLM2_array = $HKLM_2 -split '; '

    foreach ($HKCU in $HKCU2_array){
        $temp_location = $HKCU -split '='
   
        $finalText2 += $temp_location[0]
        $finalText2 += ";"
    }

    foreach ($HKLM in $HKLM2_array){
        $temp_location = $HKLM -split '='

        $finalText2 += $temp_location[0]
        $finalText2 += ";"
    }

    $finalText2 = $finalText2 -replace '[{]',''
    $finalText2 = $finalText2 -replace '[@]', ''
    "$finalText2" | Out-File log_file2.txt

    # if the texts are the same then no change has occured in the files
    if ($finalText1 -eq $finalText2)
    {
        $curTime = $(Get-Date)
        $elapsed = ($curTime - $startTime)
        $totalElapsed = $elapsed.TotalSeconds
        Add-Content compare_logFile.txt "$totalElapsed seconds: A change has not occured and a program has NOT been added to start up!"
    }
    # else one or more programs have been added and those programs will be displayed
    else
    {
        $curTime = $(Get-Date)
        $elapsed = ($curTime - $startTime)
        $totalElapsed = $elapsed.TotalSeconds
        Add-Content compare_logFile.txt "$totalElapsed seconds: A change has occured and at least one program HAS been added to start up!"

        $init_arr = "$finalText1" -split ";"

        $fin_arr = "$finalText2" -split ";"

        # for every element in the newer array 
        # compare against initial array and note any new programs in logfile
        foreach($element in $fin_arr)
        {
            if (!$init_arr.Contains("$element"))
            {
                $curTime = $(Get-Date)
                $elapsed = ($curTime - $startTime)
                $totalElapsed = $elapsed.TotalSeconds
                Add-Content compare_logFile.txt "$totalElapsed seconds: $element has been added!"
            }
        }
    }
} 


