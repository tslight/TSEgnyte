function Export-EgnytePermissions {
    [CmdletBinding(SupportsShouldProcess)]
    Param (
	[Parameter(Mandatory,ValueFromPipeline)]
	[object[]]$Permissions,
	[Parameter(Mandatory)]
	[System.IO.FileInfo]$Path,
	[Parameter(Mandatory)]
	[string]$Name
    )

    begin {
	$Sheet1 = @()
	$Sheet2 = @()
	$VbaCode = @"
Private Sub Worksheet_SelectionChange(ByVal Target As Range)
If Intersect(Target, Range("B:E")) Is Nothing Then
Else
If IsNumeric(ActiveCell.Value) And ActiveCell.Value > 0 Then
Worksheets("Permissions").Columns(7).ClearContents

MyRow = ActiveCell.Row
MyCol = ActiveCell.Column

Dim LArray() As String
Dim value1 As String

value1 = ThisWorkbook.Sheets(2).Cells(MyRow - 1, MyCol)
value1 = value1 & "|"
LArray = Split(value1, "|")

Dim TopRow As Long
With ActiveWindow.VisibleRange
TopRow = .Row
End With

For R = 0 To UBound(LArray) - 1
Dim Row As Long
If TopRow > 2 Then
Row = TopRow + R
Else
Row = TopRow + R + 2
End If
Cells(Row, 7).Value = LArray(R)
Next
Else
Worksheets("Permissions").Columns(7).ClearContents
End If
End If
End Sub
"@
    }

    process {
	$Owners  = $Permissions.Users | ? { $_.Values -eq 'Owner' }
	$Full    = $Permissions.Users | ? { $_.Values -eq 'Full' }
	$Editors = $Permissions.Users | ? { $_.Values -eq 'Editor' }
	$Viewers = $Permissions.Users | ? { $_.Values -eq 'Viewer' }
	$Perms = New-Object PSObject
	$Perms | Add-Member -MemberType NoteProperty -Name 'Folder Name' -Value $Permissions.Path
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
	$Users | Add-Member -MemberType NoteProperty -Name 'Folder Name' -Value $Permissions.Path
	$Users | Add-Member -MemberType NoteProperty -Name 'Owners' -Value $OwnersStr
	$Users | Add-Member -MemberType NoteProperty -Name 'Full' -Value $FullStr
	$Users | Add-Member -MemberType NoteProperty -Name 'Editor' -Value $EditorsStr
	$Users | Add-Member -MemberType NoteProperty -Name 'Viewer' -Value $ViewersStr
	$Sheet2 += $Users
    }

    end {
	try {
	    $Sheet2 | Export-Csv "$Path\Data.csv" -NoTypeInformation
	    $Sheet1 | Export-Csv "$Path\Permissions.csv" -NoTypeInformation
	} catch {
	    Write-Warning "Failed to create Csvs.`n$($_)"
	    throw
	}

	try {
	    Get-ChildItem "$Path\*.csv" | Convert-CsvToXls -Xlsx "$Path\$Name"
	    Remove-Item "$Path\*.csv"
	} catch {
	    Write-Warning $_.InvocationInfo.ScriptName
	    Write-Warning $_.InvocationInfo.Line
	    Write-Warning $_.Exception.Message
	    throw
	}

	try {
	    Add-XlsTitleRow "$Path\$Name.Xlsx" "$Name Permissions - Click count to view users"
	    Add-VbaToXls "$Path\$Name.Xlsx" $VbaCode
	    Remove-Item "$Path\$Name.Xlsx"
	} catch {
	    Write-Warning $_.InvocationInfo.ScriptName
	    Write-Warning $_.InvocationInfo.Line
	    Write-Warning $_.Exception.Message
	}
    }
}
