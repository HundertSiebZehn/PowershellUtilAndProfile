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
    $rootPath = ($(git rev-parse --show-toplevel).replace("/", "\"))
    $path = ($(Get-PromptPath).replace($rootPath, ""))
    $root = $(Split-Path -Leaf $rootPath)
    if ($path -eq "") {
        return Format-PromptPath(" $root")
    }
    return Format-PromptPath(" $root\" + $(Get-ShortPath($path)))
}

Export-ModuleMember -Function Get-ShortPath
Export-ModuleMember -Function Get-CustomGitPrompt
Export-ModuleMember -Function Format-PromptPath