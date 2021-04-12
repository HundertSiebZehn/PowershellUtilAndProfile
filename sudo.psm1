function Invoke-AdminCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromRemainingArguments=$true)]
        [String[]] $args
    )
    $currentPwsh = (Get-Process -Id $PID)
    if ($currentPwsh.Name.ToLower() -notin @('pwsh', 'powershell')) { throw "Powershell executable not found." }
    $pwsh = $currentPwsh.Path
    $commands = 
        @('-Command') + 
        @($args) + 
        @(
            ';',
            'pause;',
            'exit'
        )
    Start-Process $pwsh -Wait -Verb runAs -ArgumentList $commands
}
Set-Alias sudo Invoke-AdminCommand
Export-ModuleMember -Function Invoke-AdminCommand -Alias sudo
