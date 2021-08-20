function Get-EgnyteChildItem {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[string]$Path,
	[Parameter(Mandatory)]
	[object]$Session,
	[switch]$Perms
    )

    process {
	if ($Perms) {
	    $Resource = "pubapi/v2/perms$Path"
	} else {
	    $Resource = "pubapi/v1/fs$Path"
	}

	$RequestArgs = @{
	    Method = "Get"
	    Session = $Session
	    Resource = $Resource
	}

	try {
	    New-EgnyteRequest @RequestArgs
	} catch {
	    Write-Warning $_.InvocationInfo.ScriptName
	    Write-Warning $_.InvocationInfo.Line
	    Write-Warning $_.Exception.Message
	}
    }
}
