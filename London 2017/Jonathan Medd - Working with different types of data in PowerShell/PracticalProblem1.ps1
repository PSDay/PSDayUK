# --- Performance of changes with a large JSON dataset
# --- ConvertFrom-JSON generates a PSCustomObject
$JSON5 = @"
{
    "name":"Freddy",
    "age":32,
    "fruit":[ "Kiwi", "Orange" ]
}
"@ | ConvertFrom-Json

$JSON5.GetType()$JSON5 = @"
{
    "name":"Freddy",
    "age":32,
    "fruit":[ "Kiwi", "Orange" ]
}
"@ | ConvertFrom-Json

$JSON5.GetType()

# --- Carry out performance test of making many additions and note the time in TotalSeconds
Measure-Command {
    Foreach($number in 1..10000)
    {
        $JSON5 | Add-Member -MemberType NoteProperty -Name "$number" -Value $number
    }
}

# --- Instead we could make a hashtable and can still output to a JSON file with ConvertTo-JSON
$Hash1 = @{
    "name" ="Rod"
    "age" = 37
    "fruit" = "Apple", "Pear"
}

$Hash1

$Hash1 | ConvertTo-Json

# --- Notice the order
$Hash2 = [ordered]@{
    "name" ="Rod"
    "age" = 37
    "fruit" = "Apple", "Pear"
}
$Hash2

$Hash2 | ConvertTo-Json

# --- Perform the same number of additions and observe the reduction in time
Measure-Command {
    Foreach($number in 1..10000)
    {
        $Hash2.Add("$number", $number)
    }
}

# --- Convert PSCustomObject to a Hashtable
function ConvertTo-Hashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.Hashtable]) {
            return $InputObject
        }
        elseif ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) { ConvertTo-Hashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject])
        {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties)
            {
                $hash[$property.Name] = ConvertTo-Hashtable $property.Value
            }

            $hash
        }
        else
        {
            $InputObject
        }
    }
}

$JSON6 = @"
{
    "name":"Freddy",
    "age":32,
    "fruit":[ "Kiwi", "Orange" ]
}
"@ | ConvertFrom-Json

$Hash3 = $JSON6 | ConvertTo-Hashtable

$Hash3

$Hash3.GetType()

# --- Add option to ConvertFrom-Json as a Hashtable has a milestone of PS Core 6.1
# --- https://github.com/PowerShell/PowerShell/issues/3623