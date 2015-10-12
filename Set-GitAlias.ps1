[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[string]$Path
)

$previousDefinition = ""
if ((Get-Alias | Where-Object {$_.Name -eq "git"}).Count -gt 0) {
	$previousDefinition = (Get-Alias | Where-Object {$_.Name -eq "git"}).Definition
}

Set-Alias -Name git -Value $Path -Scope "Global"

$noteProperties = @{
	CurrentDefinition = $Path;
	PreviousDefinition = $previousDefinition;
}

$aliasProperties = New-Object -TypeName PSObject -Property $noteProperties

Write-Output -InputObject $aliasProperties