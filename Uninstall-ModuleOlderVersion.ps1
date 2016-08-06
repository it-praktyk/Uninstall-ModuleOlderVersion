Function Uninstall-ModuleOlderVersion {

<#
    .SYNOPSIS
    Function intended for uninstalling older versions of functions installed from PowerShell Gallery

    .DESCRIPTION
	Function intended for uninstalling older versions of functions installed from PowerShell Gallery what left if Update-Module is used.

    .PARAMETER Name
	The name of module for what older versions need to be uninstalled. If not provided all modules in scope will be checked.

	.PARAMETER Scope
	The scope what will be used for finding/uninstalling.
	By default the scope is "AllUsers", what means that modules in the folder <Program Files>\WindowsPowerShell\Modules will be checked.
	For the scope "CurrentUser" modules in the folder <USERPROFILE>\Documents\WindowsPowerShell\Modules or <USERPROFILE>\WindowsPowerShell\Modules will be checked.

	.PARAMETER Path
	If the parameter path is filled than only modules installed on the path will be checked

	.PARAMETER PassThru
	If PassThru is set to true than the function will return custom Powershell object contains uninstalled modules will be returned

	.PARAMETER ReturnExitCode
	If the parameter is set to true than the function will return exit code number

	Exit codes
	-1 - Any module don't have older version installed
	 0 - The older module version installed successfully
	 1 - The error occured under uninstalling the older module version
	 2 - Some older version don't installed due to user decision
	 3 - The interrupted by user decision


	.INPUTS

    .OUTPUTS

    .EXAMPLE

	Uninstalling modules with default parameters for scope (AllUsers) and name (all modules).

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


    .LINK
    https://github.com/it-praktyk/Uninstall-ModuleOlderVersion

    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech

    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell, PowerShell Gallery, modules

    VERSIONS HISTORY
    - 0.1.0 - 2016-02-18 - The first draft
    - 0.1.1 - 2016-02-19 - Modules filtering corrected
	- 0.2.0 - 2016-02-23 - Uninstall-Module used except Remove-Item on a folder, PassThru implemented,
						   parameter sets implemented, exit codes implemented, help updated
	- 0.3.0 - 2016-08-07 - Corrected behavior for WhatIf

    TODO
	- update help
	- check if function is used in elevated PowerShell
	- implement pipeline for the module name
	- implement support for uninstalling scripts also


    LICENSE
	Copyright (c) 2016 Wojciech Sciesinski
    This function is licensed under The MIT License (MIT)
    Full license text: https://opensource.org/licenses/MIT

#>

	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = 'byScope')]
	Param (

		[Parameter(Mandatory = $false)]
		[String]$Name,
		[Parameter(Mandatory = $false, ParameterSetName = 'byScope')]
		[ValidateSet("CurrentUser", "AllUsers")]
		[string]$Scope = "AllUsers",
		[Parameter(Mandatory = $false, ParameterSetName = 'byPath')]
		[String]$Path,
		[Parameter(Mandatory = $false)]
		[Switch]$PassThru,
		[Parameter(Mandatory = $false)]
		[Switch]$ReturnExitCode

	)

	begin {
        
        [Bool]$UninstallOne = $false
        
        [bool]$SkipAll = $false

		If ( $PSBoundParameters.Get_Item("WhatIf").IsPresent ) {
		
			$UninstallForAll = $true
		
		}
		Else {
		
			[Bool]$UninstallForAll = $false
		
		}
		
		
		$Results =@()

		If ($Path) {

			#Add validation of provided path here

		}
		Else {

			#region Part of code from PowerShellGet module, author: Microsoft

			try {
				$script:MyDocumentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
			}
			catch {
				$script:MyDocumentsFolderPath = $null

				Write-Host "Error"
			}



			$script:ProgramFilesPSPath = Microsoft.PowerShell.Management\Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell"

			$script:MyDocumentsPSPath = if ($script:MyDocumentsFolderPath) {
				Microsoft.PowerShell.Management\Join-Path -Path $script:MyDocumentsFolderPath -ChildPath "WindowsPowerShell"
			}
			else {
				Microsoft.PowerShell.Management\Join-Path -Path $env:USERPROFILE -ChildPath "Documents\WindowsPowerShell"
			}

			$script:ProgramFilesModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $script:ProgramFilesPSPath -ChildPath "Modules"
			$script:MyDocumentsModulesPath = Microsoft.PowerShell.Management\Join-Path -Path $script:MyDocumentsPSPath -ChildPath "Modules"

			$script:ProgramFilesScriptsPath = Microsoft.PowerShell.Management\Join-Path -Path $script:ProgramFilesPSPath -ChildPath "Scripts"

			$script:MyDocumentsScriptsPath = Microsoft.PowerShell.Management\Join-Path -Path $script:MyDocumentsPSPath -ChildPath "Scripts"

			#endregion

			If ([String]::IsNullOrEmpty($Path)) {

				If ($Scope -eq "AllUsers") {

					$Path = "{0}*" -f $script:ProgramFilesModulesPath

				}
				Else {

					$Path = "{0}*" -f $script:MyDocumentsModulesPath

				}

			}

			[String]$MessageText = "Uninstalling older version of module(s) from the path: {0}" -f $Path

			Write-verbose -message $MessageText

		}

	}

	Process {

		If ($Name) {

			$MultiModules = (Get-Module -ListAvailable -verbose:$false | Where-Object -FilterScript { $_.path -like $Path -and $_.Name -like $Name } | Group-Object -Property Name | Where-Object -FilterScript { $_.count -gt 1 }).name

		}
		Else {

			$MultiModules = (Get-Module -ListAvailable -verbose:$false | Where-Object -FilterScript { $_.path -like $Path } | Group-Object -Property Name | Where-Object -FilterScript { $_.count -gt 1 }).name

		}

		If ($MultiModules) {

			[String]$MessageText = "Older versions for modules: {0} found" -f [string]::Join(",", $MultiModules)

			Write-Verbose -Message $MessageText
            
            :MainLoop ForEach ($Module in $MultiModules) {
                
                $CurrentMultiModule = Get-Module -ListAvailable -Name $Module -Verbose:$false | Sort-Object -Property Version

				$CurrentMultiModuleCount = ($CurrentMultiModule | Measure-Object).Count

				[String]$MessageText = "For the module {0} {1} versions found." -f $Module, $CurrentMultiModuleCount

				Write-Verbose -message $MessageText

				For ($i = 1; $i -lt $CurrentMultiModuleCount; $i++) {

					[Bool]$UninstallOne = $false

					$Older = $CurrentMultiModule[$i - 1]

					If (-not $UninstallForAll -and -not $SkipAll) {

						[String]$title = "Uninstall module"

						[String]$message = "Do you want to uninstall the version {0} of the module {1}?" -f $Older.Version, $Module

						$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
										  "Uninstall the module version."

						$yesAll = New-Object System.Management.Automation.Host.ChoiceDescription "&All", `
											 "Uninstall all older modules versions."

						$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
										 "Retains the module version."

						$noAll = New-Object System.Management.Automation.Host.ChoiceDescription "N&o for All", `
											"Retains the all older modules versions."

						$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $yesAll, $no, $noAll)

						$answer = $host.ui.PromptForChoice($title, $message, $options, 0)

						switch ($answer) {

							0 { $UninstallOne = $true }

							1 { $UninstallForAll = $true }

							2 {

								$ExitCode = 2

							}

							3 {
							
								$SkipAll = $true

								$ExitCode = 3

								Break :MainLoop
							}


						}

					}

					if ($UninstallForAll -or $UninstallOne) {

						[String]$MessageText = "Uninstalling the {0} of the module {1}." -f $Older.Version, $Module

						Write-Verbose -Message $MessageText

						Try {

							Uninstall-Module -Name $Module -MaximumVersion $Older.Version -whatif

							$Results += $Older

						}
						Catch {

							$ExitCode = 1

						}

					}

				}

			}

		}
		Else {

			[String]$MessageText = "Any installed modules don't have older version installed."

			Write-Verbose -Message $MessageText

			[Int]$ExitCode = -1

		}

	}

	End {

		If ($PassThru.IsPresent) {

			Return $Results

		}
		elseif ($ReturnExitCode.IsPresent) {

			Return $ExitCode

		}

	}

}

# Function coppied from PowerShellGet module, author: Microsoft
# Check if current user is running with elevated privileges
function Test-RunningAsElevated {
	[CmdletBinding()]
	[OutputType([bool])]
	Param ()

	$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
	$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
	return $prp.IsInRole($adm)
}
