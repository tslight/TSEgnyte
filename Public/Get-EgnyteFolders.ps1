Function Get-EgnyteFolders {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[string]$Path,
	[Parameter(Mandatory)]
	[object]$Session,
	[int]$Depth=0,
	[switch]$IncludeParent
    )

    $Params      = @{
	Path     = $Path
	Session  = $Session
    }
    $Children = (Get-EgnyteChildItem @Params).folders.path

    if ($IncludeParent) {
	Write-Output $Path
    }

    if ($Children) {
	if ($Depth -gt 0) {
	    foreach ($Child in $Children) {
		Write-Output $Child
		$Params     = @{
		    Path    = $Child
		    Session = $Session
		    Depth   = ($Depth - 1)
		}
		Get-EgnyteFolders @Params
	    }
	} else {
	    Write-Output $Children
	}
    }
}
