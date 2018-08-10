param( $rdp_filePath, $publicIp )

##--------------------------------------------------------##
## RDPファイルの読み込み
##--------------------------------------------------------##
function load_RDP_File_and_ipChange([string]$filePath)
{
    $f = (Get-Content $filePath) -as [string[]]
    $lines = @()

    foreach ($currentLine in $f){

        # 接続先IPアドレス情報の検索
        if ($currentLine.IndexOf("full address:s:") -eq 0) {
        
            $workStr = $currentLine.Split(":")
            
            if ($workStr.Length -eq 3) {
                $new_fullAddr = $workStr[0] + ":" + $workStr[1] + ":" + $publicIp

                Write-Host "Current Value ... " -NoNewline
                Write-Host $currentLine -ForegroundColor Cyan
                Write-Host "New     Value ... " -NoNewline
                Write-Host $new_fullAddr -ForegroundColor Cyan
                Write-Host

                # キー入力を調べる
                if ((Check_ReadKey $filePath) -eq $FALSE) {
                    # "n"が入力された場合は終了する
                    return $FALSE
                }

                $lines += $new_fullAddr
            }
            else {
                Write-Host "full address get Error!"
                return $FALSE
            }
        }
        else {
            $lines += $currentLine
        }
    }

    return($lines)
}

##--------------------------------------------------------##
## キー入力チェック
##--------------------------------------------------------##
function Check_ReadKey([string]$filePath)
{
    while ($TRUE) {
        Write-Host "["$filePath"]" -NoNewline -ForegroundColor Yellow
        Write-Host " Overwrite? y/n [y]:" -NoNewline

        # キー入力の読み込み
        $keyInfo = [Console]::ReadKey($TRUE)

        Write-Host

        if (($keyInfo.Key -eq "n") -Or ($keyInfo.Key -eq "n")) {
            Write-Host "Canceled."
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
    }
}


##--------------------------------------------------------##
## メイン
##--------------------------------------------------------##

Write-Host "<"$MyInvocation.MyCommand.Name">" -ForegroundColor Yellow

if (-Not($publicIp)) {
    Write-Host "Usage : "$MyInvocation.MyCommand.Name"publicIp rdp_filePath" -ForegroundColor Red
    exit
}

if (-Not($rdp_filePath)) {
    Write-Host "Usage : "$MyInvocation.MyCommand.Name"publicIp rdp_filePath" -ForegroundColor Red
    exit
}

# rdpファイルが存在しているかどうか調べる
if ((Test-Path($rdp_filePath)) -eq $FALSE) {
    Write-Host "["$rdp_filePath"] is not found." -ForegroundColor Red
    exit
}

$lines = @()

# RDPファイルを読み込む
$lines = load_RDP_File_and_ipChange $rdp_filePath

if ($lines -eq $FALSE) {
    return $FALSE
}

# 現在の日付時刻を取得する
$timestamp = $(Get-ItemProperty $rdp_filePath).LastWriteTime.ToString('_yyyyMMdd_HHmmss')

# 現在のファイルをリネームしておく
$oldFileName = $rdp_filePath.Replace(".rdp", $timestamp + ".rdp")
Move-Item $rdp_filePath $oldFileName

Write-Host "["$rdp_filePath"]" -NoNewline -ForegroundColor Yellow
Write-Host " Rename to "
Write-Host "["$oldFileName"]" -ForegroundColor Yellow
Write-Host

# RDPファイルに書き込む
Set-Content -Path $rdp_filePath -Value $lines -Encoding Unicode

# 書き込み終了メッセージ
Write-Host "["$rdp_filePath"]" -NoNewline -ForegroundColor Yellow
Write-Host " was saved."
Write-Host

return $TRUE
