[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[ValidateScript({(Test-Path $_ )-eq $true})]
	[string]$SearchDirectory
)
$msBuildFileExtensionPattern = "^.*\..*proj$"
Write-Verbose -Message "Recursively Scanning for files matching patten [${msBuildFileExtensionPattern}] in [${SearchDirectory}]"
$repositoryFiles = Get-ChildItem -Path $SearchDirectory -Recurse
$buildFilePath = ""

Write-Verbose -Message ("Checking [" + $repositoryFiles.Length + "] possible files for MSBuild file.")
foreach ($file in $repositoryFiles) {
	Write-Verbose -Message ($file.Name)
	if (($file.Name.ToString() -imatch $msBuildFileExtensionPattern)) {
		Write-Verbose -Message ("Found a match [" + $file.Name + "] with a path of [" + $file.FullName + "].")
		$buildFilePath = $file | Select-Object -ExpandProperty FullName
    	Write-Output -InputObject $buildFilePath
	}
    
}

# H:\repositories\temp-install\auto-deploy-test-0.9.0