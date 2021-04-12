function Invoke-AdminCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromRemainingArguments=$true)]
        [String[]] $args
    )
    $currentPwsh = (Get-Process -Id $PID)
    if ($currentPwsh.Name.ToLower() -notin @('pwsh', 'powershell')) { throw "Powershell executable not found." }
    $pwsh = $currentPwsh.Path
    $commands = {$args}.Invoke()
    $commands.Insert(0, '-Command')
    $commands.Add(';')
    $commands.Add('pause;')
    $commands.Add('exit')
    Start-Process $pwsh -Wait -Verb runAs -ArgumentList $commands
}
Export-ModuleMember -Function Invoke-AdminCommand -Alias sudo