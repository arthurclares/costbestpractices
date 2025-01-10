Function CostRecommendations {
    param (
        [string]$subscriptionIds,
        [string]$resourceGroupName,
        [switch]$Verbose
    )

    $requiredModules = @(
        'Az.Accounts',
        'Az.ResourceGraph'
    )

    # Define log file path
    $logFile = Join-Path $PSScriptRoot ('ACORL-Log-' + (Get-Date -Format 'yyyy-MM-dd-HH-mm') + '.log')

    # Function to log messages to both console and log file (thread-safe)
    function Write-Log {
        param (
            [string]$Message,
            [string]$Level = "INFO" # Levels: INFO, WARNING, ERROR
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "$timestamp [$Level] $Message"

        # Use a mutex to ensure thread-safe logging
        $mutex = New-Object System.Threading.Mutex($false, "LogFileMutex")
        $mutex.WaitOne() | Out-Null
        try {
            Add-Content -Path $logFile -Value $logMessage -ErrorAction Stop
        }
        catch {
            Write-Host "Failed to write to log file: $_" -ForegroundColor Red
        }
        finally {
            $mutex.ReleaseMutex()
        }

        switch ($Level) {
            "INFO" { Write-Host $logMessage -ForegroundColor Green }
            "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
            "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        }
    }

    # Log script start
    Write-Log -Message "Starting script execution." -Level "INFO"

    # Function to install and import required modules
    function Install-AndImportModules {
        param (
            [string[]]$Modules
        )

        foreach ($module in $Modules) {
            # Check if the module is already installed
            if (-not (Get-Module -ListAvailable -Name $module)) {
                Write-Host "Installing module: $module" -ForegroundColor Yellow
                try {
                    Install-Module -Name $module -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
                    Write-Host "Module installed successfully: $module" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to install module: $module. Error: $_" -ForegroundColor Red
                    return $false
                }
            }

            # Import the module
            try {
                Import-Module -Name $module -ErrorAction Stop
                Write-Host "Module imported successfully: $module" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to import module: $module. Error: $_" -ForegroundColor Red
                return $false
            }
        }

        return $true
    }

    # Install and import required modules
    if (-not (Install-AndImportModules -Modules $requiredModules)) {
        Write-Host "Failed to install or import required modules. Exiting script." -ForegroundColor Red
        exit
    }

    # Check if the user is logged into Azure, and log them in if not
    try {
        $context = Get-AzContext -ErrorAction Stop
        if (-not $context) {
            Write-Log -Message "You are not logged into Azure. Attempting to log you in..." -Level "INFO"
            try {
                Connect-AzAccount -ErrorAction Stop
                Write-Log -Message "Successfully logged into Azure." -Level "INFO"
            }
            catch {
                Write-Log -Message "Failed to log into Azure: $_" -Level "ERROR"
                return
            }
        }
        else {
            Write-Log -Message "Already logged into Azure." -Level "INFO"
        }
    }
    catch {
        Write-Log -Message "An error occurred while checking Azure login status: $_" -Level "ERROR"
        return
    }

    # Define script path as the default path to save files
    $workingFolderPath = $PSScriptRoot
    Set-Location -Path $workingFolderPath
    Write-Log -Message "Set working directory to: $workingFolderPath" -Level "INFO"

    # Prompt user for filtering options
    Write-Host "Do you want to run the script across the entire environment or apply filters?" -ForegroundColor Cyan
    Write-Host "1. Run across the entire environment (no filters)."
    Write-Host "2. Filter by subscription ID(s)."
    Write-Host "3. Filter by resource group name (requires subscription ID)."
    $choice = Read-Host "Enter your choice (1, 2, or 3)"

    switch ($choice) {
        1 {
            Write-Log -Message "Running script across the entire environment (no filters)." -Level "INFO"
            $subscriptionIds = $null
            $resourceGroupName = $null
        }
        2 {
            $subscriptionIds = Read-Host "Enter the subscription ID(s), separated by commas"
            Write-Log -Message "Filtering by subscription ID(s): $subscriptionIds" -Level "INFO"
            $resourceGroupName = $null
        }
        3 {
            $subscriptionIds = Read-Host "Enter the subscription ID where the resource group resides"
            $resourceGroupName = Read-Host "Enter the resource group name"
            Write-Log -Message "Filtering by resource group '$resourceGroupName' in subscription '$subscriptionIds'." -Level "INFO"
        }
        default {
            Write-Log -Message "Invalid choice. Exiting script." -Level "ERROR"
            return
        }
    }

    # Define the base path for the folder structure
    $basePath = 'C:\Cost\Hugo\cost-optimizaiton-resource-library\costbestpractices\costbestpractices\docs\content\azure-resources'

    # Check if the base path exists
    if (-not (Test-Path -Path $basePath)) {
        Write-Log -Message "The base path '$basePath' does not exist. Please provide a valid path." -Level "ERROR"
        return
    }
    else {
        Write-Log -Message "Base path validated: $basePath" -Level "INFO"
    }

    # Get all KQL files dynamically, accounting for the new folder structure
    try {
        $kqlFiles = Get-ChildItem -Path $basePath -Recurse -Filter *.kql -ErrorAction Stop
        Write-Log -Message "Found $($kqlFiles.Count) KQL files in the specified directory." -Level "INFO"
    }
    catch {
        Write-Log -Message "An error occurred while retrieving KQL files: $_" -Level "ERROR"
        return
    }

    if ($kqlFiles.Count -eq 0) {
        Write-Log -Message "No KQL files found in the specified directory: $basePath" -Level "WARNING"
        return
    }

    $allResources = @()
    $queryErrors = @()

    # Process KQL files in parallel
    $kqlFiles | ForEach-Object -Parallel {
        $file = $_
        $subscriptionIds = $using:subscriptionIds
        $resourceGroupName = $using:resourceGroupName
        $logFile = $using:logFile

        function Write-Log {
            param (
                [string]$Message,
                [string]$Level = "INFO"
            )
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logMessage = "$timestamp [$Level] $Message"

            # Use a mutex to ensure thread-safe logging
            $mutex = New-Object System.Threading.Mutex($false, "LogFileMutex")
            $mutex.WaitOne() | Out-Null
            try {
                Add-Content -Path $logFile -Value $logMessage -ErrorAction Stop
            }
            catch {
                Write-Host "Failed to write to log file: $_" -ForegroundColor Red
            }
            finally {
                $mutex.ReleaseMutex()
            }
        }

        try {
            $query = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            $recommendationDescription = $file.x_RecommendationId
            Write-Log -Message "Processing query: $recommendationDescription" -Level "INFO"

            # Display the recommendation description from the file metadata
            $recommendationDescription = $file.x_RecommendationDescription
            if ($recommendationDescription) {
                Write-Log -Message "Processing query: $recommendationDescription" -Level "INFO"
            }
            else {
                Write-Log -Message "Processing query with no description found: $($file.FullName)" -Level "WARNING"
            }

            # Modify the query to include subscription or resource group filters if specified
            if ($subscriptionIds -and $resourceGroupName) {
                # Filter by both subscription ID and resource group name
                $query = "$query | where SubAccountId == '$subscriptionIds' and resourceGroup == '$resourceGroupName'"
            }
            elseif ($subscriptionIds) {
                # Filter by subscription ID(s)
                $subscriptionList = $subscriptionIds -split ',' | ForEach-Object { $_.Trim() }
                $subscriptionFilter = $subscriptionList -join "', '"
                $query = "$query | where SubAccountId in ('$subscriptionFilter')"
            }

            # Execute the query using Azure Resource Graph
            try {
                $result = Search-AzGraph -Query $query -First 1000 -ErrorAction Stop
                $fileResources = @($result)

                # Handle pagination
                while ($result.SkipToken) {
                    $result = Search-AzGraph -Query $query -SkipToken $result.SkipToken -First 1000 -ErrorAction Stop
                    $fileResources += $result
                }

                return $fileResources
            }
            catch {
                # Log the query error with details
                $errorMessage = "Query failed for file '$($file.FullName)': $($_.Exception.Message)"
                Write-Log -Message $errorMessage -Level "ERROR"
                Write-Log -Message "Query: $query" -Level "ERROR"
                return @{
                    Error = $errorMessage
                }
            }
        }
        catch {
            $errorMessage = "An error occurred while processing file '$($file.FullName)': $_"
            Write-Log -Message $errorMessage -Level "ERROR"
            return @{
                Error = $errorMessage
            }
        }
    } -ThrottleLimit 5 | ForEach-Object {
        if ($_.Error) {
            $queryErrors += $_.Error
        }
        else {
            $allResources += $_
        }
    }

    # Display query errors on the main screen
    if ($queryErrors.Count -gt 0) {
        Write-Host "`nThe following query errors occurred:" -ForegroundColor Red
        foreach ($error in $queryErrors) {
            Write-Host "- $error" -ForegroundColor Red
        }
    }

    # Export results to a JSON file
    if ($allResources.Count -gt 0) {
        try {
            New-JsonFile -allResources $allResources
            Write-Log -Message "Exported results to JSON file." -Level "INFO"
        }
        catch {
            Write-Log -Message "An error occurred while exporting results to JSON: $_" -Level "ERROR"
        }

        # Display selected fields on the main screen
        # Summarize recommendations by recommendationProvider, recommendationImpact, and resourceType
        Write-Host "`nRecommendations Summary:" -ForegroundColor Cyan
        $summary = $allResources | Group-Object -Property @{
            Expression = {
                "$($_.x_RecommendationProvider) | $($_.x_RecommendationImpact) | $($_.x_ResourceType)"
            }
        } | ForEach-Object {
            [PSCustomObject]@{
                RecommendationProvider = ($_.Name -split ' \| ')[0]
                RecommendationImpact   = ($_.Name -split ' \| ')[1]
                ResourceType           = ($_.Name -split ' \| ')[2]
                Count                  = $_.Count
            }
        }

        # Display the summary
        $summary | Format-Table -AutoSize
    }
    else {
        Write-Log -Message "No resources found to export." -Level "WARNING"
    }

    Write-Log -Message "Script execution completed." -Level "INFO"
}

# Function to export results to a JSON file
function New-JsonFile {
    param (
        [Parameter(Mandatory = $true)]
        [array]$allResources
    )

    try {
        # Define the file name with timestamp
        $outputFile = Join-Path $PSScriptRoot ('ACORL-File-' + (Get-Date -Format 'yyyy-MM-dd-HH-mm') + '.json')

        # Export the results to the JSON file
        $allResources | ConvertTo-Json -Depth 10 | Set-Content -Path $outputFile -ErrorAction Stop

        Write-Log -Message "Results exported to $outputFile" -Level "INFO"
    }
    catch {
        Write-Log -Message "An error occurred while creating the JSON file: $_" -Level "ERROR"
    }
}

# Execute the main function
CostRecommendations
