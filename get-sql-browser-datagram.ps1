param (
    [Parameter(Mandatory = $false)]
    [string]$MachineName = $env:computername
)

function Get-SqlBrowserDatagram {
    param (
        [Parameter(Mandatory = $true)]
        [string]$MachineName
    )

    $UdpClient = New-Object System.Net.Sockets.UdpClient
    $UdpClient.Client.ReceiveTimeout = 30000

    $UdpClient.Connect($MachineName, 1434)

    $Encoding = New-Object System.Text.ASCIIEncoding
    $ByteArray = 0x02

    $UdpClient.Send($ByteArray, $ByteArray.Length) |
        Out-Null

    $RemoteEndpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)

    try {
        $BytesToTrimFromFront = 3

        $BytesReceived = $UdpClient.Receive([ref] $RemoteEndpoint)
        $BytesReceivedTrimmed = New-Object byte[] ($BytesReceived.Count - $BytesToTrimFromFront)
        [System.Array]::Copy($BytesReceived, $BytesToTrimFromFront,  $BytesReceivedTrimmed, 0, $BytesReceived.Count - $BytesToTrimFromFront)
        $StringReceived = $Encoding.GetString($BytesReceivedTrimmed)

        $StringReceived.Replace(";", "`r`n")
    }
    catch {
        Write-Error $_.Exception
    }
    finally {
        $UdpClient.Dispose()
    }
}

Get-SqlBrowserDatagram -MachineName $MachineName