function New-EgnyteRequest {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)][string]$Method,
	[Parameter(Mandatory)][object]$Session,
	[Parameter(Mandatory)][string]$Resource,
	[string]$OutFile,
	[string]$InFile
    )

    # $Resource = [System.Web.HttpUtility]::UrlEncode($Resource)
    $Headers  = Get-EgnyteHeaders $Session.token
    $URL      = $Session.base_uri
    $Uri      = "$URL/$Resource"
    # Write-Host -Back Black -Fore Cyan $Uri # debug

    $RestArgs = @{
	Method			= $Method
	Uri			= $Uri
	UseDefaultCredentials	= $True
	Headers			= $Headers
    }

    if ($OutFIle) {
	return Invoke-RestMethod @RestArgs -OutFile $OutFIle
    } elseif ($InFile) {
	return Invoke-RestMethod @RestArgs -InFile $InFile
    } else {
	return Invoke-RestMethod @RestArgs
    }
}
