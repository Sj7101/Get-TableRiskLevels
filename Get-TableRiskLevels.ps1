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

    foreach ($header in $headers) {
        if ($header.innerText -eq "Risk Level") {
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
