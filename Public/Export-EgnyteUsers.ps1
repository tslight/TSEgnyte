function Export-EgnyteUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$Path,
	[Parameter(Mandatory)]
	[object]$Session,
	[string]$Name="AllEgnyteUsers"
    )

    $Pages = Get-EgnyteAllUsers -Session $Session
    $Users = $Pages.resources

    $Selection = @(
	@{
	    Name = 'User'
	    Expression = {$_.userName}
	},
	@{
	    Name = 'UPN'
	    Expression = {$_.userPrincipalName}
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
	    Name = 'Account Role'
	    Expression = {$_.role}
	},
	@{
	    Name = 'Service Account'
	    Expression = {$_.isServiceAccount}
	},
	@{
	    Name = 'Last Active Date'
	    Expression = {$_.lastActiveDate | Get-Date -UFormat '%Y-%m-%d' }
	}
    )

    $Users | Select-Object $Selection | Export-Csv "$Path\$Name.csv" -NoTypeInformation
    Convert-CsvToXls -Csv "$Path\$Name.csv" -Xlsx "$Path\$Name"
}
