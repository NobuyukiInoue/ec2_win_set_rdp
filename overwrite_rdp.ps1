param( $rdp_filePath, $publicIp )

##--------------------------------------------------------##
## RDP�t�@�C���̓ǂݍ���
##--------------------------------------------------------##
function load_RDP_File_and_ipChange([string]$filePath)
{
    $f = (Get-Content $filePath) -as [string[]]
    $lines = @()

    foreach ($currentLine in $f){

        # �ڑ���IP�A�h���X���̌���
        if ($currentLine.IndexOf("full address:s:") -eq 0) {
        
            $workStr = $currentLine.Split(":")
            
            if ($workStr.Length -eq 3) {
                $new_fullAddr = $workStr[0] + ":" + $workStr[1] + ":" + $publicIp

                Write-Host "Current Value ... " -NoNewline
                Write-Host $currentLine -ForegroundColor Cyan
                Write-Host "New     Value ... " -NoNewline
                Write-Host $new_fullAddr -ForegroundColor Cyan
                Write-Host

                # �L�[���͂𒲂ׂ�
                if ((Check_ReadKey $filePath) -eq $False) {
                    # "n"�����͂��ꂽ�ꍇ�͏I������
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
## �L�[���̓`�F�b�N
##--------------------------------------------------------##
function Check_ReadKey([string]$filePath)
{
    while ($true) {
        Write-Host "["$filePath"]" -NoNewline -ForegroundColor Yellow
        Write-Host " Overwrite? y/n [y]:" -NoNewline

        # �L�[���͂̓ǂݍ���
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
## RDP�t�@�C���ւ̏o��
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
## ���C��
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

# rdp�t�@�C�������݂��Ă��邩�ǂ������ׂ�
if ((Test-Path($rdp_filePath)) -eq $FALSE) {
    Write-Host "["$rdp_filePath"] is not found." -ForegroundColor Red
    exit
}

$lines = @()

# RDP�t�@�C����ǂݍ���
$lines = load_RDP_File_and_ipChange $rdp_filePath

if ($lines -eq $False) {
    return $False
}

# ���݂̓��t�������擾����
$timestamp = $(Get-ItemProperty $rdp_filePath).LastWriteTime.ToString('_yyyyMMdd_HHmmss')

# ���݂̃t�@�C�������l�[�����Ă���
$oldFileName = $rdp_filePath.Replace(".rdp", $timestamp + ".rdp")
Move-Item $rdp_filePath $oldFileName

Write-Host "["$rdp_filePath"]" -NoNewline -ForegroundColor Yellow
Write-Host " Rename to "
Write-Host "["$oldFileName"]" -ForegroundColor Yellow
Write-Host

# RDP�t�@�C���ɏ�������
save_RDP_File $rdp_filePath $lines

# �������ݏI�����b�Z�[�W
Write-Host "["$rdp_filePath"]" -NoNewline -ForegroundColor Yellow
Write-Host " was saved."
Write-Host

return $True
