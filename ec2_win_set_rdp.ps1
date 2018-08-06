param( $id, $rdp_filePath )

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
$publicIp = &".\get_publicIP.ps1" $id

if (-Not($publicIp)) {
    Write-Host "publicIp is Nothing."
    exit
}


# �w�肵��rdp�t�@�C���̐ڑ���IP�A�h���X���㏑������
$result = .\overwrite_rdp.ps1 $rdp_filePath $publicIp

if ($result -eq $True) {
    Write-Host "Start " -NoNewline
    Write-Host "["$rdp_filePath"]" -ForegroundColor Yellow

    # �����[�g�f�X�N�g�b�v�ڑ����N������
    &$rdp_filePath
}