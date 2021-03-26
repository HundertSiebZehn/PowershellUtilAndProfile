function Get-ShortPath ([string] $path, [int] $limit = 2, [string] $ellipses = '…') {
    [string[]] $elems = $(Convert-Path $path) -split '\\'
    if ($limit -ge $elems.count) {
        return $path
    }
    $ret = $ellipses
    for ($i= - $limit; $i -lt 0; $i++) {
        $ret += '\' + $elems[$i]
    }
    return $ret;
}

function Get-CustomGitPrompt {
    $path = $($(Get-PromptPath).replace($($(git rev-parse --show-toplevel).replace("/", "\")), "…"))
    if ($path -eq "…") {
        return "🌳"
    } else {
        return $path
    }
}

Export-ModuleMember -Function Get-ShortPath
Export-ModuleMember -Function Get-CustomGitPrompt