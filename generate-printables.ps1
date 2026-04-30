$ErrorActionPreference = 'Stop'

function New-PrintableMarkdown {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TrailPath,
        [Parameter(Mandatory = $true)]
        [string]$OutPath,
        [Parameter(Mandatory = $true)]
        [bool]$IncludeAnswers
    )

    $trail = Get-Content -Raw $TrailPath | ConvertFrom-Json -Depth 20
    $lines = New-Object System.Collections.Generic.List[string]
    $version = if ($IncludeAnswers) { 'With Answers' } else { 'Questions Only' }

    $lines.Add("# $($trail.name) - Printable ($version)")
    $lines.Add('')
    $lines.Add("$($trail.description)")
    $lines.Add('')

    for ($i = 0; $i -lt $trail.questions.Count; $i++) {
        $q = $trail.questions[$i]
        $previousIndex = if ($i -eq 0) { $trail.questions.Count - 1 } else { $i - 1 }
        $nextLocation = $trail.questions[$previousIndex].reward

        $locationTitle = $nextLocation.title
        $locationDescription = $nextLocation.description
        $locationAddress = $nextLocation.address
        $locationOsGrid = $nextLocation.osGrid
        $locationW3w = $nextLocation.w3w
        $locationLat = $nextLocation.lat
        $locationLng = $nextLocation.lng

        $lines.Add("## Stop $($q.id)")
        $lines.Add('')
        $lines.Add("**Question:** $($q.question)")

        if ($IncludeAnswers) {
            $lines.Add('')
            $lines.Add("**Answer:** $($q.correctAnswer)")
        } else {
            $lines.Add('')
            $lines.Add("**Answer:** _______________________________________________")
        }

        $lines.Add('')
        $lines.Add("**Next Location:** $locationTitle")
        $lines.Add("**Location Note:** $locationDescription")
        $lines.Add("**Address:** $locationAddress")
        $lines.Add("**OS Grid:** $locationOsGrid")
        $lines.Add("**What3Words:** $locationW3w")
        $lines.Add("**Lat/Lng:** $locationLat, $locationLng")
        $lines.Add('')
        $lines.Add('---')
        $lines.Add('')
    }

    [System.IO.File]::WriteAllLines($OutPath, $lines)
}

$printablesDir = 'docs/printables'
if (-not (Test-Path $printablesDir)) {
    New-Item -ItemType Directory -Path $printablesDir -Force | Out-Null
}

New-PrintableMarkdown -TrailPath 'docs/trails/trail-4.json' -OutPath 'docs/printables/trail-4-questions.md' -IncludeAnswers:$false
New-PrintableMarkdown -TrailPath 'docs/trails/trail-4.json' -OutPath 'docs/printables/trail-4-with-answers.md' -IncludeAnswers:$true
New-PrintableMarkdown -TrailPath 'docs/trails/trail-5.json' -OutPath 'docs/printables/trail-5-questions.md' -IncludeAnswers:$false
New-PrintableMarkdown -TrailPath 'docs/trails/trail-5.json' -OutPath 'docs/printables/trail-5-with-answers.md' -IncludeAnswers:$true

Write-Host 'Printable markdown files created in docs/printables.'
