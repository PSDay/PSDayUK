# --- Read the contents of a text file
Get-Content .\Data\Example1.txt

# --- The data is an array
$a = Get-Content .\Data\Example1.txt
$a.GetType()

# --- Count the number of elements
$a.Count

# --- Select an element of the array
$a[3]

# --- Filter for specific text
$a |  Where-Object {$_ -match "4"}

# --- Replace specific text
$a -replace "This is line","We are at section"

# --- Grab the first 3 lines
Get-Content .\Data\Example1.txt -TotalCount 3

# --- Grab the last 3 lines
Get-Content .\Data\Example1.txt -Tail 3

# --- tail -f equivalent
Get-Content .\Data\Example2.txt -Wait

# --- Raw
$b = Get-Content .\Data\Example1.txt -Raw
$b.GetType()

# --- Count the number of elements
$b.Count

# --- Examine the string length
$b.Length

# --- Consider not using Get-Content with very large files, because it reads the entire file into memory. 
# --- Instead, read your file from disk one line at a time and work with each line
# --- Instead of caching the entire file in RAM, you're reading it off disk one line at a time.
$c = New-Object System.IO.StreamReader C:\Users\Jonathan\Documents\Development\Presentations\PSDayUK\2017\Data\Example1.txt
while ($line = $c.ReadLine()) {
  
   $line -replace "This is line","We are at section"
}
$c.close()

# --- Search for string in text files
Select-String -Path .\Data\*.txt -Pattern "3"