# --- Import data from a file and ConvertFrom-Yaml
$YAML1 = Get-Content .\Data\Example1.yaml -Raw | ConvertFrom-Yaml
$YAML1

# --- Use Object Dot Notation to navigate the Yaml data
$YAML1[0].Values

# --- Use where filering to select a specific record
$YAML1 | where keys -eq 'homer'