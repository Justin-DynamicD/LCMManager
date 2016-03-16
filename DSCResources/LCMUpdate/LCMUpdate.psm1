######################################################################################
# The Get-TargetResource cmdlet.
# This function will get the certificate if it exists and return all information
######################################################################################
function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param (
        [parameter(Mandatory = $true)][System.String]$ConfigurationName,
        [parameter(Mandatory = $true)][System.String]$ServerURL,
        [parameter(Mandatory = $False)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
        [parameter(Mandatory = $false)][System.String]$CertificateEncryptID,
        [parameter(Mandatory = $false)][System.String]$CertificateAuthID,
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ConfigurationMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins
	   )
    
    $LCM = Get-DscLocalConfigurationManager
    switch ($ConfigurationType) {
        ConfigurationRepositoryWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ConfigurationRepositoryWeb]$ConfigurationName"}}
        ResourceRepositoryWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ResourceRepositoryWeb]$ConfigurationName"}}
        ReportServerWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ConfigurationRepositoryWeb]$ConfigurationName"}}
        }

    $ReturnValue = @{
        ConfigurationName = $ConfigurationName
        ServerURL = $CurrentCFG.ServerURL
        ConfigurationType = $ConfigurationType
        CertificateEncryptID = $LCM.CertificateID
        CertificateAuthID = $CurrentCFG.CertificateID
        ConfigurationMode = $LCM.ConfigurationMode
        ConfigurationNames = $CurrentCFG.ConfigurationNames
        RebootNodeIfNeeded = $LCM.RebootNodeIfNeeded
        AllowModuleOverwrite = $LCM.AllowModuleOverwrite
        RefreshFrequencyMins = $LCM.RefreshFrequencyMins
        ConfigurationModeFrequencyMins = $LCM.ConfigurationModeFrequencyMins
        ConfigurationID = $LCM.ConfigurationID
        AgentID = $LCM.AgentId
        }

    Return $ReturnValue
}

