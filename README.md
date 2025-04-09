# quick-ssm-bash
A quick BASH script (and converted ZSH function) that allows SSM Session Connect with a simple arg entry of either an EC2 Instance ID or tagged name, useful for multiple AWS accounts and connecting over CLI to an instance without querying/opening up the AWS Console.

The session manager plugin must be installed alongside the AWS CLI, you can find steps here - https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

This is provided as two versions; a standalone script ran with `bash ./scripts/Quick_SSM_Connect_BASH.sh` or imported as a ZSH function, for example adding this to your `~/.zshrc` file and then running `qssm <instance_id>` in a new session:
```
$file="~/scripts/Quick_SSM_Connect_ZSH_FUNCTION.sh"
[[ -f "$file" ]] && source "$file"
```