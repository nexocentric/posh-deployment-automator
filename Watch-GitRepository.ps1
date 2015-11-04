[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[ValidateScript({ (.\Test-RemoteGitRepository -RemoteRepositoryAddress $_) -eq $true })]
	[string]$RemoteRepositoryAddress,

	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[string]$RepositoryDirectory,

	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[string]$InstallDirectory,

	[ValidateNotNullOrEmpty()]
	[ValidateRange(30, 300)]
	[int]$SleepDuration=35,

	[ValidateNotNullOrEmpty()]
	[switch]$CreateDirectories = $false,

	[ValidateNotNullOrEmpty()]
	[switch]$BuildProject = $false,

	[ValidateNotNullOrEmpty()]
	[string]$MSBuildFileName = $null
)

Write-Verbose -Message ("These are the directories for the program.")
Write-Verbose -Message ("Remote repository location [${RemoteRepositoryAddress}]")
Write-Verbose -Message ("Local repository location [${RepositoryDirectory}]")
Write-Verbose -Message ("Install directory [${InstallDirectory}]")

Import-Module -Name ".\Invoke-MsBuild.psm1" -Force

$gitBinaryPath = (.\Get-Git.ps1)
.\Set-GitAlias -Path $gitBinaryPath | Out-Null

#everything below here should be in the loop just in case someone decides to delete something

Write-Debug -Message "Entering loop"
while ($true) {

	#these are directory checks
	$repositoryDirectoryExists = $false
	$installDirectoryExists = $false

	if ($CreateDirectories) {
		$repositoryDirectoryExists = .\New-Directory -Path $RepositoryDirectory -Create
	}
	else {
		$repositoryDirectoryExists = .\New-Directory -Path $RepositoryDirectory
	}

	if ($CreateDirectories) {
		$installDirectoryExists = .\New-Directory -Path $InstallDirectory -Create
	}
	else {
		$installDirectoryExists = .\New-Directory -Path $InstallDirectory
	}

	if (!$repositoryDirectoryExists -and !$installDirectoryExists) {
		return $false
	}

	$repositoryLocation = .\New-GitRepository -WorkingDirectory $RepositoryDirectory -RemoteRepositoryAddress $RemoteRepositoryAddress
	Write-Verbose -Message ("The location for the repository is [${repositoryLocation}]")



	Write-Verbose -Message "Checking for new releases"
	$releaseName = (.\Get-LatestReleaseName -RepositoryDirectory $repositoryLocation)
	Write-Debug -Message "Latest release name is [${releaseName}]"

	if ([string]::IsNullOrEmpty($releaseName)) {
		Write-Debug -Message "No release found!!"
		Start-Sleep -Seconds $SleepDuration
		continue
	}

	$releaseDirectory = .\Install-LatestRelease -RemoteRepositoryAddress $RemoteRepositoryAddress -ReleaseName $releaseName -InstallDirectory $InstallDirectory
	$releaseDirectory = $releaseDirectory[1]
	
	#google figure out a way to continue attempting to run a build
	#if a build fails...
	#specify a flag in Watch-GitRepository called $BuildProject and if it is on try to create the build and notify on failure
	if (![string]::IsNullOrEmpty($releaseDirectory)) {
		Write-Verbose -Message "Installing newest release"
		
		Write-Verbose -Message "Running Find-MsBuildFileForRepository in [${releaseDirectory}]"
		
		# $releaseDirectory

		$msbuildFilePath = .\Find-MsBuildFileForRepository -SearchDirectory $releaseDirectory

		if (![string]::IsNullOrEmpty($MSBuildFileName) -and $msbuildFilePath.Count) {
			foreach ($msbuildFile in $msbuildFilePath) {
				if ($msbuildFile -match $MSBuildFileName) {
					$msbuildFilePath = $msbuildFile
				}
			}
		}
		else {
			# $msbuildFilePath = @(,$msbuildFilePath)[0]
		}

		Write-Verbose -Message "Building using [${msbuildFilePath}]"

		if ($BuildProject -and ![string]::IsNullOrEmpty($msbuildFilePath)) {
			$buildSucceeded = Invoke-MsBuild -Path $msbuildFilePath -BuildLogDirectoryPath $releaseDirectory
			if ($buildSucceeded) {
				Write-Verbose -Message "Build Succeeded run New-InstallSuccessFlag this will put a new markdown file in a location where another program can see the success"
			}
			else {
				Write-Verbose -Message ("Build failed... please check error log...[" + ($msbuildFilePath + ".log") + "]")
			}
		}
	}

	Write-Verbose -Message "Sleeping..."
	Start-Sleep -Seconds $SleepDuration
}