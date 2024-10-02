function Get-RiskLevels {
    param (
        [Parameter(Mandatory=$true)]
        [string]$HtmlContent  # The HTML content as a string
    )

    # Convert the string HTML content to a memory stream so Invoke-WebRequest can process it
    $htmlBytes = [System.Text.Encoding]::UTF8.GetBytes($HtmlContent)
    $memoryStream = New-Object System.IO.MemoryStream
    $memoryStream.Write($htmlBytes, 0, $htmlBytes.Length)
    $memoryStream.Seek(0, 'Begin')

    # Create a StreamReader and read the memory stream to text
    $reader = New-Object System.IO.StreamReader($memoryStream)
    $htmlString = $reader.ReadToEnd()

    # Use Invoke-WebRequest to parse the HTML
    $htmlParsed = Invoke-WebRequest -ContentType "text/html" -Body $htmlString -UseBasicParsing

    # Find the table rows (tr elements)
    $rows = $htmlParsed.ParsedHtml.getElementsByTagName("tr")

    $riskLevels = @()

    foreach ($row in $rows) {
        # Get all table cells (td elements) in the row
        $cells = $row.getElementsByTagName("td")

        foreach ($cell in $cells) {
            # Check if the cell contains "Low Risk", "Medium Risk", or "High Risk"
            if ($cell.innerText -match 'Low Risk|Medium Risk|High Risk') {
                # Add the matched risk level to the array
                $riskLevels += $cell.innerText.Trim()
            }
        }
    }

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