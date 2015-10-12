[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[ValidateScript({(Test-Path $_ )-eq $true})]
	[string]$Directory
)
$msBuildFileExtensionPattern = "^.*\..*proj$"
Write-Verbose -Message "Recursively Scanning for files matching patten [${msBuildFileExtensionPattern}] in [${Directory}]"
$repositoryFiles = Get-ChildItem -Path $Directory -Recurse
$buildFilePath = ""

Write-Verbose -Message ("Checking [" + $repositoryFiles.Length + "] possible files for MSBuild file.")
foreach ($file in $repositoryFiles) {
	Write-Verbose -Message ($file.Name)
	if (($file.Name.ToString() -imatch $msBuildFileExtensionPattern)) {
		Write-Verbose -Message ("Found a match [" + $file.Name + "] with a path of [" + $file.FullName + "].")
		$buildFilePath = $file.FullName.ToString()
	}
}

Write-Output -InputObject $buildFilePath
# H:\repositories\temp-install\auto-deploy-test-0.9.0