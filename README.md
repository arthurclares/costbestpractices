---
title: Azure Cost Optimizarion Recommendation Library (ACORL)
geekdocNav: true
# geekdocAlign: center
geekdocAnchor: true
---


# Contributing
Thank you for your interest in contributing to ACORL! Below is a detailed guide to help you understand the folder structure and the steps required to add new recommendations.

---

## Directory Structure

The project's directory is organized as follows:

### Folder Structure

{{< highlight markdown >}}
docs/
├── content/
│   ├── azure-resources/
│   │   ├── compute/
│   │   │   ├── managedClusters/
│   │   │   │   ├── kql/
│   │   │   │   │   ├── [unique-query-id].kql
│   │   │   │   ├── _index.md
│   │   │   ├── disks/
│   │   │   │   ├── kql/
│   │   │   │   │   ├── [unique-query-id].kql
│   │   │   │   ├── _index.md
│   │   │   ├── virtualMachines/
│   │   │   │   ├── kql/
│   │   │   │   │   ├── [unique-query-id].kql
│   │   │   │   ├── _index.md
├── data/
│   ├── recommendations/
│   │   ├── azure-resources/
│   │   │   ├── compute/
│   │   │   │   ├── managedClusters/
│   │   │   │   │   ├── recommendations.yaml
│   │   │   │   ├── disks/
│   │   │   │   │   ├── recommendations.yaml
│   │   │   │   ├── virtualMachines/
│   │   │   │   │   ├── recommendations.yaml
{{< /highlight >}}

### Directory Structure

1. **ResourceType Folder**: Each recommendation will have its own folder named after the `recommendationResourceType`. For example, `Microsoft.sql/servers/elasticpools/`.

2. **Required Files**:
   - **KQL File**: Contains the KQL query for the recommendation. It should be named with a GUID for unique identification (e.g., `3ecbf770-9404-4504-a450-cc198e8b2a7d.kql`).
   - **recommendation.yaml**: This file contains metadata and description for the recommendation (e.g., `recommendation.yaml`).
   - **_index.md**: A markdown file providing additional documentation for the recommendation, such as detailed information, impact, and remediation actions.

Each new recommendation must include these three files to ensure proper functionality and documentation.


---

## Adding a New Recommendation

### 1. **Add the KQL File**
KQL File: The KQL query that supports the recommendation.

