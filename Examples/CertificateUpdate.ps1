Configuration CertificateUpdate {

    LCMCertUpdate CertUpdateBase {
        OutPath = $Node.OutPath
        OutputName = "Computer"
        TemplateName = "Lab Computer"
        }

}

$Nodes = @{
    AllNodes = @(
	@{
		PSDscAllowPlainTextPassword=$true
        NodeName = "SCCM01"
		OutPath = '\\DSC-01\CertStore'
        }
	);
   }

#Build Configuration
CertificateUpdate -ConfigurationData $Nodes

#Apply Configuration
Start-DscConfiguration .\CertificateUpdate -wait -verbose

<#
.SUMMARY
This module is designed to compare the configured thumbprint in the LCM to one that 
best matches the filter cireteria provided to the resource in the local computer 
certificate store.  In the event that a "better" certificate is found, the public key 
is copied to the "outpath" configured, so that it can be used by machines that actually 
build the configuration.

.PARAMETERS
OUTPATH = The UNC\FilePath that the "updated cert" will copy to
OUTPUTNAME ("Computer","FQDN","GUID") =  chooses the filename for the certificate file
OUTPATHCredential = Provide crednetials to path incase system account isn't sufficient
TemplateName = filter the available certificates by issued template
CERTNAME = filter the available certificates by Subjectname
SUBJECTALTERNATIVENAME = filter the available certificates by SAN (include "DNS Name=")
EXPIREAFTER = filter by a minimum expiration date

.OTHERNOTES
This resource should be used in tandem with your build process so that certificates can
be identified and updated dynamically as long as the mof generation process is more 
frequent than your certificate generation. By using a predictable 
#>