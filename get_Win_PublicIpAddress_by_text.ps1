param( $InstanceId )

if (-Not($InstanceId)) {
    Write-Host "Usage : "$MyInvocation.MyCommand.Name" InstanceId" -ForegroundColor Red
    exit
}

<#
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, PublicIpAddress]' --output text |
%{if ($_.split("`t")[0] -match $InstanceId) { $_.split("`t")[1]; } }
#>

$res = & "aws" ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId, PublicIpAddress]' --output text

foreach ($var in $res) {
    if ($var.split("`t")[0] -match $InstanceId) {
        return $var.split("`t")[1]
    }
}

return "None"
