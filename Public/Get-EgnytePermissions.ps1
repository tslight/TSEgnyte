function Get-EgnytePermissions {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(ValueFromPipeline)]
	[string]$Root="/Shared",
	[Parameter(Mandatory)]
	[object]$Session,
	[int]$Depth=0
    )

    begin {
	$Permissions = @()
    }

    process {
	$Params           = @{
	    Path          = $Root
	    Session       = $Session
	    Depth         = $Depth
	    IncludeParent = $True
	}

	if ($Depth -eq 0) {
	    $msg = "Finding folders under $Root..."
	} else {
	    $msg = "Finding folders under $Root recursively to a depth of $Depth."
	}

	Write-Host -Back Black -Fore Magenta $msg
	$Folders = Get-EgnyteFolders @Params

	foreach ($Path in $Folders) {
	    if ($Path -match '.*\.Temporaryitems.*|.*\.Trashes.*|.*__MACOSX.*') {
		continue
	    }
	    Write-Host -Back Black -Fore Green "Getting Egnyte permissions for $Path..."
	    $Folder = Get-EgnyteChildItem -Path $Path -Session $Session -Perms
	    $Groups = $Folder.groupPerms | ConvertTo-HashTable
	    $Groups.Remove('All Administrators')
	    $Users  = $Folder.userPerms  | ConvertTo-HashTable
	    $Parent = ($Path | Split-Path -Parent) -Replace ('\\','/')
	    if ($Parent -And $Permissions) {
		while ($Permissions.Path -NotContains $Parent) {
		    if ($Parent -eq $Root) { break }
		    $Parent = ($Parent | Split-Path -Parent) -Replace ('\\','/')
		}
	    }
	    $ParentPermissions	= $Permissions | ? { $_.Path -eq $Parent }
	    $ParentGroups	= $ParentPermissions.Groups.Name | Sort-Object -Unique | Sort-Object -Descending
	    $CurrentGroups	= $Groups.Keys                   | Sort-Object -Unique | Sort-Object -Descending
	    $ParentUsers	= $ParentPermissions.Users.Name  | Sort-Object -Unique | Sort-Object -Descending
	    $CurrentUsers	= $Users.Keys                    | Sort-Object -Unique | Sort-Object -Descending
	    if ($ParentGroups -eq $CurrentGroups -And $ParentUsers -eq $CurrentUsers) {
		Write-Host -Back Black -Fore Cyan "Permissions are the same as parent directory. Skipping."
		continue
	    }
	    $Groups = ConvertFrom-EgnyteGroups $Groups $Permissions
	    $Users  = ConvertFrom-EgnyteUsers $Users $Groups
	    $Properties = @{
		Path    = $Path
		Groups  = $Groups
		Users   = $Users
	    }
	    $FolderPermissions = New-Object PSObject -Property $Properties
	    $Permissions += $FolderPermissions
	}
    }

    end {
	return $Permissions
    }
}
