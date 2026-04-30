param(
    [Parameter(Mandatory = $true)]
    [string]$InputCsv,

    [string]$OutputJson,

    [string]$TrailName,

    [string]$TrailDescription,

    [switch]$Register,

    [switch]$Overwrite
)

$scriptRoot = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot
} elseif (-not [string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.Path)) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    (Get-Location).Path
}

function Resolve-PathFromRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return [System.IO.Path]::GetFullPath((Join-Path $scriptRoot $PathValue))
}

function Get-NextTrailFileName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TrailsIndexPath
    )

    if (-not (Test-Path $TrailsIndexPath)) {
        return "trail-1.json"
    }

    $entries = Get-Content -Raw $TrailsIndexPath | ConvertFrom-Json
    if ($null -eq $entries) {
        return "trail-1.json"
    }

    $max = 0
    foreach ($entry in $entries) {
        if ($entry -match '^trail-(\d+)\.json$') {
            $num = [int]$matches[1]
            if ($num -gt $max) {
                $max = $num
            }
        }
    }

    return "trail-$($max + 1).json"
}

function Parse-Double {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$FieldName,
        [Parameter(Mandatory = $true)]
        [string]$RowId
    )

    $number = 0.0
    if (-not [double]::TryParse($Value, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$number)) {
        throw "Row '$RowId' has invalid $FieldName value: '$Value'"
    }

    return $number
}

$inputPath = Resolve-PathFromRoot -PathValue $InputCsv
if (-not (Test-Path $inputPath)) {
    throw "Input CSV not found: $inputPath"
}

$trailsIndexPath = Join-Path $scriptRoot "docs/trails/trails.json"
if ([string]::IsNullOrWhiteSpace($OutputJson)) {
    $nextName = Get-NextTrailFileName -TrailsIndexPath $trailsIndexPath
    $OutputJson = Join-Path "docs/trails" $nextName
}

$outputPath = Resolve-PathFromRoot -PathValue $OutputJson
$outputDir = Split-Path -Parent $outputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

if ((Test-Path $outputPath) -and (-not $Overwrite)) {
    throw "Output file already exists: $outputPath. Use -Overwrite to replace it."
}

$rows = Import-Csv $inputPath
if ($null -eq $rows -or $rows.Count -eq 0) {
    throw "CSV is empty: $inputPath"
}

$requiredColumns = @("id", "type", "question", "correctAnswer", "title", "description", "address", "lat", "lng", "osGrid", "w3w")
$presentColumns = @($rows[0].PSObject.Properties.Name)
$missing = @($requiredColumns | Where-Object { $_ -notin $presentColumns })
if ($missing.Count -gt 0) {
    throw "CSV is missing required columns: $($missing -join ', ')"
}

if ([string]::IsNullOrWhiteSpace($TrailName)) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
    $TrailName = ($baseName -replace '[_-]+', ' ')
}

if ([string]::IsNullOrWhiteSpace($TrailDescription)) {
    $TrailDescription = "Imported from $([System.IO.Path]::GetFileName($inputPath))"
}

$questions = @()
for ($i = 0; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]

    if (-not [int]::TryParse($row.id, [ref]$null)) {
        throw "Row index $($i + 1) has invalid id value: '$($row.id)'"
    }

    $nextValue = if ($i -lt ($rows.Count - 1)) { [int]$rows[$i + 1].id } else { $null }

    $questionObj = [ordered]@{
        id            = [int]$row.id
        type          = $row.type
        question      = $row.question
        correctAnswer = $row.correctAnswer
        reward        = [ordered]@{
            title       = $row.title
            description = if ([string]::IsNullOrWhiteSpace($row.description)) { "Find this location to continue the trail." } else { $row.description }
            address     = $row.address
            lat         = Parse-Double -Value $row.lat -FieldName "lat" -RowId $row.id
            lng         = Parse-Double -Value $row.lng -FieldName "lng" -RowId $row.id
            osGrid      = $row.osGrid
            w3w         = $row.w3w
        }
        next          = $nextValue
    }

    $questions += $questionObj
}

$trailObj = [ordered]@{
    name        = $TrailName
    description = $TrailDescription
    questions   = $questions
}

$trailObj | ConvertTo-Json -Depth 8 | Set-Content -Path $outputPath -Encoding utf8

if ($Register) {
    if (-not (Test-Path $trailsIndexPath)) {
        throw "Cannot register trail because index file was not found: $trailsIndexPath"
    }

    $trailList = @(Get-Content -Raw $trailsIndexPath | ConvertFrom-Json)
    $outputFileName = Split-Path -Leaf $outputPath

    if ($outputFileName -notin $trailList) {
        $trailList += $outputFileName
        ($trailList | ConvertTo-Json -Compress) | Set-Content -Path $trailsIndexPath -Encoding utf8
    }
}

Write-Host "Created trail JSON: $outputPath"
if ($Register) {
    Write-Host "Registered in trails index: $trailsIndexPath"
}
