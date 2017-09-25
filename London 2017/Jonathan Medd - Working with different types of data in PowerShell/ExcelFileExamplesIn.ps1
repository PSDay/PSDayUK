# --- Examine what is available in the ImportExcel module
Get-Command -Module ImportExcel

# --- Import data from a worksheet in an Excel file
Invoke-Item .\Data\Example1.xlsx

$Data = Import-Excel -WorkSheetname Sheet1 -Path .\Data\Example1.xlsx

$Data

# --- Sum one of the Excel columns
$Data | Measure-Object -Property Apples -Sum