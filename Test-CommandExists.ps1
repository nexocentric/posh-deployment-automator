[CmdletBinding(SupportsShouldProcess=$true)]
param (
	[ValidateNotNullOrEmpty()]
	[parameter(Mandatory=$true)]
	[string]$Command
)

$commandExists = $false

try {
	(&$Command) | Out-Null
	$commandExists = $true
}
catch [Exception] {
	Write-Warning -Message "The [${Command}] command is not available on this system."
}

$noteProperties = @{
	CommandExists = $commandExists;
	CommandName = $command;
}

$commandProperties = New-Object -TypeName PSObject -Property $noteProperties

Write-Output -InputObject $commandProperties