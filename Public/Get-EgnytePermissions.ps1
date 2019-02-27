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
	    if ($Path -match '.*\.Temporaryitems.*|.*\.Trashes.*') {
		continue
	    }

	    Write-Host -Back Black -Fore Green "Getting Egnyte permissions for $Path..."
	    $Folder = Get-EgnyteChildItem -Path $Path -Session $Session -Perms

	    $Groups = $Folder.groupPerms | ConvertTo-HashTable
	    $Groups.Remove('All Administrators')
	    $Users  = $Folder.userPerms  | ConvertTo-HashTable
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
