function Get-EgnytePermissions {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(ValueFromPipeline)]
	[string]$Root="/Shared",
	[Parameter(Mandatory)]
	[object]$Session,
	[int]$Depth=0
    )

    process {
	$Params     = @{
	    Path    = $Root
	    Session = $Session
	    Depth   = $Depth
	}
	$msg = (
	    "Getting $Depth levels of folders starting at $Root..."
	)
	Write-Host -Back Black -Fore Magenta $msg
	$Folders = Get-EgnyteFolders @Params

	foreach ($Path in $Folders) {
	    if ($Path -match '.*\.Temporaryitems.*|.*\.Trashes.*') {
		continue
	    }

	    Write-Host -Back Black -Fore Green "Getting perms for $Path"
	    $Folder = Get-EgnyteChildItem -Path $Path -Session $Session -Perms

	    $Groups = $Folder.groupPerms |
	      Select-Object -ExcludeProperty 'All Administrators' |
	      ConvertTo-HashTable
	    $Users  = $Folder.userPerms |
	      Select-Object -ExcludeProperty 'All Administrators' |
	      ConvertTo-HashTable
	    # $Groups = ConvertFrom-EgnyteGroups $Groups $Perms
	    # $Users  = ConvertFrom-EgnyteUsers $Users $Groups

	    $Properties = @{
		Path    = $Path
		Groups  = $Groups
		Users   = $Users
	    }

	    New-Object PSObject -Property $Properties
	}
    }
}
