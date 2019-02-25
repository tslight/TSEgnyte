function ConvertFrom-EgnyteGroups {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[AllowNull()]
	[hashtable]$Groups,
	[Parameter(Mandatory)]
	[AllowEmptyCollection()]
	[array]$Permissions
    )

    $GroupObjects = @()

    foreach ($Name in $Groups.keys) {
	$GroupObj = New-Object PSObject
	$GroupObj | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name
	$GroupObj | Add-Member -MemberType NoteProperty -Name "Permissions" -Value $Groups[$Name]
	if ($Permissions.Groups.Name -Contains $Name) {
	    Write-Host -Back Black -Fore Cyan "Already queried $Name group."
	    $Members = ($Permissions.Groups | ? { $_.Name -eq $Name }).Members
	} else {
	    Write-Host -Back Black -Fore Magenta "Getting members of $Name group..."
	    $Members = (Get-ADGroupMembersByName $Name -Quick).Name
	}
	if ($Members) {
	    $GroupObj | Add-Member -MemberType NoteProperty -Name "Members" -Value $Members
	}
	$GroupObjects += $GroupObj
    }

    return $GroupObjects
}
