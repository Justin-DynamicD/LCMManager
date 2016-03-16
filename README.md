# LCMManager
DSC Module and resources to manage DSC Nodes

LCMUpdate:
This resource allows you to pull LCM configuraiton changes.  Typically this is done with a meta-configuraiton, but those configurations can be pushed only.  This module will take common settings, compare them to the LCM on the node, and dynamically build and push the updated meta-configuration if needed.  This was written with WMF5.0 in mind, so will not function orectly under 4.0.


LCMCertUpdate:
This resource will select a local machine certificate based on the provided filter cirteria then compare the thumbprint to the thumbprint configured in the LocalConfigurationManager.  If the the two do not match, it exports the appropriate certificate to the defined location using the configured format (computername, FQDN, or GUID) to a specified location so it may be used by configurations in future mofs.
