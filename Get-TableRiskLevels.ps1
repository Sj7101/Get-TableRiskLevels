function Get-RiskLevels {
    param (
        [Parameter(Mandatory=$true)]
        [pscustomobject]$HtmlObject  # Your PSCustomObject with the HTML table content
    )

    # Use Invoke-WebRequest to parse the HTML content
    $htmlParsed = [System.Net.WebUtility]::HtmlDecode($HtmlObject)

    # Load the HTML into an XML document for easier parsing
    $htmlDoc = New-Object -ComObject "HTMLFile"
    $htmlDoc.IHTMLDocument2_write($htmlParsed)

    # Select all rows from the table
    $rows = $htmlDoc.getElementsByTagName("tr")

    $riskLevels = @()

    foreach ($row in $rows) {
        # Get all cells (td elements) in the current row
        $cells = $row.getElementsByTagName("td")

        foreach ($cell in $cells) {
            # Check if the cell contains "Low Risk", "Medium Risk", or "High Risk"
            if ($cell.innerText -match 'Low Risk|Medium Risk|High Risk') {
                # Add this row to the riskLevels array
                $riskLevels += $cell.innerText
            }
        }
    }

    return $riskLevels
}

<#

Input: The function takes a PSCustomObject with HTML content.
HTML Parsing: It parses the HTML and looks for table rows (tr) and cells (td).
Risk Level Filter: It checks for cells with "Low Risk", "Medium Risk", or "High Risk" and adds them to an array.
Output: Returns an array of the risk levels found.

#>