#  This is a script that grabs all the basic info from devices on the local network
#  It also does a MAC Address lookup to identify the NIC manufacturer.  This may not 
#  identify the machine in all cases, but still it is helpful.


#  Get-NICManufacturer
#  =====================
#  This performs the lookup for the NIC Manufacturer, in the form of a webrequest to macvendors.com
#  In order to keep from getting blocked, we have to delay the requests /  response

function Get-NICManufacturer 
{
    param (
        $MACaddress
    )
    $url = "https://api.macvendors.com/"+$MACAddress
    $webresponse = Invoke-WebRequest -Uri $url -UseBasicParsing
    sleep(.8)
    Write $webresponse.content
}

#  Get the local IP Address, take the first three bytes (xx.xx.xx.) and perform a programmed ping to 1 to 254

$(Get-NetIPAddress | where-object {$_.PrefixLength -eq "24"}).IPAddress `
| Where-Object {$_ -like "*.*"} `
| % {     $LocalIPPrefix="$($([IPAddress]$_).GetAddressBytes()[0]).$($([IPAddress]$_).GetAddressBytes()[1]).$($([IPAddress]$_).GetAddressBytes()[2])"
    write-host "`n`nping hosts on the local subnet $LocalIPPrefix.1-254 ...`n"
    1..254 | % { 
        (New-Object System.Net.NetworkInformation.Ping).SendPingAsync("$LocalIPPrefix.$_","1000") | Out-Null
    }
}

# Wait for the pings to finish and build a cache

while ($(Get-NetNeighbor).state -eq "incomplete") {write-host "waiting";timeout 1 | out-null}

#  Add the hostname, the IP Address, MAC Address, interface state and do the manufacturer lookup
#  Output it to a Grid View

#  $choice = Read-Host -Prompt "Select your output format: 1. GridView 2. CSV File (c:\temp\machines.csv)"

Get-NetNeighbor | Where-Object -Property state -ne Unreachable `
| where-object -property state -ne Permanent `
| select IPaddress,LinkLayerAddress,State,@{n="NIC Manufacturer"; `
 e={Get-NICManufacturer($_.LinkLayerAddress)}}, `
 @{n="Hostname"; e={(Resolve-DnsName $_.IPaddress).NameHost}} `
| Export-Csv "c:\temp\machines.csv"

#  Give the user a choice between a CSV file and seeing a Grid View

$userchoice = Read-Host -Prompt "Select your output format: 1. See it in a GridView 2. Output to CSV File (c:\temp\machines.csv)"

Write-Host "Stand by while the information is generated and the process is completed."

if ($userchoice -eq 1 ) 
{
    Import-Csv -Path "c:\temp\machines.csv" | Out-GridView -Title "Local Area Network Devices"
} 
else 
{
    Write-Host "`nDone.  File saved to c:\temp\machines.csv"
}

Write-Host "Process complete"
