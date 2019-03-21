function Export-EgnyteADUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$InputCsv,
	[System.IO.FileInfo]$ExportCsv=".\EgnyteADInfo.csv",
	[object]$Session=(Get-EgnyteSession)
    )

    Get-CsvColumn -Csv $InputCsv -Column 'email' |
      Get-EgnyteADUsersFromEmail -Session $Session |
      Export-Csv -NoTypeInformation $ExportCsv

    $Xlsx = $ExportCsv -Replace ('.csv','')
    Convert-CsvToXls -Csv $ExportCsv -Xlsx $Xlsx
}
