
function Set-EnvVar {
    $env:REDMINECOUNTISSUES = $(GetRedmine-OpenIssuesCount)
    $env:REDMINECOUNTMYISSUES = $(GetRedmine-MyOpenIssuesCount)
    $env:REDMINECOUNTMYHOURS = $(GetRedmine-SumHoursEntries)
}

New-Alias -Name 'Set-PoshContext' -Value 'Set-EnvVar' -Scope Global -Force

function GetRedmine-SumHoursEntries {
    try {
        $Today = (Get-Date).Date
        $Monday = $Today.AddDays(1 - $Today.DayOfWeek.value__)
        $apiUrl = "http://redmineserver/time_entries.json?from=$($Monday.Year)-$($Monday.toString("MM"))-$($Monday.toString("dd"))&to=2024-01-01&user_id=me&limit=100"
        $apiKey = ''
        $headers = @{
            "X-Redmine-API-Key" = $apiKey
        }
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
        if (($response.time_entries).Count -eq 0) {
            Write-Output 0
            return
        }
        $result = ($response.time_entries | measure-object -property hours -sum).sum
        Write-Output $result
    }
    catch {
        Write-Error "Failed to retrieve sum from time entries. Error: $_"
    }
}

unction GetRedmine-OpenIssuesCount {
    try {
        $apiUrl = "http://redmineserver/issues.json?status_id=open&limit=1"
        $apiKey = ''
        $headers = @{
            "X-Redmine-API-Key" = $apiKey
        }
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
        Write-Output $response.total_count
    }
    catch {
        Write-Error "Failed to retrieve open issue count. Error: $_"
    }
}

function GetRedmine-MyOpenIssuesCount {
    try {
        $apiUrl = "http://redmineserver/issues.json?status_id=open&assigned_to_id=me&limit=1000"
        $apiKey = ''
        $headers = @{
            "X-Redmine-API-Key" = $apiKey
        }
        $openStatus = 1, 2, 6, 7
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
            
        $myIssues = ($response.issues | where-object { $openStatus -contains $_.status.id }).Count
        Write-Output $myIssues
    }
    catch {
        Write-Error "Failed to retrieve my open issue count. Error: $_"
    }
}
