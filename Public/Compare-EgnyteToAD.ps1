function Compare-EgnyteToAD {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[System.IO.FileInfo]$InputCsv
    )

    $Instance = ($InputCsv | Split-Path -Leaf) -Replace 'Users_|.csv',''

    $InputCsv | Import-Csv | % { $_ | Add-Member -MemberType NoteProperty -Name 'Instance' -Value $Instance }
}
