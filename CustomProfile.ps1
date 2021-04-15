function Load-Module([string] $name) {
    $path = Join-Path -Path $PSScriptRoot $name
    if (-not [System.IO.File]::Exists($path)) {
        if (-not (Get-Module -ListAvailable -Name $name)) {
            # $name is not installed
            Install-Module $name -Force
        }
        Import-Module $name
    } else {
        Import-Module $path
    }
    Write-Host "`e[0mLoading: `e[38;5;28m$name `e[0m"
}

Load-Module DockerCompletion
Load-Module DockerComposeCompletion
Load-Module posh-git
Load-Module posh-with
Load-Module ZLocation # needs to be loaded after posh-git, because of the prompt shenanigans
Load-Module ./utils.psm1
Load-Module ./sudo.psm1

function prompt {
    try {Update-ZLocation $(Get-PromptPath)} catch {} # a workaround for ZLocation in combination with posh-git
    if ($(git status 2>&1 | Out-Null; $LASTEXITCODE)) {
        return "$(Format-PromptPath($(Get-ShortPath $(Get-PromptPath)))) "
    }
    return & $GitPromptScriptBlock
}

function global:Write-WithPrompt()
{
    param(
        [string]
        $command
    )

    Write-Host -NoNewline "$(prompt)`e[0m`e[38;5;19m `e[38;5;21m$command`e[0m> "
}

$GitPromptSettings.DefaultPromptPath = '$(Get-CustomGitPrompt)'
$GitPromptSettings.TruncatedBranchSuffix = '…'
$GitPromptSettings.BeforeStatus.Text = "["
$GitPromptSettings.AfterStatus.Text = "]"
$GitPromptSettings.PathStatusSeparator.Text = ' '

#"Aliases" 
function up {docker-compose up -d}
function logs {docker-compose logs --follow}
function down {docker-compose down}