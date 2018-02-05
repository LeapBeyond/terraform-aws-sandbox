#!/bin/bash

cd `dirname $0`
[ -d ../data ] || mkdir ../data
[[ -s ./env.rc ]] && source ./env.rc

echo "======== setting up groups ========"
aws iam get-group --group-name $ADMIN_GROUP > /dev/null 2>&1
if [ $? -gt 0 ]
then
    aws iam create-group --group-name $ADMIN_GROUP
    aws iam attach-group-policy --group-name $ADMIN_GROUP --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"
fi

aws iam get-group --group-name $DEV_GROUP > /dev/null 2>&1
if [ $? -gt 0 ]
then
    aws iam create-group --group-name $DEV_GROUP
    aws iam attach-group-policy --group-name $DEV_GROUP --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    aws iam attach-group-policy --group-name $DEV_GROUP --policy-arn "arn:aws:iam::aws:policy/IAMUserChangePassword"
fi

for ID in $ADMIN_USERS
do
  aws iam add-user-to-group --group-name $ADMIN_GROUP --user-name $ID
done

for ID in $DEV_USERS
do
  aws iam add-user-to-group --group-name $DEV_GROUP --user-name $ID
done

echo "======= setting up key pairs ======="
for KEY_NAME in $KEY_NAMES
do
  aws ec2 describe-key-pairs --output text --key-name $KEY_NAME >/dev/null 2>&1
  if [ $? -gt 0 ]
  then
    aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' | sed -e 's/^"//' -e 's/"$//' -e's/\\n/\
/g'> ../data/$KEY_NAME.pem
    chmod 400 ../data/$KEY_NAME.pem
  fi
  aws ec2 describe-key-pairs --output text --key-name $KEY_NAME
done

echo "======== attaching SSL key to users ========"
for ID in $DEV_USERS
do
  ssh-keygen -b 2048 -f ../data/${ID}_key -N '' -C $ID
  chmod 400 ../data/${ID}_key
  aws iam upload-ssh-public-key --user-name $ID --ssh-public-key-body "$(cat ../data/${ID}_key.pub)"
  aws iam list-ssh-public-keys --user-name $ID --output text | cut -f2,5
done

echo "======== setting up terraform back end ========"
cd terraform
terraform init
terraform apply
