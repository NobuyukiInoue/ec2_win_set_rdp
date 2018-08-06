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
                if ((Check_ReadKey $filePath) -eq $False) {
                    # "n"が入力された場合は終了する
                    return $False
                }

                $lines += $new_fullAddr
            }
            else {
                Write-Host "full address get Error!"
                return $False
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
    while ($true) {
        Write-Host "["$filePath"]" -NoNewline -ForegroundColor Yellow
        Write-Host " Overwrite? y/n [y]:" -NoNewline

        # キー入力の読み込み
        $keyInfo = [Console]::ReadKey($true)

        Write-Host

        if (($keyInfo.Key -eq "n") -Or ($keyInfo.Key -eq "n")) {
            Write-Host "Canceled."
            Write-Host
            return $False
        }
        elseif (($keyInfo.Key -eq "Y") -Or ($keyInfo.Key -eq "y")) {
            Write-Host
            return $True
        }
        elseif ($keyInfo.Key -eq "Enter") {
            Write-Host
            return $True
        }
    }
}


##--------------------------------------------------------##
## RDPファイルへの出力
##--------------------------------------------------------##
function save_RDP_File([string]$filePath, [array]$lines)
{
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($i -eq 0) {
            $lines[$i] | Out-File $filePath -Encoding Unicode
            # Write-Host $lines[$i]
        }
        else {
            $lines[$i] | Out-File $filePath -Encoding Unicode -Append
            # Write-Host $lines[$i]
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

if ($lines -eq $False) {
    return $False
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
save_RDP_File $rdp_filePath $lines

# 書き込み終了メッセージ
Write-Host "["$rdp_filePath"]" -NoNewline -ForegroundColor Yellow
Write-Host " was saved."
Write-Host

return $True
