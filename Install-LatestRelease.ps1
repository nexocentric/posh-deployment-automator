[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[parameter(Mandatory=$true)]
	[ValidateScript({ (.\Test-RemoteGitRepository -RemoteRepositoryAddress $_) -eq $true })]
	[string]$RemoteRepositoryAddress,

	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
	[string]$ReleaseName,

	[parameter(Mandatory=$true)]
	[ValidateScript({ Test-Path -LiteralPath $_ })]
	[string]$InstallDirectory
)

$repositoryName = [System.IO.Path]::GetFileNameWithoutExtension($RemoteRepositoryAddress)
$repositoryName = $repositoryName.Replace(".git", "")
$installedFolder = $repositoryName + "-" + $ReleaseName.Replace("v", "")
Write-Verbose -Message "Installed in [${installedFolder}]"

if (Test-Path -Path ($InstallDirectory + "\" + $installedFolder)) {
	return ""
}
$previousLocation = (Get-Location).Path


$fileName = $ReleaseName + ".zip"
$releaseArchiveAddress =  ($RemoteRepositoryAddress.Replace(".git", "")) + "/archive/" + $fileName
Write-Verbose -Message ("Preparing to download the following archive [${releaseArchiveAddress}].")

$fullFileName = ($InstallDirectory + "\" + $fileName)
Write-Verbose -Message ("Attempting to download file to the following location [${fullFileName}].")

(New-Object Net.WebClient).DownloadFile(
	$releaseArchiveAddress,
	$fullFileName #full file path required!
) | Out-Null

Set-Location -Path $InstallDirectory
$shell = new-object -com shell.application
$zip = $shell.NameSpace($fullFileName)
foreach($item in $zip.items())
{
	$shell.Namespace($fullFileName.Replace(".zip", "").Replace($ReleaseName, "")).copyhere($item)
}

Remove-Item -Path $fullFileName
Set-Location -Path $previousLocation
Join-Path -Path $InstallDirectory -ChildPath $installedFolder
# return ($InstallDirectory + "\" + $installedFolder)

# VERBOSE: Installed in [auto-deploy-test-0.7.0]
# VERBOSE: Preparing to download the following archive
# [https://github.com/nexocentric/auto-deploy-test/archive/v0.7.0.zip].
