# Uninstall-ModuleOlderVersion
## SYNOPSIS
Function intended for uninstalling older versions of functions installed from PowerShell Gallery

## SYNTAX
```powershell
Uninstall-ModuleOlderVersion [-Name <String>] [-Scope <String>] [-PassThru] [-ReturnExitCode] [-WhatIf] [-Confirm] [<CommonParameters>]



Uninstall-ModuleOlderVersion [-Name <String>] [-Path <String>] [-PassThru] [-ReturnExitCode] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Function intended for uninstalling older versions of functions installed from PowerShell Gallery what left if Update-Module is used.

## PARAMETERS
### -Name &lt;String&gt;
The name of module for what older versions need to be uninstalled. If not provided all modules in scope will be checked.
```
Required?                    false

Position?                    named

Default value

Accept pipeline input?       false

Accept wildcard characters?  false
```

### -Scope &lt;String&gt;
The scope what will be used for finding/uninstalling.

By default the scope is "AllUsers", what means that modules in the folder <Program Files>\WindowsPowerShell\Modules will be checked.

For the scope "CurrentUser" modules in the folder <USERPROFILE>\Documents\WindowsPowerShell\Modules or <USERPROFILE>\WindowsPowerShell\Modules will be checked.
```
Required?                    false

Position?                    named

Default value                AllUsers

Accept pipeline input?       false

Accept wildcard characters?  false
```

### -Path &lt;String&gt;
If the parameter path is filled than only modules installed on the path will be checked
```
Required?                    false

Position?                    named

Default value

Accept pipeline input?       false

Accept wildcard characters?  false
```

### -PassThru &lt;SwitchParameter&gt;
If PassThru is set to true than the function will return custom Powershell object contains uninstalled modules will be returned
```
Required?                    false

Position?                    named

Default value                False

Accept pipeline input?       false

Accept wildcard characters?  false
```

### -ReturnExitCode &lt;SwitchParameter&gt;
If the parameter is set to true than the function will return exit code number



Exit codes  
 -1 - Any module don't have older version installed  
  0 - The older module version installed successfully  
  1 - The error occured under uninstalling the older module version  
  2 - Some older version don't installed due to user decision  
  3 - The interrupted by user decision
```
Required?                    false

Position?                    named

Default value                False

Accept pipeline input?       false

Accept wildcard characters?  false
```

### -WhatIf &lt;SwitchParameter&gt;

```
Required?                    false

Position?                    named

Default value

Accept pipeline input?       false

Accept wildcard characters?  false
```

### -Confirm &lt;SwitchParameter&gt;

```
Required?                    false

Position?                    named

Default value

Accept pipeline input?       false

Accept wildcard characters?  false
```

## INPUTS


## NOTES
AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net

KEYWORDS: PowerShell, PowerShell Gallery, modules



VERSIONS HISTORY

- 0.1.0 - 2016-02-18 - The first draft

- 0.1.1 - 2016-02-19 - Modules filtering corrected

- 0.2.0 - 2016-02-23 - Uninstall-Module used except Remove-Item on a folder, PassThru implemented,parameter sets implemented, exit codes implemented, help updated





TODO

- update help

- check if function is used in elevated PowerShell

- implement pipeline for the module name

- implement support for uninstalling scripts also





LICENSE

Copyright (c) 2016 Wojciech Sciesinski

This function is licensed under The MIT License (MIT)

Full license text: https://opensource.org/licenses/MIT

## EXAMPLES
### EXAMPLE 1
```powershell
PS C:\>Uninstalling modules with default parameters for scope (AllUsers) and name (all modules).



[PS]  > Uninstall-ModuleOlderVersion -Verbose -PassThru

VERBOSE: Uninstalling older version of module(s) from the path: C:\Program Files\WindowsPowerShell\Modules*

VERBOSE: Older versions for modules: PSScriptAnalyzer found

VERBOSE: For the module PSScriptAnalyzer 3 versions found.



Uninstall module

Do you want to uninstall the version 1.2.0 of the module PSScriptAnalyzer?

[Y] Yes  [A] All  [N] No  [O] No for All  [?] Help (default is "Y"): y

VERBOSE: Uninstalling the 1.2.0 of the module PSScriptAnalyzer.

What if: Performing the operation "Uninstall-Module" on target "Version '1.2.0' of module 'PSScriptAnalyzer'".



Uninstall module

Do you want to uninstall the version 1.3.0 of the module PSScriptAnalyzer?

[Y] Yes  [A] All  [N] No  [O] No for All  [?] Help (default is "Y"): y

VERBOSE: Uninstalling the 1.3.0 of the module PSScriptAnalyzer.

What if: Performing the operation "Uninstall-Module" on target "Version '1.3.0' of module 'PSScriptAnalyzer'".



           Directory: C:\Program Files\WindowsPowerShell\Modules



ModuleType Version    Name                                ExportedCommands

---------- -------    ----                                ----------------

Binary     1.2.0      PSScriptAnalyzer                    {Get-ScriptAnalyzerRule, Invoke-ScriptAnalyzer}

Script     1.3.0      PSScriptAnalyzer                    {Get-ScriptAnalyzerRule, Invoke-ScriptAnalyzer}
```
