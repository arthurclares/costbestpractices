# Azure Cost Optimization Recommendations Script

This PowerShell script automates the process of generating cost optimization recommendations for Azure resources using Azure Resource Graph queries and manual validations. It is designed to help users identify potential cost savings and improve the efficiency of their Azure environment.

---

## **Features**
- **Automated KQL Queries**: Executes pre-defined KQL (Kusto Query Language) queries to identify cost optimization opportunities.
- **Manual Validations**: Processes YAML files to include manual checks for specific resource types.
- **Well-Architected Framework Integration**: Optionally includes results from a Well-Architected Cost Optimization assessment.
- **Excel Export**: Exports the results to an Excel file with separate sheets for recommendations, manual checks, and assessment data.
- **Customizable Scope**: Allows users to specify the scope (entire environment, specific subscriptions, or resource groups).

---

## **How It Works**
1. **Initialization**:
   - The script checks the PowerShell version and installs required modules (`Az.Accounts`, `Az.ResourceGraph`, `ImportExcel`, `powershell-yaml`).
   - It authenticates to Azure using `Connect-AzAccount`.

2. **Scope Selection**:
   - The user is prompted to select a scope (entire environment, specific subscriptions, or resource groups).

3. **KQL Query Execution**:
   - The script processes KQL files in parallel to query Azure Resource Graph and retrieve cost optimization recommendations.

4. **Manual Validations**:
   - The script processes YAML files to include manual checks for specific resource types.

5. **Well-Architected Assessment**:
   - The user can optionally include results from a Well-Architected Cost Optimization assessment by providing a CSV file.

6. **Excel Export**:
   - The script exports the results to an Excel file with the following sheets:
     - **Recommendations**: Results from KQL queries.
     - **Manual Recommendations**: Results from manual validations.
     - **Well-Architected Assessment**: Results from the Well-Architected Cost Optimization assessment (if provided).

---

## **Prerequisites**
- **PowerShell 7+**: The script requires PowerShell 7 or later.
- **Azure Modules**: The following PowerShell modules must be installed:
  - `Az.Accounts`
  - `Az.ResourceGraph`
  - `ImportExcel`
  - `powershell-yaml`
- **Azure Permissions**: The user must have sufficient permissions to query Azure Resource Graph and access the specified resources.

---

## **Usage**
1. **Download the latest version of the script**
```POWERSHELL
invoke-webrequest https://aka.ms/acorl/tools/costcollector -out collectCostRecommendations.ps1
```

2. **Run the Script:**
```POWERSHELL
.\costrecommendations.ps1
```

3. **Follow the Prompts:**
- Select the scope (entire environment, specific subscriptions, or resource groups).
- Choose whether to include a Well-Architected Cost Optimization assessment.
- Choose whether to run manual checks.

4. **Review the Results:**
- The script generates an Excel file (ACORL-File-<timestamp>.xlsx) in the script's directory.
- Open the Excel file to view the recommendations and manual checks.