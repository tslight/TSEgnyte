function Get-EgnyteHeaders {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory)][string]$Token
    )

    $HTTPHeaders = @{
	'Authorization'	= ("Bearer {0}" -f $Token)
	'Content-Type'	= 'application/json'
    }

    return $HTTPHeaders
}
