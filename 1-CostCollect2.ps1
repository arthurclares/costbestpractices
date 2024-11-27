Function CostRecommendations {

    param (
        [string[]]$subscriptionId
    )   

    # Define script path as the default path to save files
    $workingFolderPath = $PSScriptRoot
    Set-Location -Path $workingFolderPath;
    
    # Validate subscription and determine scope
    $useSubscriptionScope = $null -ne $subscriptionId

    # Define the base path for the folder structure
    $basePath = 'C:\Cost\cost library\costbp\azure-resources\'

    # Get all kql files dynamically, accounting for the new folder structure
    $kqlFiles = Get-ChildItem -Path $basePath -Recurse -Filter *.kql

    $allResources = @()

    foreach ($file in $kqlFiles) {
        $query = Get-Content -Path $file.FullName -Raw
        $recommendationDescription = $file.x_RecommendationId
        Write-Host "Processing query: $recommendationDescription"
        
        # Display the recommendation description from the file metadata
        $recommendationDescription = $file.x_RecommendationDescription
        if ($recommendationDescription) {
            Write-Host "Processing query: $recommendationDescription" -ForegroundColor Green
        } else {
            Write-Host "Processing query with no description found: $($file.FullName)" -ForegroundColor Yellow
        }

        $result = $useSubscriptionScope ?
            (Search-AzGraph -Query $query -First 1000 -Subscription $subscriptionId) 
            :
            (Search-AzGraph -Query $query -First 1000 -UseTenantScope)

        $fileResources = @($result)

        while ($result.SkipToken) {
            $result = $useSubscriptionScope ? 
                (Search-AzGraph -Query $query -SkipToken $result.SkipToken -Subscription $subscriptionId -First 1000) : 
                (Search-AzGraph -Query $query -SkipToken $result.SkipToken -First 1000 -UseTenantScope)
            $fileResources += $result
        }

        $allResources += $fileResources
    }

    # Export results to a JSON file
    New-JsonFile $allResources

    return $allResources
}

# Function to export results to a JSON file
function New-JsonFile {
    param (
        [Parameter(Mandatory=$true)]
        [array]$allResources
    )
    
    # Define the file name with timestamp
    #$outputFile = 'C:\Path\To\Your\ExportFolder\ACORL-File-' + (Get-Date -Format 'yyyy-MM-dd-HH-mm') + '.json'

    #$Script:JsonFile = ($PSScriptRoot + '\ACORL-File-' + (Get-Date -Format 'yyyy-MM-dd-HH-mm') + '.json')
    $outputFile = Join-Path $PSScriptRoot ('ACORL-File-' + (Get-Date -Format 'yyyy-MM-dd-HH-mm') + '.json')

    # Export the results to the JSON file
    $allResources | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFile

    Write-Host "Results exported to $outputFile" -ForegroundColor Green
}

CostRecommendations