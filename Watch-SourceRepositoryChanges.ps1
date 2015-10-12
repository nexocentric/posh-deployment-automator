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
	[string]$WorkingDirectory,

	[parameter(Mandatory=$true)]
	[string]$RemoteRepositoryAddress
)

# Write-Verbose -Message "This is a stub"
# Test-Connection -ComputerName "https://ddzakuma.visualstudio.com/DefaultCollection/_git/powershell-pull-git-repository-updates"

# git config --global credential.helper wincred
# $information = git ls-remote $RepositoryAddress
$currentDirectory = (Get-Location).Path

if ($currentDirectory -ne $WorkingDirectory) {
	# we need to set the working directory for usage
}

Write-Verbose -Message (Set-Location -Path $WorkingDirectory -PassThru)

$repositoryName = Split-Path -Path $RemoteRepositoryAddress -Leaf

if (!(Test-Path ($WorkingDirectory + "\" + $repositoryName)))
{
	Write-Verbose -Message "Attempting to create a new folder for the repository"
	New-Item -Name $repositoryName -ItemType Directory -Path $WorkingDirectory
}

Write-Verbose -Message (Set-Location -Path ($WorkingDirectory + "\" + $repositoryName) -PassThru)

$currentStatus = git status # i want to change the to --porcelain, but when I do it stops working because it returns null
if ($currentStatus -eq $null)
{
	git init
	git remote add origin $RemoteRepositoryAddress
	git remote -v
	git pull origin master
	# $repositoryName
}

git fetch --tags
$remoteTagList = git tag -l
if ($remoteTagList.IndexOf("new tag"))
{
	$newestTag = $remoteTagList -split ("`n")
	$changesToPull = $newestTag[$newestTag.Length - 1]
	Write-Verbose -Message $changesToPull
	git pull origin master
	git archive master --format=zip --output "archive-${changesToPull}.zip"
}


https://github.com/dahlbyk/posh-git.git