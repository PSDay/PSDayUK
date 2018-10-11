[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Just an example")]
param()

Write-Host 'hello'

# Auto-Fix
gci

# Formatting: Ctrl + K + F 
if ($true)
{

}

# PSPossibleIncorrectUsageOfRedirectionOperator
if ($a > $b) {

}

# PSPossibleIncorrectUsageOAssignmentOperator
if ($a = $b) {

}

Invoke-Expression -Command '#format c'
