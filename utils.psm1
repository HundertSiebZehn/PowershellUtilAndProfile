function Get-ShortPath ([string] $path, [int] $limit = 2, [string] $ellipses = '…') {
    [string[]] $elems = $path -split '\\'
    if ($limit -ge $elems.Count) {
        return $path
    }
    $ret = $ellipses
    for ($i= - $limit; $i -lt 0; $i++) {
        $ret += '\' + $elems[$i]
    }
    return $ret;
}
function Format-PromptPath([string] $path) {
    return "🗂️`e[34m[`e[0m$path`e[34m]`e[0m"
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