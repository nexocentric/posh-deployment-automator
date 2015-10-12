[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[string]$Path,

	[ValidateNotNullOrEmpty()]
	[switch]$Create = $false
)
if (Test-Path -Path $Path) {
	$parentDirectory = [System.IO.Path]::GetDirectoryName($Path)
	Write-Verbose -Message ("Direct parent directory [${parentDirectory}]")

	$directoryName = [System.IO.Path]::GetFileName($Path)
	Write-Verbose -Message ("Name of directory [${directoryName}]")
	$isDirectory = (Get-ChildItem -Path $parentDirectory -Attributes Directory | Where-Object { $_.Name -eq "${directoryName}"})
	if ($isDirectory.Count) {
		Write-Verbose -Message ("[${Path}] exists and is a directory.")
		return $true
	}
	else {
		Write-Verbose -Message ("[${Path}] exists and is a file.")
	    return $false
	}
}

if (!$Create) {
	return $false
}

Write-Verbose -Message ("[${Path}] Directory does not exist! Creating directory and any needed parents.")
$directoryInformation = New-Item -ItemType Directory -Path $Path

return $true