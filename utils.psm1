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
    $saved = $LASTEXITCODE;
    if (-not [System.IO.Path]::IsPathRooted($Path)) {
        $Path = $(Resolve-Path -Path $Path).Path
    }
    $result = $(git -C $Path status 2>&1 | Out-Null; -not [System.boolean] $LASTEXITCODE)
    $LASTEXITCODE = $saved;

    return $result
}

function Get-GitRootName([string] $path) {
    if (-not $(Test-Git $path)) {
        return ""
    }

    $rootPath = $(git -C $path rev-parse --show-toplevel).replace("/", "\")
    $rootName = $(Split-Path -Leaf $rootPath)
    $parentPath = $(Join-Path -ErrorAction SilentlyContinue $rootPath ".." -Resolve)
    if ($(Test-Git $parentPath)) {
        return $(Get-GitRootName $parentPath) + " »  $rootName"
    }
    return " $rootName"
}

function Get-CustomPrompt {
    return "$(Format-PromptPath($(Get-ShortPath $(Get-PromptPath)))) "
}

Export-ModuleMember -Function Get-ShortPath
Export-ModuleMember -Function Get-CustomGitPrompt
Export-ModuleMember -Function Get-CustomPrompt
Export-ModuleMember -Function Test-Git
Export-ModuleMember -Function Get-GitRootName