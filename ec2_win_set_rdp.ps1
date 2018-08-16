param( $id, $rdp_filePath )

##--------------------------------------------------------##
## メイン
##--------------------------------------------------------##
if (-Not($id)) {
    $id = "ここにインスタンスIDをセットしてください"
}

if (-Not($rdp_filePath)) {
    $rdp_filePath = "ここにRDPファイルのパスをセットしてください"
}

if ($rdp_filePath.Substring(0,1) -ne ".") {
    $rdp_filePath = ".\" + $rdp_filePath
}

Write-Host "<"$MyInvocation.MyCommand.Name">" -ForegroundColor Yellow

# 指定した[InstanceId]の[publicIp]を取得
$publicIp = &".\get_Win_PublicIpAddress_by_text.ps1" $id    # 指定したidのPublicIpAddressを検索する
#$publicIp = &".\get_Win_PublicIpAddress_by_json.ps1" $id      # 指定したidのPublicIpAddressを検索する

if ($publicIp -eq "None") {
    Write-Host "publicIp is Nothing."
    exit
}

# 指定したrdpファイルの接続先IPアドレスを上書きする
$result = .\overwrite_rdp.ps1 $rdp_filePath $publicIp

if ($result -eq $TRUE) {
    Write-Host "Start " -NoNewline
    Write-Host "["$rdp_filePath"]" -ForegroundColor Yellow

    # リモートデスクトップ接続を起動する
    &$rdp_filePath
}
