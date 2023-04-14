$url = "https://datausa.io/api/data?drilldowns=State&measures=Population"

$headers = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
}
$response = Invoke-RestMethod -Uri $url -Headers $headers
$myjson = $response | ConvertTo-Json -Depth 100
$ourdata = @()
$csvheader = 'State ID', 'State Name', 'Year ID', 'Year', 'Population', 'State Slug', 'Population Change'

foreach ($x in $response.data) {
    $population_change = $x.'Population' - $ourdata[-1][4]
    $percent_change = [Math]::Round((($x.'Population' - $ourdata[-1][4]) / $ourdata[-1][4]) * 100, 2)
    $percent_change_formatted = "($percent_change%)"
    $listing = @(
        $x.'ID State',
        $x.'State',
        $x.'ID Year',
        $x.'Year',
        $x.'Population',
        $x.'Slug State',
        "$population_change $percent_change_formatted"
    )
    $ourdata += ,$listing
}

$filePath = 'data.csv'
Set-Content -Path $filePath -Value '' # Clear the file content
Add-Content -Path $filePath -Value ($csvheader -join ',')
Add-Content -Path $filePath -Value ''

foreach ($listing in $ourdata) {
    Add-Content -Path $filePath -Value ($listing -join ',')
}

Write-Output $ourdata
