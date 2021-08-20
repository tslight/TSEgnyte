function Import-EgnyteUsersFromCsv {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[System.IO.FileInfo]$InputCsv
    )

    process {
	$Instance = ($InputCsv | Split-Path -Leaf) -Replace 'Users_|.csv',''
	$InputCsv | Import-Csv | Compare-EgnyteADUsers -Instance $Instance
    }
}
