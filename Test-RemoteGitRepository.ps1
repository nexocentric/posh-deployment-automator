[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [ValidateScript({ $_ -imatch ".*github\.com/[\s\S]*/.*\.git"})]
	[string]$RemoteRepositoryAddress
)
try {
	(New-Object Net.WebClient).DownloadString($RemoteRepositoryAddress) | Out-Null
	return $true
}
catch {
	return $false
}