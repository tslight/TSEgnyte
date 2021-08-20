function Export-EgnyteADUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[System.IO.FileInfo]$InputCsv,
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$ExportPath,
	[string]$Name="EgnyteADUsers",
	[object]$Session,
	[switch]$FromEmailColumn,
	[switch]$SingleWorksheet,
	[switch]$CorrectlyChargedUsers,
	[switch]$IncorrectlyChargedUsers,
	[switch]$Force
    )

    begin {
	$Date = Get-Date -UFormat "%Y-%m-%d"
	New-Path "$ExportPath\$Date\Csv" -Type 'Directory'
	$Selection = @(
	    'AD User Found',
	    @{ Name = 'Egnyte Active'; Expression = {$_.Active} },
	    'AD Enabled',
	    @{ Name = 'Egnyte Username'; Expression = {$_.UserName} },
	    'AD UserName',
	    @{ Name = 'Egnyte Email'; Expression = {$_.Email} },
	    'AD Email',
	    'Egnyte Instance',
	    'AD Company',
	    'AD Department',
	    @{ Name = 'Egnyte Account Type'; Expression = {$_.Type} },
	    @{ Name = 'Egnyte Account Role'; Expression = {$_.Role} },
	    @{ Name = 'Egnyte Last Active'; Expression = {$_.LastActive} },
	    'AD Last Active'
	)
	$Users = @()
    }

    process {
	if ($FromEmailColumn) {
	    if (-Not $Session) {
		$Session = Get-EgnyteSession
	    }
	    Get-CsvColumn -Csv $InputCsv -Column 'email' |
	      Get-EgnyteADUsersFromEmail -Session $Session |
	      Export-Csv -NoTypeInformation "$ExportPath\$Date\Csv\$Name.csv"
	} else {
	    $Instance = ($InputCsv | Split-Path -Leaf) -Replace 'Users_|.csv',''
	    if ($SingleWorksheet) {
		$CsvPath = "$ExportPath\$Date\Csv\$Name-$Date.csv"
	    } else {
		$CsvPath = "$ExportPath\$Date\Csv\$Instance.csv"
	    }
	    if ((Test-Path $CsvPath) -And (-Not $Force)) {
		Write-Warning "$CsvPath already exists. Use -Force to overwrite..."
	    } else {
		if ($CorrectlyChargedUsers) {
		    $InstanceUsers = $InputCsv |
		      Import-Csv |
		      Compare-EgnyteADUsers -Instance $Instance |
		      Where-Object {
			  ($_.'AD User Found' -eq $True) -And
			  ($_.'AD Enabled' -eq $True) -And
			  ($_.Active -eq 'yes') -And
			  ($_.Type -eq 'power')
		      } | Select-Object $Selection
		} elseif ($IncorrectlyChargedUsers) {
		    $InstanceUsers = $InputCsv |
		      Import-Csv |
		      Compare-EgnyteADUsers -Instance $Instance |
		      Where-Object {
			  (($_.'AD User Found' -eq $False) -or
			   ($_.'AD Enabled' -eq $False)) -And
			  ($_.Active -eq 'yes') -And
			  ($_.Type -eq 'power')
		      } | Select-Object $Selection
		} else {
		    $InstanceUsers = $InputCsv |
		      Import-Csv |
		      Compare-EgnyteADUsers -Instance $Instance |
		      Select-Object $Selection
		}
		if ($SingleWorksheet) {
		    $Users += $InstanceUsers
		} else {
		    $InstanceUsers | Export-Csv -NoTypeInformation $CsvPath
		}
	    }
	}
    }

    end {
	$Xlsx = "$ExportPath\$Date\$Name-$Date"
	if ((Test-Path "$Xlsx.xlsx") -And (-Not $Force)) {
	    Write-Warning "$Xlsx.xlsx already exists. Use -Force to overwrite..."
	} else {
	    if ($SingleWorksheet) {
		$Users | Export-Csv -NoTypeInformation $CsvPath
		Get-Item $CsvPath | Convert-CsvToXls -Xlsx $Xlsx
	    } else {
		Get-ChildItem "$ExportPath\$Date\Csv\*.csv" | Convert-CsvToXls -Xlsx $Xlsx
	    }
	}
    }
}
