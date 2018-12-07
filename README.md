# あるawsアカウントからあるユーザを削除するsh

参考（cliからまともに削除しようとすると面倒..）
https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/id_users_manage.html#id_users_deleting_cli

## Usage
1. 環境変数export
```
export AWS_ACCESS_KEY_ID="xxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxx"
export AWS_DEFAULT_REGION="ap-northeast-1"
export AWS_DEFAULT_OUTPUT="json"
```
// 面倒なので事前にconfigureしておいて第２引数で実行するだけのshにして手順削減したい

2. 引数にusernameつけて実行
```
./delete_iam_user.sh ${username}
```
