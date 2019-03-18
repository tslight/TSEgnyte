function Export-EgnyteUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$Path,
	[Parameter(Mandatory)]
	[object]$Session,
	[string]$Name="AllEgnyteUsers"
    )

    $Users = Get-EgnyteAllUsers -Session $Session

    $Selection = @(
	@{
	    Name = 'Username'
	    Expression = {$_.userName}
	},
	@{
	    Name = 'Name'
	    Expression = {$_.name.formatted}
	},
	@{
	    Name = 'UPN'
	    Expression = {$_.userPrincipalName}
	},
	@{
	    Name = 'Account Type'
	    Expression = {$_.userType}
	},
	@{
	    Name = 'Account Role'
	    Expression = {$_.role}
	},
	@{
	    Name = 'Service Account'
	    Expression = {$_.isServiceAccount}
	},
	@{
	    Name = 'Active'
	    Expression = {$_.active}
	},
	@{
	    Name = 'Locked'
	    Expression = {$_.locked}
	},
	@{
	    Name = 'Authorisation'
	    Expression = {$_.authType}
	},
	@{
	    Name = 'Last Active Date'
	    Expression = {$_.lastActiveDate | Get-Date -UFormat '%Y-%m-%d' }
	}
    )

    $Users | Select-Object $Selection | Export-Csv "$Path\$Name.csv" -NoTypeInformation
    Convert-CsvToXls -Csv "$Path\$Name.csv" -Xlsx "$Path\$Name"
}
