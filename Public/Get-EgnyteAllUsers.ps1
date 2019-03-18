function Get-EgnyteAllUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)]
	[object]$Session,
	[int]$StartIndex=1,
	[array]$Users=@()
    )

    $Resource = "pubapi/v2/users?count=100&startIndex=$StartIndex"
    $RequestArgs = @{
	Method = "Get"
	Session = $Session
	Resource = $Resource
    }

    try {
	$Response = New-EgnyteRequest @RequestArgs
	$msg = (
	    "Retrieved $StartIndex - $($StartIndex + 100) of $($Response.totalResults) results..."
	)
	Write-Host -Back Black -Fore Cyan $msg
	Write-Verbose $Response
    } catch {
	Write-Warning $_.InvocationInfo.ScriptName
	Write-Warning $_.InvocationInfo.Line
	Write-Warning $_.Exception.Message
    }

    if ($Response.resources -ne $Null) {
	$Users += $Response.resources
	$StartIndex += 100
	Get-EgnyteAllUsers -Session $Session -StartIndex $StartIndex -Users $Users
    } else {
	return $Users
    }
}
