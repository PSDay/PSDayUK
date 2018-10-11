@{
    IncludeDefaultRules=$true
	ExcludeRules = @(
        'PSUseDeclaredVarsMoreThanAssignments'
    )
    'Rules' = @{
        'PSUseCompatibleCmdlets' = @{
            'compatibility' = @("core-6.0.2-windows", "desktop-4.0-windows")
        }
    }
}