######################################################################################
# The Set-TargetResource cmdlet.
# This function will pass the "apply" switch back to the validate function
######################################################################################
function Set-TargetResource
{
	[CmdletBinding()]
	param (
        [parameter(Mandatory = $true)][System.String]$ConfigurationName,
        [parameter(Mandatory = $true)][System.String]$ServerURL,
        [parameter(Mandatory = $False)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
        [parameter(Mandatory = $false)][System.String]$CertificateEncryptID,
        [parameter(Mandatory = $false)][System.String]$CertificateAuthID,
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ConfigurationMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins
	   )

    ValidateProperties @PSBoundParameters -Apply
}

######################################################################################
# The Test-TargetResource cmdlet.
# This function will only return a $true $false on compliance
######################################################################################
function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param (
        [parameter(Mandatory = $true)][System.String]$ConfigurationName,
        [parameter(Mandatory = $true)][System.String]$ServerURL,
        [parameter(Mandatory = $False)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
        [parameter(Mandatory = $false)][System.String]$CertificateEncryptID,
        [parameter(Mandatory = $false)][System.String]$CertificateAuthID,
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ConfigurationMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins
	   )

ValidateProperties @PSBoundParameters
}


######################################################################################
# The ValidateProperties cmdlet.
# This function accepts an -apply flag and "does the work"
######################################################################################
function ValidateProperties
{
    param (
        [parameter(Mandatory = $true)][System.String]$ConfigurationName,
        [parameter(Mandatory = $true)][System.String]$ServerURL,
        [parameter(Mandatory = $False)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
        [parameter(Mandatory = $false)][System.String]$CertificateEncryptID,
        [parameter(Mandatory = $false)][System.String]$CertificateAuthID,
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ConfigurationMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins,
        [parameter(Mandatory = $false)][switch]$Apply
	   )

    #Start by Assuming all settings are valid and no changes need to be done
    [boolean]$SettingsBlock=$false
    [boolean]$TestedOK=$true

    #Gather Settings into a hashtable for comparison then update "TestedOK" as needed
    $LCM = Get-DscLocalConfigurationManager
    switch ($ConfigurationType) {
        ConfigurationRepositoryWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ConfigurationRepositoryWeb]$ConfigurationName"}}
        ResourceRepositoryWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ResourceRepositoryWeb]$ConfigurationName"}}
        ReportServerWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ConfigurationRepositoryWeb]$ConfigurationName"}}
        }

    $ExistingValues = @{
        ServerURL = $CurrentCFG.ServerURL
        CertificateEncryptID = $LCM.CertificateID
        CertificateAuthID = $CurrentCFG.CertificateID
        ConfigurationMode = $LCM.ConfigurationMode
        ConfigurationNames = $CurrentCFG.ConfigurationNames
        RebootNodeIfNeeded = $LCM.RebootNodeIfNeeded
        AllowModuleOverwrite = $LCM.AllowModuleOverwrite
        RefreshFrequencyMins = $LCM.RefreshFrequencyMins
        ConfigurationModeFrequencyMins = $LCM.ConfigurationModeFrequencyMins
        }

    If (!$CurrentCFG) {$TestedOK = $false}
    If (($ExistingValues.ServerURL -ne $ServerURL) -and $ServerURL) {$TestedOK = $false}
    If (($ExistingValues.CertificateEncryptID -ne $CertificateEncryptID) -and $CertificateEncryptID) {$TestedOK = $false}
    If (($ExistingValues.CertificateAuthID -ne $CertificateAuthID) -and $CertificateAuthID) {$TestedOK = $false}
    If (($ExistingValues.ConfigurationMode -ne $ConfigurationMode) -and $ConfigurationMode) {$TestedOK = $false}
    If (($ExistingValues.ConfigurationNames -ne $ConfigurationNames) -and $ConfigurationNames) {$TestedOK = $false}
    If (($ExistingValues.RebootNodeIfNeeded -ne $RebootNodeIfNeeded) -and $RebootNodeIfNeeded) {$TestedOK = $false}
    If (($ExistingValues.AllowModuleOverwrite -ne $AllowModuleOverwrite) -and $AllowModuleOverwrite) {$TestedOK = $false}
    If (($ExistingValues.RefreshFrequencyMins -ne $RefreshFrequencyMins) -and $RefreshFrequencyMins) {$TestedOK = $false}
    If (($ExistingValues.ConfigurationModeFrequencyMins -ne $ConfigurationModeFrequencyMins) -and $ConfigurationModeFrequencyMins) {$TestedOK = $false}

    #Make the changes if switch is set and changes detected
    If ($Apply -and ($TestedOK -eq $false)) {
        Write-Verbose "The changes detected between LCM and desired state, generating new meta-config"
        
        #store a variable for the enter key, then ID if a SettingsBLock is needed
        $newline = "`r`n"
        If ($CertificateEncryptID -or $ConfigurationMode -or $RebootNodeIfNeeded -or $AllowModuleOverwrite -or $RefreshFrequencyMins -or $ConfigurationModeFrequencyMins) {$SettingsBlock=$true}
        If ($ConfigurationNames) {[string]$CFGNames = '@("'+($ConfigurationNames -join '","')+'")'}

        #Create a text variable that contains the configuraiton that will be created
        $Text = "[DSCLocalConfigurationManager()]Configuration UpdateLCM {"
        If ($SettingsBlock) {$Text += ($newline + '        Settings {')}
        If ($SettingsBlock -and ($ConfigurationType -eq "ConfigurationRepositoryWeb")) {$Text += ($newline + '             RefreshMode = "Pull"')}
        If ($CertificateEncryptID) {$Text += ($newline + '             CertificateID = "'+$CertificateEncryptID+'"')}
        If ($ConfigurationMode) {$Text += ($newline + '             ConfigurationMode = "'+$ConfigurationMode+'"')}
        If ($RebootNodeIfNeeded) {$Text += ($newline + '             RebootNodeIfNeeded = "'+$RebootNodeIfNeeded+'"')}
        If ($AllowModuleOverwrite) {$Text += ($newline + '             AllowModuleOverwrite = "'+$AllowModuleOverwrite+'"')}
        If ($RefreshFrequencyMins) {$Text += ($newline + '             RefreshFrequencyMins = "'+$RefreshFrequencyMins+'"')}
        If ($ConfigurationModeFrequencyMins) {$Text += ($newline + '             ConfigurationModeFrequencyMins = "'+$ConfigurationModeFrequencyMins+'"')}
        If ($SettingsBlock) {$Text += $newline + '             }'}
        $Text += ($newline + '        '+$ConfigurationType+' '+$ConfigurationName+' {')
        $Text += ($newline + '             ServerURL = "'+$ServerURL+'"')
        If ($CertificateAuthID) {$Text += ($newline + '             CertificateID = "'+$CertificateAuthID+'"')}
        If ($ConfigurationNames) {$Text += ($newline + '             ConfigurationNames = '+$CFGNames)}
        $Text += $newline + '             }'
        $Text += $newline + '        }'

        #Create the completed configuration, compile, and set
        write-verbose "applying UpdateLCM by first compiling mof to $env:TEMP\$ConfigurationName"
        Invoke-Expression $Text
        UpdateLCM -OutputPath "$env:TEMP\$ConfigurationName"
        Set-DscLocalConfigurationManager -Path "$env:TEMP\$ConfigurationName\"

        }

    #if apply switch wasn't set, this function is in test mode, return boolean
    ElseIf (!$Apply) {
        Return $TestedOK
        }
}

#  FUNCTIONS TO BE EXPORTED 
Export-ModuleMember -Function *-TargetResource
