# LCMManager
DSC Module and resource to compare configured thumbprint to desired certificate

This module and resource will select a local machine certificate based on the provided filter cirteria then compare the thumbprint to the thumbprint configured in the LocalConfigurationManager.  If the the two do not match, it exports the appropriate certificate to the defined location using the configured format (computername, FQDN, or GUID) to a specified location so it may be used by configurations in future mofs.

Note this merely helps create a complete solution to expiring/renewing certificates.  During the configuration process, the build script should check the same location for certificates to be used when encrypting passwords/mofs.  Including a meta-mof will allow the pull server to specify updated thumbprints as they change.  For helper functions to assit in parsing the resulting SMB share and adding it to your configurationdata, please see the DSCHelperfunctions module
