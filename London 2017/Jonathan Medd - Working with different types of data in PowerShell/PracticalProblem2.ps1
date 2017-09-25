# --- Look at the output from a text file
# --- which doesn't support structured output
# --- but in your mind you can see the pattern
$AddressData = Get-Content .\Data\PracticalProblem2.txt

$AddressData

# --- We can give a template with a pattern example
$StringTemplate1 = @'
{Name*:Homer Simpson}
{Location:742 Evergreen Terrace}
{City:Springfield}
{Phone:321-827-8734}

{Name*:Moe}
{Location:Moes Tavern}
{City:Springfield}
{Phone:834-235-2345}

{Name*:Seymour Skinner}
{Location:Springfield Elementary School}
{City:Springfield}
{Phone:390-534-2923}
'@

# --- Then supply the template to ConvertFrom-String to
# --- tell it what to look for
$ConvertResult = $AddressData | ConvertFrom-String -TemplateContent $StringTemplate1

$ConvertResult

# --- Then we can use it like any other PSCustomObject
$ConvertResult | Select-Object Name,Phone