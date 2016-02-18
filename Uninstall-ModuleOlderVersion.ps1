Function Uninstall-ModuleOlderVersion {
    
<#
    .SYNOPSIS
    Function intended for uninstalling older versions of functions installed from PowerShell Gallery
   
    .DESCRIPTION
	Function intended for uninstalling older versions of functions installed from PowerShell Gallery what left if Update-Module is used.
	
    .PARAMETER Name
	The name of module what older versions need to be uninstalled. If not provided all modules in scope will be checked.
	
	.PARAMETER Scope
	The scope what will be used for finding/uninstalling. By default the scope
	
	.PARAMETER Path
    
	.INPUT
    
    .OUTPUTS
      
    .EXAMPLE
	
	
     
    .LINK
    https://github.com/it-praktyk/<BASE_REPOSITORY_URL>
    
    .LINK
    https://www.linkedin.com/in/sciesinskiwojciech
          
    .NOTES
    AUTHOR: Wojciech Sciesinski, wojciech[at]sciesinski[dot]net
    KEYWORDS: PowerShell, PowerShell Gallery, 
   
    VERSIONS HISTORY
    - 0.1.0 -  2016-02-18 - The first draft

    TODO
	- update help
	- ask user about unintalling/removing and implement "Force"
	- correctly handle "WhatIf"
	- implement PassThru to return uninstalled modules data
	- implement exist code if not PassThru used
	- check if function is used in elevated PowerShell 
	- implement pipeline for the module name
	- implement support for uninstalling scripts also
	- replace Remove-Item with Uninstall-Module -MinimumVersion
        
    LICENSE
	Copyright (c) 2016 Wojciech Sciesinski
    This function is licensed under The MIT License (MIT)
    Full license text: https://opensource.org/licenses/MIT
	
#>
    
    [CmdletBinding()]
    Param (
        
        #Parameters are not used yet :-)
        
        [Parameter(Mandatory = $false)]
        [String]$Name,
        [Parameter(Mandatory = $false)]
        [ValidateSet("CurrentUser", "AllUsers")]
        [string]$Scope = "AllUsers",
        [Parameter(Mandatory = $false)]
        [String]$Path
        
    )
    
    #region Part of code from PowerShellGet module, author: Microsoft
    
    try {
        $script:MyDocumentsFolderPath = [Environment]::GetFolderPath("MyDocuments")
    }
    catch {
        $script:MyDocumentsFolderPath = $null
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
            
            $Path = $script:ProgramFilesModulesPath
            
        }
        Else {
            
            $script:MyDocumentsModulesPath
            
        }
        
        [String]$MessageText = "Uninstalling older version of module(s) from the path: {0}" -f $Path
        
        Write-verbose -message $MessageText
        
    }
}
Else {
    
    #Add validation of provided path here
    
}

$MultiModules = (Get-Module -Name $Name -ListAvailable -verbose:$false | Where-Object -FilterScript { $_.path -like $Path } | Group-Object -Property Name | Where-Object -FilterScript { $_.count -gt 1 }).name

If ($MultiModules) {
    
    [String]$MessageText = "Older versions for modules: {0} found" -f [string]::Join(",", $MultiModules)
    
    Write-Verbose -Message $MessageText
    
}
Else {
    
    [String]$MessageText = "Any installed modules don't have older version installed."
    
    Write-Verbose -Message $MessageText
    
}

ForEach ($Module in $MultiModules) {
    
    $CurrentMultiModule = Get-Module -ListAvailable -Name $Module -Verbose:$false | Sort-Object -Property Version
    
    $CurrentMultiModuleCount = ($CurrentMultiModule | Measure-Object).Count
    
    [String]$MessageText = "For the module {0} {1} versions found." -f $Module, $CurrentMultiModuleCount
    
    Write-Verbose -message $MessageText
    
    For ($i = 1; $i -lt $CurrentMultiModuleCount; $i++) {
        
        $Older = $CurrentMultiModule[$i - 1]
        
        [String]$MessageText = "For the module {0} the version {1} will be uninstalled." -f $Module, $Older.Version
        
        Write-Verbose -Message $MessageText
        
        $FolderToRemove = ([system.io.fileinfo]$Older.Path).DirectoryName
        
        Remove-Item -Path $FolderToRemove -Force -Recurse -WhatIf
        
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