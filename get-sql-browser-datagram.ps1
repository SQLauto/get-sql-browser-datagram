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
        $BytesReceived = $UdpClient.Receive([ref] $RemoteEndpoint)
        $StringReceived = $Encoding.GetString($BytesReceived)

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