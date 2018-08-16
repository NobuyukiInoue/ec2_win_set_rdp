param( $id, $rdp_filePath )

##--------------------------------------------------------##
## �C���X�^���X�N���w���m�F
##--------------------------------------------------------##
function Check_startRun([string]$msg)
{
    while ($TRUE) {
        Write-Host $msg -NoNewLine

        # �L�[���͂̓ǂݍ���
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
## ���C��
##--------------------------------------------------------##
if (-Not($id)) {
    $id = "�����ɃC���X�^���XID���Z�b�g���Ă�������"
}

if (-Not($rdp_filePath)) {
    $rdp_filePath = "������RDP�t�@�C���̃p�X���Z�b�g���Ă�������"
}

if ($rdp_filePath.Substring(0,1) -ne ".") {
    $rdp_filePath = ".\" + $rdp_filePath
}

Write-Host "<"$MyInvocation.MyCommand.Name">" -ForegroundColor Yellow

# �w�肵��[InstanceId]��[publicIp]���擾

do {
    $publicIp = &".\get_Win_PublicIpAddress_by_text.ps1" $id    # �w�肵��id��PublicIpAddress����������
    # $publicIp = &".\get_Win_PublicIpAddress_by_json.ps1" $id  # �w�肵��id��PublicIpAddress����������

    if ($publicIp -ne "None") {
        break
    }
    else {
        Write-Host "publicIp is Nothing."

        # �C���X�^���X�̋N���w���̊m�F
        $result = Check_startRun "Windows Server 2016 Let you start Now? (y/n) [y]:"

        if ($result -eq $TRUE) {
            # EC2�C���X�^���X�̋N��
            aws ec2 start-instances --instance-ids $id

            Write-Host "Please wait 15 Seconds."
            Start-Sleep -s 15
        }
        else {
            # �N�����Ȃ��ꍇ�͎��̏�����
            Write-Host
            # exit
        }
    }
} while ($publicIp -ne "None")

# �w�肵��rdp�t�@�C���̐ڑ���IP�A�h���X���㏑������
$result = .\overwrite_rdp.ps1 $rdp_filePath $publicIp

Write-Host "["$rdp_filePath"]" -ForegroundColor Yellow -NoNewline

# �����[�g�f�X�N�g�b�v�ڑ��̋N���w���̊m�F
$result = Check_startRun " Execute Now? (y/n) [y]:"

if ($result -eq $TRUE) {
    &$rdp_filePath
}
