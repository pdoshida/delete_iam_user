#!/bin/bash

user_name=$1

echo ${user_name}

echo "Deleting Access Key"
aws iam delete-access-key --access-key-id $(aws iam list-access-keys --user-name ${user_name} \
    | jq -r '.AccessKeyMetadata[] | .AccessKeyId' ) --user-name ${user_name}

echo "Deleting Signing Certificates"
if (( $(aws iam list-signing-certificates --user-name ${user_name} | jq -r '.Certificates[] | .CertificateId' | wc -l) > 0 )); then 
    for cert in $(aws iam list-signing-certificates --user-name ${user_name} | jq -r '.Certificates[] | .CertificateId'); do
        aws iam delete-signing-certificate --user-name ${user_name}  --certificate-id $cert
    done
fi

echo "Deleting Login Profile"
if $(aws iam get-login-profile --user-name ${user_name} &>/dev/null); then 
    aws iam  delete-login-profile --user-name ${user_name}
fi

echo "Deleting 2FA Devices associated with User"
if (( $(aws iam list-mfa-devices --user-name ${user_name} | jq -r '.MFADevices[] | .SerialNumber' | wc -l) > 0 )); then 
    for mfa_dev in $(aws iam list-mfa-devices --user-name ${user_name} | jq -r '.MFADevices[] | .SerialNumber'); do
        aws iam deactivate-mfa-device --user-name ${user_name}  --serial-number $mfa_dev
    done
fi

echo "Removing Attached User Policies:"
aws iam list-attached-user-policies --user-name ${user_name} | jq -r '.AttachedPolicies[] | .PolicyName'

for policy in $(aws iam list-attached-user-policies --user-name ${user_name} | jq -r '.AttachedPolicies[] | .PolicyArn'); do 
    aws iam detach-user-policy \
    --user-name ${user_name} \
    --policy-arn ${policy}
done


echo "Deleting Inline Policies:"
for inline_policy in $(aws iam list-user-policies --user-name ${user_name} | jq -r '.PolicyNames[]'); do
    echo $inline_policy
    aws iam delete-user-policy \
        --user-name ${user_name} \
        --policy-name ${inline_policy}
done


echo "Removing Group Memberships:"
for group in $(aws iam list-groups-for-user --user-name ${user_name} | jq -r '.Groups[] | .GroupName'); do
    echo $group 
    aws iam remove-user-from-group \
        --group-name ${group} \
        --user-name ${user_name}
done

echo "Deleting User"
 aws iam delete-user --user-name ${user_name}
