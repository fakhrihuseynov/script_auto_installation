<#
.SYNOPSIS
    .
.DESCRIPTION
    The purpose of this script is getting an API get request from Microsot Azure Devops 
    and feel all existing variables in to hash-table then 
     

.PROJECTNAME
    Name of the target project GIBRALTAR TECHNOLOGIES.
.PARAMETER OUT TO C:/ DRIVE
    Output file directly to SystemDrive (most case is C:/) by placing as C:/myApi.txt

.EXAMPLE
    The script will query request using PAT token from the C drive pat.txt and
    will authorize the get proccess query for Azure Devops Variable group named REST-API
    And will fetch all the variabels on dedicated variable group.

.NOTES
    Author: FAKHRI HUSEYNOV
    Date:   27.03.2022
#>
$baseUrl = "https://dev.azure.com/x-huseynovf/x-huseynovf/"
$url_endpoint = "_apis/distributedtask/variablegroups?api-version=6.0-preview.2"
$url = $baseUrl + $url_endpoint
$PAT = Get-Content "$env:SystemDrive\pat.txt"
$user = ""
$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $PAT)))
$header = @{authorization = "Basic $token" }

$response = Invoke-RestMethod -uri $url -Method Get -ContentType "application/json" -Headers $header
$response | ConvertTo-Json -Depth 5

$Key1 = "Author Name"
$Key2 = "Author Sirname";
$Key3 = "Job experience and main focuse"
$Key4 = "Preffered Infrastructure as Code Tools"
$Key5 = "Preffered script type for automating"
$Key6 = "Gained experience by years"

$value1 = $response.value.variables.'Author Name'.value
$value2 = $response.value.variables.'Author Sirname'.value
$value3 = $response.value.variables.'Cloud experience'.value
$value4 = $response.value.variables.'IaC tools'.value
$value4 = $response.value.variables.'IaC tools'.value
$value5 = $response.value.variables.'Owned scripts'.value
$value6 = $response.value.variables.'Work experience by year'.value

$hash = [ordered]@{ 

    $Key1 = $value1;
    $Key2 = $value2;
    $Key3 = $value3;
    $Key4 = $value4;
    $Key5 = $value5;
    $Key6 = $value6
}
$hash | Format-Table -AutoSize | Out-File $env:SystemDrive\myApi.txt