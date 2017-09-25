# --- Import data from a file and ConvertFrom-JSON
$JSON1 = Get-Content .\Data\Example1.JSON | ConvertFrom-Json
$JSON1

# --- Use Object Dot Notation to navigate the JSON data
$JSON1.resources

$JSON1.resources[0].properties

$JSON1.resources[0].properties.administratorLogin

# --- Receive data from a webservice and convert from JSON to a PowerShell Object
$JSON2 = Invoke-WebRequest -Uri 'https://api.github.com/users/jonathanmedd/repos' | ConvertFrom-Json

$JSON2 | Format-Table Name,default_branch,html_url -AutoSize
