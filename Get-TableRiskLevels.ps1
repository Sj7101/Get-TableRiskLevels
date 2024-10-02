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
        # Get all the header (th) and data (td) elements in the row
        $headers = $row.getElementsByTagName("th")
        $cells = $row.getElementsByTagName("td")

        # Check if the row has a "RISK LEVEL" header
        foreach ($header in $headers) {
            if ($header.innerText -eq "RISK LEVEL") {
                # If a matching header is found, get the corresponding data in <td>
                foreach ($cell in $cells) {
                    if ($cell.innerText -match 'Low Risk|Medium Risk|High Risk') {
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
    <table>
        <tr><th>RISK LEVEL</th><td>Low Risk</td></tr>
        <tr><th>RISK LEVEL</th><td>Medium Risk</td></tr>
        <tr><th>RISK LEVEL</th><td>High Risk</td></tr>
        <tr><th>RISK LEVEL</th><td>None</td></tr>
    </table>
</html>
"@

$riskLevels = Get-RiskLevels -HtmlContent $htmlObject
$riskLevels
#>