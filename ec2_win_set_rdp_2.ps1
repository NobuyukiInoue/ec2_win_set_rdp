param( $id, $rdp_filePath )

##--------------------------------------------------------##
## �C���X�^���X�N���w���m�F
##--------------------------------------------------------##
function Check_startRun([string]$id)
{
    Write-Host

    while ($TRUE) {
        Write-Host "Windows Server 2016 Let you start Now? (y/n) [y]:" -NoNewLine

        # �L�[���͂̓ǂݍ���
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
    $publicIp = &".\get_publicIP.ps1" $id

    if ($publicIp) {
        break
    }
    else {
        Write-Host "publicIp is Nothing."

        # �C���X�^���X�̋N���w���̊m�F
        $result = Check_startRun $id

        if ($result -eq $TRUE) {
            # EC2�C���X�^���X�̋N��
            aws ec2 start-instances --instance-ids $id

            Write-Host "Please wait 15 Seconds."
            Start-Sleep -s 15
        }
        else {
            # �N�����Ȃ��ꍇ�͏������I������
            Write-Host
            exit
        }
    }
} while (-Not($publicIp))


# �w�肵��rdp�t�@�C���̐ڑ���IP�A�h���X���㏑������
$result = .\overwrite_rdp.ps1 $rdp_filePath $publicIp

if ($result -eq $TRUE) {
    Write-Host "Start " -NoNewline
    Write-Host "["$rdp_filePath"]" -ForegroundColor Yellow

    # �����[�g�f�X�N�g�b�v�ڑ����N������
    &$rdp_filePath
}
