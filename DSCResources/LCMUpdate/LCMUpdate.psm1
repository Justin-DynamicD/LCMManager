######################################################################################
# The Get-TargetResource cmdlet.
# This function will get the certificate if it exists and return all information
######################################################################################
function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param (
        [parameter(Mandatory = $true)][System.String]$ConfigurationBlock,
        [parameter(Mandatory = $false)][System.String]$ServerURL,
        [parameter(Mandatory = $false)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
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
        ConfigurationRepositoryWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ConfigurationRepositoryWeb]$ConfigurationBlock"}}
        ResourceRepositoryWeb {$CurrentCFG = $LCM.ResourceModuleManagers | where-object {$_.ResourceID -eq "[ResourceRepositoryWeb]$ConfigurationBlock"}}
        ReportServerWeb {$CurrentCFG = $LCM.ReportManagers | where-object {$_.ResourceID -eq "[ReportServerWeb]$ConfigurationBlock"}}
        }

    $ReturnValue = @{
        ConfigurationBlock = $ConfigurationBlock
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
        [parameter(Mandatory = $true)][System.String]$ConfigurationBlock,
        [parameter(Mandatory = $false)][System.String]$ServerURL,
        [parameter(Mandatory = $false)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
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
        [parameter(Mandatory = $true)][System.String]$ConfigurationBlock,
        [parameter(Mandatory = $false)][System.String]$ServerURL,
        [parameter(Mandatory = $false)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
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
        [parameter(Mandatory = $true)][System.String]$ConfigurationBlock,
        [parameter(Mandatory = $false)][System.String]$ServerURL,
        [parameter(Mandatory = $false)][ValidateSet("ConfigurationRepositoryWeb","ResourceRepositoryWeb","ReportServerWeb")][System.String]$ConfigurationType = "ConfigurationRepositoryWeb",
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
        ConfigurationRepositoryWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ConfigurationRepositoryWeb]$ConfigurationBlock"}}
        ResourceRepositoryWeb {$CurrentCFG = $LCM.ResourceModuleManagers | where-object {$_.ResourceID -eq "[ResourceRepositoryWeb]$ConfigurationBlock"}}
        ReportServerWeb {$CurrentCFG = $LCM.ReportManagers | where-object {$_.ResourceID -eq "[ReportServerWeb]$ConfigurationBlock"}}
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
        
        #ID if a SettingsBlock is needed and reformat array
        If ($CertificateEncryptID -or $ConfigurationMode -or $RebootNodeIfNeeded -or $AllowModuleOverwrite -or $RefreshFrequencyMins -or $ConfigurationModeFrequencyMins) {$SettingsBlock=$true}
        If ($ConfigurationNames) {[string]$CFGNames = '@("'+($ConfigurationNames -join '","')+'")'}

        #If Settings block is needed, but this is defined as reporting or resource block, error
        If ($SettingsBlock -and ($ConfigurationType -ne "ConfigurationRepositoryWeb")) {
            write-error "$ConfigurationType was specified, but settings are present that do not apply" -ErrorAction Stop
            }

        #If ConfigurationNames is defined this MUST be a ConfigurationRepositoryWeb block
        If ($ConfigurationNames -and ($ConfigurationType -ne "ConfigurationRepositoryWeb")) {
            write-error "ConfigurationNames was specified, but this is not the ConfigurationRepositoryWeb" -ErrorAction Stop
            }

        #If this is either defined as reporting/resource block, or uses ConfigurationNames, ServerURL becomes required
        If (!$ServerURL -and (($ConfigurationType -ne "ConfigurationRepositoryWeb") -or $ConfigurationNames)) {
            write-error "ServerURL is required unless this is a settings block" -ErrorAction Stop
            }


        #Create a text variable that contains the configuraiton that will be created
        $newline = "`r`n"
        $Text = "[DSCLocalConfigurationManager()]Configuration UpdateLCM {"
        If ($SettingsBlock) {$Text += ($newline + '        Settings {')}
        If ($SettingsBlock -and ($ConfigurationType -eq "ConfigurationRepositoryWeb")) {$Text += ($newline + '             RefreshMode = "Pull"')}
        If ($CertificateEncryptID) {$Text += ($newline + '             CertificateID = "'+$CertificateEncryptID+'"')}
        If ($ConfigurationMode) {$Text += ($newline + '             ConfigurationMode = "'+$ConfigurationMode+'"')}
        If ($RebootNodeIfNeeded) {$Text += ($newline + '             RebootNodeIfNeeded = $'+$RebootNodeIfNeeded)}
        If ($AllowModuleOverwrite) {$Text += ($newline + '             AllowModuleOverwrite = $'+$AllowModuleOverwrite)}
        If ($RefreshFrequencyMins) {$Text += ($newline + '             RefreshFrequencyMins = "'+$RefreshFrequencyMins+'"')}
        If ($ConfigurationModeFrequencyMins) {$Text += ($newline + '             ConfigurationModeFrequencyMins = "'+$ConfigurationModeFrequencyMins+'"')}
        If ($SettingsBlock) {$Text += $newline + '             }'}
        If ($ServerURL) {$Text += ($newline + '        '+$ConfigurationType+' '+$ConfigurationBlock+' {')}
        If ($ServerURL) {$Text += ($newline + '             ServerURL = "'+$ServerURL+'"')}
        If ($CertificateAuthID) {$Text += ($newline + '             CertificateID = "'+$CertificateAuthID+'"')}
        If ($ConfigurationNames) {$Text += ($newline + '             ConfigurationNames = '+$CFGNames)}
        If ($ServerURL) {$Text += $newline + '             }'}
        $Text += $newline + '        }'

        #Create the completed configuration, compile, and set
        write-verbose "applying UpdateLCM by first compiling mof to $env:TEMP\$ConfigurationBlock"
        Invoke-Expression $Text
        UpdateLCM -OutputPath "$env:TEMP\$ConfigurationBlock"
        Set-DscLocalConfigurationManager -Path "$env:TEMP\$ConfigurationBlock\" -Force

        }

    #if apply switch wasn't set, this function is in test mode, return boolean
    ElseIf (!$Apply) {
        Return $TestedOK
        }
}

#  FUNCTIONS TO BE EXPORTED 
Export-ModuleMember -Function *-TargetResource
