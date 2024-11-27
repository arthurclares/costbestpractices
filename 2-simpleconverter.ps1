# Convert JSON to Excel

function Test-Requirement {
    # Install required modules
    Write-Host 'Validating ' -NoNewline
    Write-Host 'ImportExcel' -ForegroundColor Cyan -NoNewline
    Write-Host ' Module..'
    $ImportExcel = Get-Module -Name ImportExcel -ListAvailable -ErrorAction silentlycontinue
    if ($null -eq $ImportExcel) {
      Write-Host 'Installing ImportExcel Module' -ForegroundColor Yellow
      Install-Module -Name ImportExcel -Force -SkipPublisherCheck
    }
}
function Convert-JsonToExcel {
    param (
        [Parameter(Mandatory=$true)]
        [string]$JsonFilePath,

        [Parameter(Mandatory=$true)]
        [string]$ExcelFilePath
    )

    # Import the JSON file
    $jsonData = Get-Content -Path $JsonFilePath | ConvertFrom-Json

    # Load the Excel package module
    Import-Module ImportExcel -ErrorAction Stop

    # Table Style
    $TableStyle = 'Light19'

    # Common column style
    $columnCommonStyle = @{
        FontName = 'Calibri'
        FontSize = 11
        WrapText = $true
    }

    # Header row style
    $headerCommonStyle = @{
        FontName            = 'Calibri'
        FontSize            = 11
        FontColor           = 'White'
        Bold                = $true
        BackgroundColor     = 'DarkSlateGray'
        HorizontalAlignment = 'Center'
        VerticalAlignment   = 'Center'
        WrapText            = $true
    }

    # Define styles
    $Styles2 = @(
        # Column styles
        New-ExcelStyle @columnCommonStyle -Range 'A:Z' -HorizontalAlignment Left -VerticalAlignment Top

        # Header styles
        New-ExcelStyle @headerCommonStyle -Range 'A1:Z1' -Width 30
    )

    # Export the JSON data to an Excel file with styling
    $jsonData | Export-Excel -Path $ExcelFilePath `
                            -WorksheetName 'Recommendations' `
                            -TableName 'Table1' `
                            -AutoSize `
                            -TableStyle $TableStyle `
                            -Style $Styles2 `
                            -MoveToStart

    Write-Host "Data successfully exported to a styled Excel file: $ExcelFilePath" -ForegroundColor Green
}

# Example usage
$JsonFilePath = "$PSScriptRoot\ACORL-File-2024-11-26-20-55.json" # Adjust file name as needed
# Generate the Excel file path with a timestamp
$timestamp = (Get-Date -Format 'yyyy-MM-dd-HH-mm')
$ExcelFilePath = "$PSScriptRoot\ACORL-File-$timestamp.xlsx"

Convert-JsonToExcel -JsonFilePath $JsonFilePath -ExcelFilePath $ExcelFilePath