- **Location:** `docs/content/azure-resources/<ResourceType>/<Resource>/kql/`
- **Purpose:** This file contains the KQL query associated with your recommendation.
- **File Naming:** Use a UUID for the file name (e.g., `ab703887-fa23-4915-abdc-3defbea89f7a.kql`). You can use [Guid Generator](https://guidgenerator.com/) to create a unique UUID.

### 2. **Add the Recommendation YAML**
Recommendations YAML File: Contains metadata for the recommendation.

- **Location:** `docs/data/recommendations/azure-resources/<ResourceType>/<Resource>/`
- **Purpose:** This YAML file provides metadata for the recommendation, including its description, impact, and control.
- **File Naming:** Name the file `recommendations.yaml`.
- **Structure Example:**
{{< highlight yaml >}}
- description: SQL Database elastic pool has no associated databases
  acorlGuid: '50987aae-a46d-49ae-bd41-a670a4dd18bd'
  recommendationTypeId: null
  recommendationControl: UsageOptimization/OrphanedResources
  recommendationImpact: High
  recommendationResourceType: Microsoft.sql/servers/elasticpools
  recommendationMetadataState: Active
  remediationAction: |
    Review and remove this resource if not needed
  potentialBenefits: Remove idle resources
  pgVerified: true
  publishedToLearn: false
  automationAvailable: true
  tags: null
  learnMoreLink:
    - name: xx
      url: "https://aka.ms/finops/toolkit"
{{< /highlight >}}

| **Field**                     | **Description**                                                                                         | **Required** | **Example**                                                  |
|-------------------------------|---------------------------------------------------------------------------------------------------------|--------------|--------------------------------------------------------------|
| `description`                 | A concise description of the recommendation.                                                           | Yes          | `SQL Database elastic pool has no associated databases`      |
| `acorlGuid`                   | Unique identifier for the recommendation.                                                              | Yes          | `50987aae-a46d-49ae-bd41-a670a4dd18bd`                      |
| `recommendationTypeId`        | Type identifier for the recommendation. Use `null` if not applicable.                                  | No           | `null`                                                       |
| `recommendationControl`       | Categorization of the recommendation (e.g., Optimization/Resource Management).                         | Yes          | `UsageOptimization/OrphanedResources`                       |
| `recommendationImpact`        | Impact level of the recommendation (e.g., High, Medium, Low).                                          | Yes          | `High`                                                      |
| `recommendationResourceType`  | Resource type the recommendation applies to.                                                           | Yes          | `Microsoft.sql/servers/elasticpools`                        |
| `recommendationMetadataState` | Metadata status of the recommendation (e.g., Active, Deprecated).                                      | Yes          | `Active`                                                    |
| `remediationAction`           | Suggested action to resolve or mitigate the issue.                                                     | Yes          | `Review and remove this resource if not needed`             |
| `potentialBenefits`           | Key benefits of implementing the recommendation.                                                       | Yes          | `Remove idle resources`                                     |
| `pgVerified`                  | Indicates if the recommendation is verified by Product Group (`true`/`false`).                        | No          | `true`                                                      |
| `publishedToLearn`            | Whether the recommendation is published to Learn documentation (`true`/`false`).                      | No           | `false`                                                     |
| `automationAvailable`         | Indicates if automation is available for this recommendation (`true`/`false`).                        | No          | `true`                                                      |
| `tags`                        | Tags for additional categorization. Use `null` if not applicable.                                      | No           | `null`                                                      |
| `learnMoreLink`               | Links to additional resources. Includes a `name` and `url`. Multiple links can be added as a list.     | No           | `- name: xx`<br>`  url: https://aka.ms/finops/toolkit`      |


### 3. **Add or Update the `_index.md`**
Index Markdown File: Displays and merges the KQL content and YAML data.

- **Location:** `docs/content/azure-resources/<ResourceType>/<Resource>/`
- **Purpose:** This file merges the information from the KQL and YAML files into a presentable format for the Hugo site.
- **Example Content:**
    ```markdown
    ---
    title: Resource Type - Resource Recommendations
    ---
    { {< kqltomd file="example-uuid" >} } <!--- Remove the extra blank space between the curly brackets so Hugo understand this as a shortcode { {< shortcode >} }>
    ```

---

## What If the ResourceType/Resource Doesn't Exist?

If the directory for your `<ResourceType>` or `<Resource>` does not exist, you can create it:

1. Add a folder under `docs/content/azure-resources/` for the `<ResourceType>`.
2. Inside this folder, create a subfolder for the `<Resource>`.
3. Ensure both a `kql/` folder and `_index.md` are added under the `<Resource>` directory.
4. Add a corresponding folder under `docs/data/recommendations/azure-resources/<ResourceType>/<Resource>/`.

---

## Creating a TOC for a New ResourceType

Follow these steps to create a Table of Contents (TOC) for a new `ResourceType` in your Hugo project:

### Step 1: Understand the Folder Structure
Each `ResourceType` should have its directory under `docs/content/azure-resources`. For example:
{{< highlight markdown >}}
docs/
└── content/
    └── azure-resources/
        └── <ResourceType>/
            └── _index.md
{{< /highlight >}}
Replace `<ResourceType>` with the actual type, such as `compute`, `network`, `storage`, etc.

### Step 2: Add Resource Directories
Inside the `ResourceType` directory, create subdirectories for each specific resource. For example:

docs/content/azure-resources/<ResourceType>/
└── resourceA/
└── resourceB/
└── resourceC/

### Step 3: Add the `_index.md` File
Create an `_index.md` file inside the `ResourceType` directory. This file serves as the entry point and includes a TOC shortcode.

### Example `_index.md`:
{{< highlight markdown >}}
---
title: "<ResourceType> Resources"
---

# Table of Contents for <ResourceType>


{ {< toc >} } <!--- Remove the extra blank space between the curly brackets so Hugo understand this as a shortcode { {< shortcode >} }>

{{< /highlight >}}

### Step 4: Add Resource Pages

For each resource under the new `ResourceType`, ensure the following:

1. Create a `_index.md` file in each resource directory:

{{< highlight markdown >}}
---
title: "<Resource Name>"
---
Description of the resource...
{{< /highlight >}}


### [Hugo Shortcodes Used on This Site](#shortcodes)

In Hugo, **shortcodes** allow us to embed dynamic content into Markdown files easily. Shortcodes are wrapped in double curly braces `{{ }}`, and Hugo processes them during site generation to output the corresponding content. This helps to incorporate advanced functionalities, such as rendering tables or generating automatic navigation, without having to write complex logic each time.

The following shortcodes are used in this project:

#### 1. **yamltotable2.html**

The `yamltotable2.html` shortcode is designed to read a YAML file and display its contents as an HTML table. It performs the following steps:

1. **ResourceType and Resource Input**: It accepts two parameters: `resourceType` and `resource`. These parameters define the specific resource and resource type for which the YAML data will be retrieved.
   
2. **Dynamic File Path Construction**: The shortcode constructs the path to the YAML file dynamically using the provided `resourceType` and `resource` values. The expected file structure is `data/recommendations/azure-resources/{resourceType}/{resource}/recommendations.yaml`.

3. **YAML Parsing**: It reads the YAML file, parses it, and transforms the data into a structured format. If the YAML file is empty or the data is not found, it defaults to an empty list.

4. **Table Generation**: If the YAML data exists, the shortcode generates an HTML table with the following columns:
   - Description
   - ACORL Guid
   - Recommendation Control
   - Impact
   - Resource Type
   - Remediation Action
   - Potential Benefits

5. **Error Handling**: If the file does not contain any data or the file is missing, an error message is displayed that indicates no data was found for the specified file.

File location `docs/layouts/shortcodes/yamltotable2.html`

#### 2. **toc.html**
### Table of Contents (TOC) Shortcode

The `toc.html` shortcode is designed to dynamically generate a Table of Contents (TOC) based on the subdirectories in a specified directory. It performs the following steps:

1. **Directory Input**: It accepts a `dir` parameter, which represents the base directory where the TOC should be generated.
2. **Directory Reading**: The shortcode reads the contents of the specified directory (e.g., `content/{dir}`).
3. **Subdirectory Filtering**: It checks whether the subdirectories contain an `_index.md` file (which typically indicates that they are valid Hugo content directories).
4. **TOC Generation**: If valid subdirectories are found, it generates an HTML list of links to these subdirectories, humanizes the directory names, and adds them to the TOC.
5. **Error Handling**: If no subdirectories are found or if the `dir` parameter is missing or invalid, it outputs an appropriate error message.

File location `docs/layouts/shortcodes/toc.html`


#### 3. **kqltomd.html**

The `kqltomd.html` shortcode is designed to render a KQL file's content as a formatted code block within the page. The shortcode does the following:

1. **File Parameter Input**: The shortcode accepts a `file` parameter which specifies the name of the KQL file to be rendered.

2. **File Path Construction**: The shortcode constructs the file path relative to the page directory by appending the provided `file` parameter to the path `kql/` within the current page directory. This allows for dynamic file resolution based on where the page is located.

3. **KQL File Reading**: The shortcode reads the content of the KQL file, if available, and attempts to render it.

4. **Rendering as a Code Block**: If the KQL file exists and contains content, the shortcode formats and renders it as a code block with syntax highlighting for KQL, using a `<pre>` HTML element with appropriate styling.

5. **Error Handling**: If the KQL file is not found or is empty, the shortcode displays an error message indicating that the specified file could not be found.

File location `docs/layouts/shortcodes/kqltomd.html`

# Closing Notes

Thank you for your interest in contributing to this project! We greatly appreciate your time and effort to help improve and expand our resources. 
