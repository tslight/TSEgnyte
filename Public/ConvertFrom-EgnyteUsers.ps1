function ConvertFrom-EgnyteUsers {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[AllowNull()]
	[hashtable]$Users,
	[Parameter(Mandatory)]
	[AllowNull()]
	[object]$Groups
    )

    $NewHT = @{}
    $Users = $Users | Sort-Object -Unique

    foreach ($Name in $Users.keys) {
	if ($Name -match '[A-z]+\.[A-z]+') {
	    try {
		$ADName = (Get-ADUserBySam $Name).Name
		if (!$ADName) {
		    Write-Warning "Failed to get AD name of $Name. Adding (Non-Employee) to name.."
		    $ADName  = (Get-Culture).TextInfo.ToTitleCase("$Name")
		    $ADName  = $ADName -Replace ("\."," ")
		    $ADName += " (Non-Employee)"
		}
		$NewHT[$ADName] = $Users[$Name]
	    } catch {
		Write-Warning $_.InvocationInfo.ScriptName
		Write-Warning $_.InvocationInfo.Line
		Write-Warning $_.Exception.Message
	    }
	}
    }

    foreach ($Group in $Groups) {
	foreach ($Name in $Group.Members) {
	    $NewHT[$Name] = $Group.Permissions
	}
    }

    return $NewHT
}
