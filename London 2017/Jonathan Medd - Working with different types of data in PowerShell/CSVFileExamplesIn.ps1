# --- Import a CSV with no header
Import-Csv .\Data\Example1.csv -Header GivenName,Surname,DisplayName,SAMAccountName,Office,Department

# --- Import a CSV with a header
Import-Csv .\Data\Example2.csv

# --- Pass the results to do something useful
# --- Import-Csv .\Data\Example2.csv | New-ADUser

# --- Import a CSV with a different delimiter
Import-Csv .\Data\Example3.csv -Delimiter ";"