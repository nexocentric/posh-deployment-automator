[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[ValidateNotNullOrEmpty()]
	[string]$PortableGitReleaseArchive="https://github.com/git-for-windows/git/releases/download/v2.5.3.windows.1/PortableGit-2.5.3-64-bit.7z.exe"
)

$programName = "PortableGit.7z.exe"
$downloadPath = [Environment]::GetFolderPath("ProgramFiles") #put in programs 64
$fullDownloadPath = $downloadPath + "\" + $programName

$gitBinaryPath = ([Environment]::GetFolderPath("ProgramFiles") + "\PortableGit\cmd\git.exe")

if (Test-Path -Path $gitBinaryPath) {
	Write-Verbose -Message "Git already installed!"
	return $gitBinaryPath
}

(New-Object Net.WebClient).DownloadFile(
	$PortableGitReleaseArchive,
	$fullDownloadPath
)
Write-Verbose -Message $fullDownloadPath
#-gm2 means do not show prompts
#-sd1 means delete archive after completed
#-y means hide all dialogs
Start-Process -FilePath $fullDownloadPath -ArgumentList "-y -gm2 -sd1" -Wait
Write-Output -InputObject ([Environment]::GetFolderPath("ProgramFiles") + "\PortableGit\cmd\git.exe")