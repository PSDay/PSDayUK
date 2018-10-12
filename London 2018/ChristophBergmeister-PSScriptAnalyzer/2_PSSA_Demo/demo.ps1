# Auto-Fix
gci

# Formatting: Ctrl + K + F 
if ($true)
{

}

# PSPossibleIncorrectUsageOfRedirectionOperator
if ($a > $b) {

}

# PSPossibleIncorrectUsageOfAssignmentOperator
if ($a = $b) {

}

# PSUseCompatibleCmdlets
Compress-Archive

# PSSA Settings/VSCode integration:
https://github.com/bergmeister/PSScriptAnalyzer-VSCodeIntegration


###################################################################

# PSAvoidUsingCmdletAlias for implicit 'Get-' alias (if applicable on the given platform)
service
curl
# Show on Ubuntu: Invoke-ScriptAnalyzer -ScriptDefinition 'service'


###################################################################

Show-Ast { if($a -eq "$b.wth()"){ }  }