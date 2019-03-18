function Get-EgnytePaidUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[object]$Session,
	[Parameter(ValueFromPipeline)]
	[object[]]$Users=(Get-EgnyteAllUsers -Session $Session)
    )

    $Users | Where-Object { $_.active -eq $True -And $_.userType -eq 'power' }

}
