function Export-EgnytePermissions {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object]$Permissions,
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$Path,
	[Parameter(Mandatory)]
	[string]$Name
    )

    process {
	$Sheet1 = @()
	$Sheet2 = @()

	foreach ($Value in $Permissions.Values) {
	    $Owners  = $Value.Users | ? { $_.Values -eq 'Owner' }
	    $Full    = $Value.Users | ? { $_.Values -eq 'Full' }
	    $Editors = $Value.Users | ? { $_.Values -eq 'Editor' }
	    $Viewers = $Value.Users | ? { $_.Values -eq 'Viewer' }
	    $Perms = New-Object PSObject
	    $Perms | Add-Member -MemberType NoteProperty -Name 'Folder Name' -Value $Value.Path
	    $Perms | Add-Member -MemberType NoteProperty -Name 'Owners' -Value $Owners.Count
	    $Perms | Add-Member -MemberType NoteProperty -Name 'Full' -Value $Full.Count
	    $Perms | Add-Member -MemberType NoteProperty -Name 'Editors' -Value $Editors.Count
	    $Perms | Add-Member -MemberType NoteProperty -Name 'Viewers' -Value $Viewers.Count
	    $Sheet1 += $Perms

	    $OwnersStr = $FullStr = $EditorsStr = $ViewersStr = ""
	    $Owners.Keys  | ? { $_ -ne $Null } | % { $OwnersStr  += $_ + "|" }
	    $Full.Keys    | ? { $_ -ne $Null } | % { $FullStr    += $_ + "|" }
	    $Editors.Keys | ? { $_ -ne $Null } | % { $EditorsStr += $_ + "|" }
	    $Viewers.Keys | ? { $_ -ne $Null } | % { $ViewersStr += $_ + "|" }
	    $Users = New-Object PSObject
	    $Users | Add-Member -MemberType NoteProperty -Name 'Folder Name' -Value $Value.Path
	    $Users | Add-Member -MemberType NoteProperty -Name 'Owners' -Value $OwnersStr
	    $Users | Add-Member -MemberType NoteProperty -Name 'Full' -Value $FullStr
	    $Users | Add-Member -MemberType NoteProperty -Name 'Editor' -Value $EditorsStr
	    $Users | Add-Member -MemberType NoteProperty -Name 'Viewer' -Value $ViewersStr
	    $Sheet2 += $Users
	}

	try {
	    $Sheet1 | Export-Csv "$Path\Permissions.csv" -NoTypeInformation
	    $Sheet2 | Export-Csv "$Path\Users.csv" -NoTypeInformation
	} catch {
	    Write Warning "Failed to create Csvs.`n$($_)"
	    throw
	}

	try {
	    Get-ChildItem "$Path\*.csv" | ConvertTo-XlsxFromCsv -Xlsx "$ReportPath\$Name"
	    Remote-Item "$Path\*.csv"
	    return "$ReportPath\$Name.xlsx"
	} catch {
	    Write-Warning $_
	    throw
	}
    }
}
