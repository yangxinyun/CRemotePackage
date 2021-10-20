Configuration CRemotePackageDSC
{
    param(
        [ValidateSet('Present', 'Absent')] 
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()] 
        [string]
        $Name,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()] 
        [string]
        $Path,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()] 
        [string]
        $ProductId,

        [Parameter()]
        [System.String]
        $Arguments = '/q',
        
        [Parameter()]
        [Hashtable[]]
        $Headers,
        
        [Parameter()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $Proxy,

        [Parameter()]
        [System.Management.Automation.Credential()]
        [System.Management.Automation.PSCredential]
        $ProxyCredential,

        [Parameter()]
        [System.Boolean]
        $MatchSource = $true,

        [Parameter()]
        [System.Uint32]
        $TimeoutSec
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    $localPath = $Path
    If ($Path.StartsWith('http') -and ($Ensure -eq 'Present'))
    {
        $installerName = Split-Path $Path -Leaf

        if ($Headers)
        {
            xRemoteFile DownloadRemotePackage
            {
                DestinationPath = "$env:TEMP\$installerName"
                Uri             = $Path
                Headers         = $Headers
                MatchSource     = $MatchSource
                TimeoutSec      = $TimeoutSec
            }
        }
        else
        {
            xRemoteFile DownloadRemotePackage
            {
                DestinationPath = "$env:TEMP\$installerName"
                Uri             = $Path
                MatchSource     = $MatchSource
                TimeoutSec      = $TimeoutSec
            }
        }

        $localPath = "$env:TEMP\$installerName"
    }

    xPackage InstallPackage
    {
        Ensure    = $Ensure
        Name      = $Name
        Path      = $localPath
        ProductId = $ProductId
        Arguments = "$Arguments"
    }
}