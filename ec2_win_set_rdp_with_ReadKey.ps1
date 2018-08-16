param( $id, $rdp_filePath )

##--------------------------------------------------------##
## インスタンス起動指示確認
##--------------------------------------------------------##
function Check_startRun([string]$msg)
{
    while ($TRUE) {
        Write-Host $msg -NoNewLine

        # キー入力の読み込み
        $keyInfo = [Console]::ReadKey($TRUE)

        if (($keyInfo.Key -eq "n") -Or ($keyInfo.Key -eq "n")) {
            Write-Host
            return $FALSE
        }
        elseif (($keyInfo.Key -eq "Y") -Or ($keyInfo.Key -eq "y")) {
            Write-Host
            return $TRUE
        }
        elseif ($keyInfo.Key -eq "Enter") {
            Write-Host
            return $TRUE
        }

        Write-Host
    }
}

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

do {
    $publicIp = &".\get_Win_PublicIpAddress_by_text.ps1" $id    # 指定したidのPublicIpAddressを検索する
    # $publicIp = &".\get_Win_PublicIpAddress_by_json.ps1" $id  # 指定したidのPublicIpAddressを検索する

    if ($publicIp -ne "None") {
        break
    }
    else {
        Write-Host "publicIp is Nothing."

        # インスタンスの起動指示の確認
        $result = Check_startRun "Windows Server 2016 Let you start Now? (y/n) [y]:"

        if ($result -eq $TRUE) {
            # EC2インスタンスの起動
            aws ec2 start-instances --instance-ids $id

            Write-Host "Please wait 15 Seconds."
            Start-Sleep -s 15
        }
        else {
            # 起動しない場合は次の処理へ
            Write-Host
            # exit
        }
    }
} while ($publicIp -ne "None")

# 指定したrdpファイルの接続先IPアドレスを上書きする
$result = .\overwrite_rdp.ps1 $rdp_filePath $publicIp

Write-Host "["$rdp_filePath"]" -ForegroundColor Yellow -NoNewline

# リモートデスクトップ接続の起動指示の確認
$result = Check_startRun " Execute Now? (y/n) [y]:"

if ($result -eq $TRUE) {
    &$rdp_filePath
}
