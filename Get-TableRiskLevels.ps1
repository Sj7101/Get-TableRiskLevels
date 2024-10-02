function Get-RiskLevels {
    param (
        [Parameter(Mandatory=$true)]
        [pscustomobject]$HtmlObject  # Your PSCustomObject with the HTML table
    )

    # Convert the HTML content (directly from the PSCustomObject) to a DOM object
    $htmlContent = $HtmlObject  # The HTML is directly in the object

    # Load the HTML content using the HTML DOM parser
    $htmlParsed = New-Object -ComObject "HTMLFILE"
    $htmlParsed.IHTMLDocument2_write($htmlContent)

    # Select all rows from the table (assuming there's a single table)
    $rows = $htmlParsed.getElementsByTagName("tr")

    $riskLevels = @()

    foreach ($row in $rows) {
        # Get all cells (td elements) in the current row
        $cells = $row.getElementsByTagName("td")

        foreach ($cell in $cells) {
            # Check if the cell contains "Low Risk", "Medium Risk", or "High Risk"
            if ($cell.innerText -match 'Low Risk|Medium Risk|High Risk') {
                # Add the matched risk level to the array
                $riskLevels += $cell.innerText
            }
        }
    }

    return $riskLevels
}

# Example usage
$htmlObject = "<html><table><tr><th>RISK LEVEL</th><td>Low Risk</td></tr><tr><td>High Risk</td></tr></table></html>"

$riskLevels = Get-RiskLevels -HtmlObject $htmlObject
$riskLevels

<#

Input: The function takes a PSCustomObject with HTML content.
HTML Parsing: It parses the HTML and looks for table rows (tr) and cells (td).
Risk Level Filter: It checks for cells with "Low Risk", "Medium Risk", or "High Risk" and adds them to an array.
Output: Returns an array of the risk levels found.

#>