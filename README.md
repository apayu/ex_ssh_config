# ex_ssh_config
Generate an SSH config for AWS EC2 quickly andeasily using Elixir

## Config
This script is based on [ex_aws](https://github.com/ex-aws/ex_aws), Please configure your AWS key following the [instructions](https://github.com/ex-aws/ex_aws?tab=readme-ov-file#aws-key-configuration).

## Arguments
Adjust the following module attrtube according to your needs.
```
@profile "default"
@key_dir "~/.ssh/"
@key_name "id_ed25519"
@region "ap-northeast-1"
```

## Usag
```
$ elixir aws_ssh_config.exs
```
