function Clear-RWModCache {
    $Script:ModSearchCache.Clear()
    $Script:ModPackageIdCache.Clear()
}
