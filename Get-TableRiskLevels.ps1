function Get-RiskLevels {
    param (
        [Parameter(Mandatory=$true)]
        [string]$HtmlContent  # The HTML content as a string
    )

    # Create an Internet Explorer COM object
    $ie = New-Object -ComObject "InternetExplorer.Application"
    $ie.Visible = $false

    # Load the HTML content into the IE object
    $ie.Navigate("about:blank")
    while ($ie.Busy) { Start-Sleep -Milliseconds 100 }
    $ie.Document.Write($HtmlContent)

    # Get the table element (assuming there's only one table)
    $table = $ie.Document.getElementsByTagName("table") | Select-Object -First 1

    $riskLevels = @()
    $riskLevelIndex = -1

    # Find the header row and get the index of "Risk Level"
    $headerRow = $table.getElementsByTagName("tr") | Select-Object -First 1
    $headers = $headerRow.getElementsByTagName("th")

    # Debug: Print all header values
    Write-Host "Headers found:"
    foreach ($header in $headers) {
        Write-Host $header.innerText.Trim()
    }

    # Check headers for "Risk Level"
    foreach ($header in $headers) {
        if ($header.innerText.Trim().ToLower() -eq "risk level") {
            $riskLevelIndex = [Array]::IndexOf($headers, $header)
            break
        }
    }

    # If the Risk Level header was found
    if ($riskLevelIndex -ne -1) {
        # Iterate through the data rows (skip the header row)
        $dataRows = $table.getElementsByTagName("tr") | Select-Object -Skip 1  # Skip the header row

        foreach ($row in $dataRows) {
            $cells = $row.getElementsByTagName("td")

            # Ensure there are enough cells in the row
            if ($cells.length -gt $riskLevelIndex) {
                $cellValue = $cells[$riskLevelIndex].innerText.Trim()

                # Debug: Print the cell value found
                Write-Host "Cell value: '$cellValue'"

                # Match "None", "LOW_RISK", "MEDIUM_RISK", "HIGH_RISK"
                if ($cellValue -match 'None|LOW_RISK|MEDIUM_RISK|HIGH_RISK') {
                    # Add the matched risk level to the array
                    $riskLevels += $cellValue
                }
            }
        }
    } else {
        Write-Host "Risk Level header not found."
    }

    # Quit the IE COM object
    $ie.Quit()

    return $riskLevels
}

<#
<table>
<tr>
<th>Friendly Name</th> 
<th>Issuer</th> 
<th>Server</th>
<th>Thumbprint</th>
<th>Subject Name</th> 
<th>Issue Date</th>
<th>Expiration Date</th> 
<th>Risk Level</th>
<th>Expires in (Days)</th>
</tr>
<tr class="even-table-color">
<td>QACA92</td>
<td>CN=Wells Fargo Enterprise certification Authori</td>
<td>MSGQVZLTM901</td>
<td>1EFSECA8CFF5FB0F4469686C129D28224314ADB4</td> 
<td>CN-QACA92, OU-EMC, 0-Wells Fargo, C-US</td> 
<td>08/12/2024 05:33:01</td>
<td>08/12/2026 05:33:01</td>
<td>None</td>
<td>679</td> 
</tr> 
</table>
#>