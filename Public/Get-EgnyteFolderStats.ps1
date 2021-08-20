function Get-EgnyteFolderStats {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[string]$Path,
	[Parameter(Mandatory)]
	[object]$Session
    )

    $PathId = (Get-EgnyteChildItem $Path $Session).folder_id

    $RequestArgs = @{
	Method = "Get"
	Session = $Session
	Resource = "pubapi/v1/fs/ids/folder/$PathId/stats"
    }

    New-EgnyteRequest @RequestArgs
}
