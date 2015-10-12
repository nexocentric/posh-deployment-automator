[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[parameter(Mandatory=$true)]
	[ValidateScript({ Test-Path -Path $_ })]
	[string]$WorkingDirectory,

	[parameter(Mandatory=$true)]
	[ValidateScript({ (.\Test-RemoteGitRepository -RemoteRepositoryAddress $_) -eq $true })]
	[string]$RemoteRepositoryAddress
)
$repositoryLocation = ""
$lastLocation = (Get-Location).Path

if ($lastLocation -ne $WorkingDirectory) {
	Write-Debug -Message "Changing directories to [${WorkingDirectory}] for git repository."
	Set-Location -Path $WorkingDirectory
}

$folderName = [System.IO.Path]::GetFileNameWithoutExtension($RemoteRepositoryAddress)
if (Test-Path -Path (".\" + $folderName)) {
	Set-Location -Path (".\" + $folderName)
}

$currentStatus = git status # i want to change the to --porcelain, but when I do it stops working because it returns null
if ($currentStatus -eq $null)
{
	Write-Debug -Message "Cloning the [${RemoteRepositoryAddress}] repository."
	git clone $RemoteRepositoryAddress | Out-Null #you might need to save this information later
	Write-Debug -Message "Repository resides in a folder named [${folderName}]"
	
	Write-Debug -Message "Entering folder for checks [${folderName}]."
	Set-Location -Path $folderName
	git remote -v | Out-Null #you might need to save this information later
	git pull origin master | Out-Null #you might need to save this information later
}
$repositoryLocation = (Get-Location).Path

Set-Location -Path $lastLocation
Write-Output -InputObject $repositoryLocation