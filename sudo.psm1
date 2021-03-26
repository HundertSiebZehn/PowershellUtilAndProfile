function sudo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromRemainingArguments=$true)]
        [String[]] $args
    )
    Start-Process pwsh -Wait -Verb runAs -ArgumentList "-Command $($args); pause; exit"
    #Start-Process powershell -Wait -Verb runAs -ArgumentList "-Command $($args); pause; exit" for older powershell verisons
}
Export-ModuleMember -Function sudo