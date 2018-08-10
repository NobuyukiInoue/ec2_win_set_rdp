param( $id, $rdp_filePath )

##--------------------------------------------------------##
## インスタンス起動指示確認
##--------------------------------------------------------##
function Check_startRun([string]$id)
{
    Write-Host

    while ($TRUE) {
        Write-Host "Windows Server 2016 Let you start Now? (y/n) [y]:" -NoNewLine

        # キー入力の読み込み
        $keyInfo = [Console]::ReadKey($TRUE)

        if (($keyInfo.Key -eq "N") -Or ($keyInfo.Key -eq "n")) {
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
    $publicIp = &".\get_publicIP.ps1" $id

    if ($publicIp) {
        break
    }
    else {
        Write-Host "publicIp is Nothing."

        # インスタンスの起動指示の確認
        $result = Check_startRun $id

        if ($result -eq $TRUE) {
            # EC2インスタンスの起動
            aws ec2 start-instances --instance-ids $id

            Write-Host "Please wait 15 Seconds."
            Start-Sleep -s 15
        }
        else {
            # 起動しない場合は処理を終了する
            Write-Host
            exit
        }
    }
} while (-Not($publicIp))


# 指定したrdpファイルの接続先IPアドレスを上書きする
$result = .\overwrite_rdp.ps1 $rdp_filePath $publicIp

if ($result -eq $TRUE) {
    Write-Host "Start " -NoNewline
    Write-Host "["$rdp_filePath"]" -ForegroundColor Yellow

    # リモートデスクトップ接続を起動する
    &$rdp_filePath
}
