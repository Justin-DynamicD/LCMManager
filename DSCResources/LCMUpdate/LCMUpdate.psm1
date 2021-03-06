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
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ActionAfterReboot,
        [parameter(Mandatory = $false)][ValidateSet("None","ForceModuleImport","All")][System.String]$DebugMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$StatusRetentionTimeInDays
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
        ActionAfterReboot = $LCM.ActionAfterReboot
        DebugMode = ([string]$LCM.DebugMode)
        ConfigurationNames = $CurrentCFG.ConfigurationNames
        RebootNodeIfNeeded = $LCM.RebootNodeIfNeeded
        AllowModuleOverwrite = $LCM.AllowModuleOverwrite
        RefreshFrequencyMins = $LCM.RefreshFrequencyMins
        ConfigurationModeFrequencyMins = $LCM.ConfigurationModeFrequencyMins
        StatusRetentionTimeInDays = $LCM.StatusRetentionTimeInDays
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
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ActionAfterReboot,
        [parameter(Mandatory = $false)][ValidateSet("None","ForceModuleImport","All")][System.String]$DebugMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$StatusRetentionTimeInDays
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
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ActionAfterReboot,
        [parameter(Mandatory = $false)][ValidateSet("None","ForceModuleImport","All")][System.String]$DebugMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$StatusRetentionTimeInDays
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
        [parameter(Mandatory = $false)][ValidateSet("ApplyOnly","ApplyAndMonitor","ApplyAndAutoCorrect")][System.String]$ActionAfterReboot,
        [parameter(Mandatory = $false)][ValidateSet("None","ForceModuleImport","All")][System.String]$DebugMode,
        [parameter(Mandatory = $false)][System.Array]$ConfigurationNames,
        [parameter(Mandatory = $false)][System.Boolean]$RebootNodeIfNeeded,
        [parameter(Mandatory = $false)][System.Boolean]$AllowModuleOverwrite,
        [parameter(Mandatory = $false)][System.UInt32]$RefreshFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$ConfigurationModeFrequencyMins,
        [parameter(Mandatory = $false)][System.UInt32]$StatusRetentionTimeInDays,
        [parameter(Mandatory = $false)][switch]$Apply
	   )

    #Start by Assuming all settings are valid and no changes need to be done
    [boolean]$TestedOK=$true

    #Gather Settings into a hashtable for comparison then update "TestedOK" as needed
    $LCM = Get-DscLocalConfigurationManager
    switch ($ConfigurationType) {
        ConfigurationRepositoryWeb {$CurrentCFG = $LCM.ConfigurationDownloadManagers | where-object {$_.ResourceID -eq "[ConfigurationRepositoryWeb]$ConfigurationBlock"}}
        ResourceRepositoryWeb {$CurrentCFG = $LCM.ResourceModuleManagers | where-object {$_.ResourceID -eq "[ResourceRepositoryWeb]$ConfigurationBlock"}}
        ReportServerWeb {$CurrentCFG = $LCM.ReportManagers | where-object {$_.ResourceID -eq "[ReportServerWeb]$ConfigurationBlock"}}
        }

    $ExistingValues = @{
        ResourceID = "["+$ConfigurationType+"]"+$ConfigurationBlock
        ServerURL = $CurrentCFG.ServerURL
        CertificateEncryptID = $LCM.CertificateID
        CertificateAuthID = $CurrentCFG.CertificateID
        ConfigurationMode = $LCM.ConfigurationMode
        ActionAfterReboot = $LCM.ActionAfterReboot
        DebugMode = ([string]$LCM.DebugMode)
        ConfigurationNames = $CurrentCFG.ConfigurationNames
        RebootNodeIfNeeded = $LCM.RebootNodeIfNeeded
        AllowModuleOverwrite = $LCM.AllowModuleOverwrite
        RefreshFrequencyMins = $LCM.RefreshFrequencyMins
        ConfigurationModeFrequencyMins = $LCM.ConfigurationModeFrequencyMins
        StatusRetentionTimeInDays = $LCM.StatusRetentionTimeInDays
        ConfigurationID = $LCM.ConfigurationID
        }

    If (!$CurrentCFG) {$TestedOK = $false}
    If (($ExistingValues.ServerURL -ne $ServerURL) -and $ServerURL) {$TestedOK = $false}
    If (($ExistingValues.CertificateEncryptID -ne $CertificateEncryptID) -and $CertificateEncryptID) {$TestedOK = $false}
    If (($ExistingValues.CertificateAuthID -ne $CertificateAuthID) -and $CertificateAuthID) {$TestedOK = $false}
    If (($ExistingValues.ConfigurationMode -ne $ConfigurationMode) -and $ConfigurationMode) {$TestedOK = $false}
    If (($ExistingValues.ActionAfterReboot -ne $ActionAfterReboot) -and $ActionAfterReboot) {$TestedOK = $false}
    If (($ExistingValues.DebugMode -ne $DebugMode) -and $DebugMode) {$TestedOK = $false}
    If (($ExistingValues.ConfigurationNames -ne $ConfigurationNames) -and $ConfigurationNames) {$TestedOK = $false}
    If (($ExistingValues.RebootNodeIfNeeded -ne $RebootNodeIfNeeded) -and $RebootNodeIfNeeded) {$TestedOK = $false}
    If (($ExistingValues.AllowModuleOverwrite -ne $AllowModuleOverwrite) -and $AllowModuleOverwrite) {$TestedOK = $false}
    If (($ExistingValues.RefreshFrequencyMins -ne $RefreshFrequencyMins) -and $RefreshFrequencyMins) {$TestedOK = $false}
    If (($ExistingValues.ConfigurationModeFrequencyMins -ne $ConfigurationModeFrequencyMins) -and $ConfigurationModeFrequencyMins) {$TestedOK = $false}
    If (($ExistingValues.StatusRetentionTimeInDays -ne $StatusRetentionTimeInDays) -and $StatusRetentionTimeInDays) {$TestedOK = $false}

    #Make the changes if switch is set and changes detected
    If ($Apply -and ($TestedOK -eq $false)) {
        Write-Verbose "The changes detected between LCM and desired state, generating new meta-config"
        
        #Build a final list for the settings block
        $LCMSettings = @{
            ConfigurationID = $ExistingValues.ConfigurationID
            CertificateEncryptID = If ($CertificateEncryptID) {$CertificateEncryptID} Else {$ExistingValues.CertificateEncryptID}
            ConfigurationMode = If ($ConfigurationMode) {$ConfigurationMode} Else {$ExistingValues.ConfigurationMode}
            ActionAfterReboot = If ($ActionAfterReboot) {$ActionAfterReboot} Else {$ExistingValues.ActionAfterReboot}
            DebugMode = If ($DebugMode) {$DebugMode} Else {$ExistingValues.DebugMode}
            RebootNodeIfNeeded = If ($RebootNodeIfNeeded) {$RebootNodeIfNeeded} Else {$ExistingValues.RebootNodeIfNeeded}
            AllowModuleOverwrite = If ($AllowModuleOverwrite) {$AllowModuleOverwrite} Else {$ExistingValues.AllowModuleOverwrite}
            RefreshFrequencyMins = If ($RefreshFrequencyMins) {$RefreshFrequencyMins} Else {$ExistingValues.RefreshFrequencyMins}
            ConfigurationModeFrequencyMins = If ($ConfigurationModeFrequencyMins) {$ConfigurationModeFrequencyMins} Else {$ExistingValues.ConfigurationModeFrequencyMins}
            StatusRetentionTimeInDays = If ($StatusRetentionTimeInDays) {$StatusRetentionTimeInDays} Else {$ExistingValues.StatusRetentionTimeInDays}
            }
        

        


        #Format and compile the arraylist of configuration blocks
        If ($ConfigurationNames -and $ConfigurationType -ne "ConfigurationRepositoryWeb") {
            write-error "ConfigurationNames can only be used in a ConfigurationRepositoryWeb block" -ErrorAction Stop
            }
        [System.Collections.ArrayList]$LCMConfigArray = $LCM.ConfigurationDownloadManagers
        [System.Collections.ArrayList]$LCMResourceArray = $LCM.ResourceModuleManagers
        [System.Collections.ArrayList]$LCMReportArray = $LCM.ReportManagers
        switch ($ConfigurationType) {
            ConfigurationRepositoryWeb {[System.Collections.ArrayList]$LCMtoUpdate = $LCMConfigArray}
            ResourceRepositoryWeb {[System.Collections.ArrayList]$LCMtoUpdate = $LCMResourceArray}
            ReportServerWeb {[System.Collections.ArrayList]$LCMtoUpdate = $LCMReportArray}
            }

        $LCMtoUpdate | Where-Object {$_.ResourceID -eq "[$ConfigurationType]$ConfigurationBlock"} | ForEach {
            #Object Found, needs to be updated
            If ($ServerURL) {$_.ServerURL = $ServerURL}
            If ($ConfigurationNames) {$_.ConfigurationNames = $ConfigurationNames}
            If ($CertificateAuthID) {$_.CertificateID = $CertificateAuthID}
            }
        If ($LCMtoUpdate.ResourceID -notcontains "[$ConfigurationType]$ConfigurationBlock") {
            #Object missing, create a new one and add it
            $newentry = new-object PSObject
            $newentry | Add-Member -Type NoteProperty -Name ResourceId -Value "[$ConfigurationType]$ConfigurationBlock"
            If ($CertificateAuthID) {$newentry | Add-Member -Type NoteProperty -Name CertificateID -Value $CertificateAuthID}
            If ($ConfigurationNames) {$newentry | Add-Member -Type NoteProperty -Name ConfigurationNames -Value $ConfigurationNames}
            If ($ServerURL) {$newentry | Add-Member -Type NoteProperty -Name ServerURL -Value $ServerURL}
            $LCMtoUpdate.add($newentry) | Out-Null
            }

        #Write changes back to original array
        switch ($ConfigurationType) {
            ConfigurationRepositoryWeb {[System.Collections.ArrayList]$LCMConfigArray = $LCMtoUpdate}
            ResourceRepositoryWeb {[System.Collections.ArrayList]$LCMResourceArray = $LCMtoUpdate}
            ReportServerWeb {[System.Collections.ArrayList]$LCMReportArray = $LCMtoUpdate}
            }

        #Create a text variable that contains the configuraiton that will be created
        $newline = "`r`n"
        $Text = "[DSCLocalConfigurationManager()]Configuration UpdateLCM {"
        $Text += ($newline + '        Settings {')
        $Text += ($newline + '             RefreshMode = "Pull"')
        If ($LCMSettings.ConfigurationID) {$Text += ($newline + '             ConfigurationID = "'+$LCMSettings.ConfigurationID+'"')}
        If ($LCMSettings.CertificateEncryptID) {$Text += ($newline + '             CertificateID = "'+$LCMSettings.CertificateEncryptID+'"')}
        If ($LCMSettings.ConfigurationMode) {$Text += ($newline + '             ConfigurationMode = "'+$LCMSettings.ConfigurationMode+'"')}
        If ($LCMSettings.ActionAfterReboot) {$Text += ($newline + '             ActionAfterReboot = "'+$LCMSettings.ActionAfterReboot+'"')}
        If ($LCMSettings.DebugMode) {$Text += ($newline + '             DebugMode = "'+$LCMSettings.DebugMode+'"')}
        If ($LCMSettings.RebootNodeIfNeeded) {$Text += ($newline + '             RebootNodeIfNeeded = $'+$LCMSettings.RebootNodeIfNeeded)}
        If ($LCMSettings.AllowModuleOverwrite) {$Text += ($newline + '             AllowModuleOverwrite = $'+$LCMSettings.AllowModuleOverwrite)}
        If ($LCMSettings.RefreshFrequencyMins) {$Text += ($newline + '             RefreshFrequencyMins = "'+$LCMSettings.RefreshFrequencyMins+'"')}
        If ($LCMSettings.ConfigurationModeFrequencyMins) {$Text += ($newline + '             ConfigurationModeFrequencyMins = "'+$LCMSettings.ConfigurationModeFrequencyMins+'"')}
        If ($LCMSettings.StatusRetentionTimeInDays) {$Text += ($newline + '             StatusRetentionTimeInDays = "'+$LCMSettings.StatusRetentionTimeInDays+'"')}
        $Text += $newline + '             }'

        #Add ConfigurationRepositoryWeb
        ForEach ($entry in $LCMConfigArray) {
            If ($entry.ConfigurationNames) {[string]$CFGNames = '@("'+($entry.ConfigurationNames -join '","')+'")'}
            $Text += ($newline + '        ConfigurationRepositoryWeb '+($entry.ResourceID -split "]")[1]+' {')
            If ($entry.ServerURL) {$Text += ($newline + '             ServerURL = "'+$entry.ServerURL+'"')}
            If ($entry.AllowUnsecureConnection) {$Text += ($newline + '             ServerURL = $'+$entry.AllowUnsecureConnection)}
            If ($entry.CertificateID) {$Text += ($newline + '             CertificateID = "'+$entry.CertificateID+'"')}
            If ($entry.ConfigurationNames) {$Text += ($newline + '             ConfigurationNames = '+$CFGNames)}
            $Text += $newline + '             }'
            }

        #Add ResourceWeb
        ForEach ($entry in $LCMResourceArray) {
            $Text += ($newline + '        ConfigurationResourceWeb '+($entry.ResourceID -split "]")[1]+' {')
            If ($entry.ServerURL) {$Text += ($newline + '             ServerURL = "'+$entry.ServerURL+'"')}
            If ($entry.AllowUnsecureConnection) {$Text += ($newline + '             ServerURL = $'+$entry.AllowUnsecureConnection)}
            If ($entry.CertificateID) {$Text += ($newline + '             CertificateID = "'+$entry.CertificateID+'"')}
            $Text += $newline + '             }'
            }

        #Add ReportWeb
        ForEach ($entry in $LCMReportArray) {
            $Text += ($newline + '        ReportServerWeb '+($entry.ResourceID -split "]")[1]+' {')
            If ($entry.ServerURL) {$Text += ($newline + '             ServerURL = "'+$entry.ServerURL+'"')}
            If ($entry.AllowUnsecureConnection) {$Text += ($newline + '             ServerURL = $'+$entry.AllowUnsecureConnection)}
            If ($entry.CertificateID) {$Text += ($newline + '             CertificateID = "'+$entry.CertificateID+'"')}
            $Text += $newline + '             }'
            }

        #Close the config block
        $Text += $newline + '        }'

        #Create the completed configuration, compile, and set
        out-file -FilePath C:\test\dump.txt -Encoding string -InputObject $Text
        write-verbose "applying UpdateLCM by first compiling mof to $env:TEMP\$ConfigurationBlock"
        Invoke-Expression $Text
        UpdateLCM -OutputPath "C:\Test\$ConfigurationBlock"
        Set-DscLocalConfigurationManager -Path "C:\Test\$ConfigurationBlock\" -Force

        }#End Apply phase

    #if apply switch wasn't set, this function is in test mode, return boolean
    ElseIf (!$Apply) {
        Return $TestedOK
        }
}

#  FUNCTIONS TO BE EXPORTED 
Export-ModuleMember -Function *-TargetResource
