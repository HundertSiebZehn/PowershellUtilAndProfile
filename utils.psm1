function Get-ShortPath ([string] $path, [int] $limit = 2, [string] $ellipses = '…') {
    [string[]] $elems = $path -split '\\' | Select-String .+ -Raw
    if ($limit -ge $elems.Count) {
        return $elems -join '\'
    }
    $ret = $ellipses + '\'
    $ret += $elems[-$limit..-1] -join '\'
    return $ret;
}
function Format-PromptPath([string] $path) {
    $reset = "`e[0m"
    $fg = "`e[38;5;{0}m"
    #$bg = "`e[48;5;{0}m"
    return @(
        $reset,
        ($fg -f 220),
        '  ',
        ($fg -f 20),
        '[',
        $reset,
        $path,
        ($fg -f 20),
        ']',
        $reset
    ) -join ''
}

function Get-CustomGitPrompt {
    if (-not $(Test-Git $(Get-PromptPath))) {
        # not a git repo … return default prompt
        return Get-CustomPrompt
    }
    $rootPath = ($(git rev-parse --show-toplevel).replace("/", "\"))
    $root = Get-GitRootName $rootPath
    $path = ($(Get-PromptPath).replace($rootPath, ""))
    if ($path -eq "") {
        return Format-PromptPath($root)
    }
    return Format-PromptPath($root + "\" + $(Get-ShortPath($path)))
}

function Test-Git {
    Param (
        [Parameter(Mandatory=$True)]
        [String]$Path
    )
    if ([System.IO.Path]::IsPathRooted($Path)) {
        # absolute path
        $Path = $(Join-Path -ErrorAction SilentlyContinue $Path "/.git" -Resolve)
    } else {
        $Path = $(Join-Path -ErrorAction SilentlyContinue $PWD $Path "/.git" -Resolve)
    }
    return [System.Boolean] $(Test-Path -ErrorAction SilentlyContinue -Path $Path)
}

function Get-GitRootName([string] $path) {
    if (-not $(Test-Git $path)) {
        return ""
    }
    Write-Host $path
    $rootPath = $(git -C $path rev-parse --show-toplevel).replace("/", "\")
    Write-Host $rootPath
    $root = $(Split-Path -Leaf $rootPath)
    Write-Host $root
    $parentPath = $(Join-Path -ErrorAction SilentlyContinue $rootPath ".." -Resolve)
    Write-Host $parentPath
    if ($(Test-Git $parentPath)) {
        Write-Host "recursive call"
        return $(Get-GitRootName $parentPath) + " »  $root"
    }
    return " $root"
}

function Get-CustomPrompt {
    return "$(Format-PromptPath($(Get-ShortPath $(Get-PromptPath)))) "
}

Export-ModuleMember -Function Get-ShortPath
Export-ModuleMember -Function Get-CustomGitPrompt
Export-ModuleMember -Function Get-CustomPrompt
Export-ModuleMember -Function Test-Git
Export-ModuleMember -Function Get-GitRootName