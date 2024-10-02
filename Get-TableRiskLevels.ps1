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

    # Get all table rows (tr elements)
    $rows = $ie.Document.getElementsByTagName("tr")

    $riskLevels = @()

    # Iterate through each row
    foreach ($row in $rows) {
        # Get header (th) and data (td) elements
        $headers = $row.getElementsByTagName("th")
        $cells = $row.getElementsByTagName("td")

        # Check if the row has a "RISK LEVEL" header
        foreach ($header in $headers) {
            if ($header.innerText -eq "RISK LEVEL") {
                # If a matching header is found, look for <td> elements in the same row
                foreach ($cell in $cells) {
                    # Match "None", "LOW_RISK", "MEDIUM_RISK", "HIGH_RISK"
                    if ($cell.innerText -match 'None|LOW_RISK|MEDIUM_RISK|HIGH_RISK') {
                        # Add the matched risk level to the array
                        $riskLevels += $cell.innerText.Trim()
                    }
                }
            }
        }
    }

    # Quit the IE COM object
    $ie.Quit()

    return $riskLevels
}

<# Example usage
$htmlObject = @"
<html>
    <body>
        <table>
            <tr><th>RISK LEVEL</th><td>LOW_RISK</td></tr>
            <tr><th>RISK LEVEL</th><td>MEDIUM_RISK</td></tr>
            <tr><th>RISK LEVEL</th><td>HIGH_RISK</td></tr>
            <tr><th>RISK LEVEL</th><td>None</td></tr>
        </table>
    </body>
</html>
"@

$riskLevels = Get-RiskLevels -HtmlContent $htmlObject
$riskLevels
#>