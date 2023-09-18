# Function to create folders
function Create-Folders {
    param (
        [string]$countryName,
        [string[]]$subfolders
    )

    $countryFolder = Join-Path (Get-Location) $countryName
    New-Item -Path $countryFolder -ItemType Directory -Force

    foreach ($subfolder in $subfolders) {
        $subfolderPath = Join-Path $countryFolder $subfolder.Trim()
        New-Item -Path $subfolderPath -ItemType Directory -Force
    }
}

# Function to create individual subfolders within all folders in the current directory
function Create-IndividualSubfoldersWithinAllFolders {
    param (
        [string[]]$subfolders
    )

    $currentDirectory = Get-Location

    $allFolders = Get-ChildItem -Directory

    foreach ($folder in $allFolders) {
        $folderPath = Join-Path $currentDirectory $folder.Name

        foreach ($subfolder in $subfolders) {
            $subfolderPath = Join-Path $folderPath $subfolder.Trim()

            if (-not (Test-Path -Path $subfolderPath -PathType Container)) {
                New-Item -Path $subfolderPath -ItemType Directory -Force
            }
        }
        Write-Host "Individual subfolders created in bulk within $($folder.Name)."
    }
}

# Function to create README.md files
function Create-ReadmeFiles {
    param (
        [string]$countryName
    )

    $countryFolder = Join-Path (Get-Location) $countryName

    Get-ChildItem -Path $countryFolder -Directory | ForEach-Object {
        $readmeFile = Join-Path $_.FullName "README.md"
        Set-Content -Path $readmeFile -Value "# Will update later (as a placeholder)" -Force
    }
}

# Function to fetch all countries from the RestCountries API
function Fetch-AllCountries {
    $url = "https://restcountries.com/v3.1/all"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        $countries = $response | ForEach-Object { $_.name.common }
        return $countries
    } catch {
        Write-Host "Failed to fetch data from the API."
        return @()
    }
}

# Main menu
while ($true) {
    Write-Host "`nMain Menu:"
    Write-Host "1. API Fetch of all countries and Create Folders"
    Write-Host "2. Sub Folder Creation"
    Write-Host "3. Bulk README.md file creator"
    Write-Host "4. Exit"

    $choice = Read-Host "Enter your choice (1/2/3/4)"

    switch ($choice) {
        1 {
            Write-Host "API Fetch of all countries and Create Folders:"
            $countries = Fetch-AllCountries

            if ($countries.Count -eq 0) {
                Write-Host "No countries fetched. Check your internet connection or try again later."
                continue
            }

            foreach ($country in $countries) {
                Create-Folders -countryName $country
                Write-Host "Folder created for $country."
            }
        }
        2 {
            Write-Host "Sub Folder Creation:"
            Write-Host "1. Create Individual Subfolders in Bulk"
            Write-Host "2. Create Subfolders within subfolders"
            $subChoice = Read-Host "Enter your choice (1/2)"

            if ($subChoice -eq 1) {
                $subfolders = (Read-Host "Enter subfolders (comma-separated)").Split(',')
                Create-IndividualSubfoldersWithinAllFolders -subfolders $subfolders
                Write-Host "Individual subfolders created in bulk within all folders in the current directory."
            } elseif ($subChoice -eq 2) {
                $subfolderName = Read-Host "Enter the name of the subfolder"
                $subfolders = (Read-Host "Enter subfolders within $subfolderName (comma-separated)").Split(',')
                Create-SubfoldersWithinAllFolders -subfolderName $subfolderName -subfolders $subfolders
                Write-Host "Subfolders created within $subfolderName in all folders in the current directory."
            } else {
                Write-Host "Invalid choice. Please enter a valid sub-option (1/2)."
            }
        }
        3 {
            Write-Host "Bulk README.md file creator:"
            $countryName = Read-Host "Enter the name of the country"
            Create-ReadmeFiles -countryName $countryName
            Write-Host "README.md files created for $countryName and its subfolders."
        }
        4 {
            break
        }
        default {
            Write-Host "Invalid choice. Please enter a valid option."
        }
    }
}
