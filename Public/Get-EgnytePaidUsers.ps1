function Get-EgnytePaidUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[object]$Session=(Get-EgnyteSession),
	[Parameter(ValueFromPipeline)]
	[object[]]$Users=(Get-EgnyteUsers -Session $Session)
    )

    $Users | Where-Object {
	($_.active -eq $True) -And ($_.userType -eq 'power' -Or $_.userType -eq 'admin')
    }
}
