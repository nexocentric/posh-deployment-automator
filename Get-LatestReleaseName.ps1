# the name of this function should be watch repository
# it should only export the Watch-ContinuouDeploymentRepository function
# 
# 

# goal number one should be to initialize a git repository and then watch it for changes
# initialize-Git
[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[parameter(Mandatory=$true)]
	[ValidateScript({ Test-Path -Path $_ })]
	[string]$RepositoryDirectory
)
$latestRelease = ""
$previousDirectory = (Get-Location).Path

if ($previousDirectory -ne $RepositoryDirectory) {
	Set-Location -Path $RepositoryDirectory
}

git fetch | Out-Null
$changesOnRemote = [string]::IsNullOrEmpty((git diff HEAD origin/master))

Write-Verbose -Message ("Local repository behind remote? [${changesOnRemote}]")

git fetch --tags | Out-Null
$codeReleases = git tag -l --sort=version:refname

if ($codeReleases.Length -gt 1) {
	$latestRelease = $codeReleases[$codeReleases.Length - 1]
} else {
	$latestRelease = $codeReleases
}

Set-Location -Path $previousDirectory

#$codeReleases
Write-Debug -Message ("Let's check this out!")


Write-Output -InputObject $latestRelease