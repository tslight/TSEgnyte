
<a id='public'></a>
## PUBLIC COMMANDS

| **COMMAND** | **PARAMETER** |
|:------------|:--------------|
| `Compare-EgnyteADUsers` | `User` |
 |	| `Instance` |
| `ConvertFrom-EgnyteGroups` | `Groups` |
 |	| `Permissions` |
| `ConvertFrom-EgnyteUsers` | `Users` |
 |	| `Groups` |
| `Export-EgnyteADUsers` | `InputCsv` |
 |	| `ExportPath` |
 |	| `Name` |
 |	| `Session` |
 |	| `FromEmailColumn` |
 |	| `SingleWorksheet` |
 |	| `CorrectlyChargedUsers` |
 |	| `IncorrectlyChargedUsers` |
 |	| `Force` |
| `Export-EgnytePermissions` | `Permissions` |
 |	| `Path` |
 |	| `Name` |
| `Export-EgnyteUsers` | `Path` |
 |	| `Session` |
 |	| `Name` |
| `Get-EgnyteADUser` | `ADUser` |
 |	| `Session` |
| `Get-EgnyteADUsersFromEmail` | `EmailAddress` |
 |	| `Session` |
| `Get-EgnyteChildItem` | `Path` |
 |	| `Session` |
 |	| `Perms` |
| `Get-EgnyteFolders` | `Path` |
 |	| `Session` |
 |	| `Depth` |
 |	| `IncludeParent` |
| `Get-EgnyteFolderStats` | `Path` |
 |	| `Session` |
| `Get-EgnytePaidDisabledUsers` | `Session` |
| `Get-EgnytePaidUsers` | `Session` |
 |	| `Users` |
| `Get-EgnytePermissions` | `Root` |
 |	| `Session` |
 |	| `Depth` |
| `Get-EgnyteSession` | `Instance` |
 |	| `Username` |
 |	| `JsonSessionsDir` |
| `Get-EgnyteUsers` | `Session` |
 |	| `StartIndex` |
 |	| `Filter` |
 |	| `UserName` |
 |	| `Email` |
 |	| `ExternalId` |
| `Import-EgnyteUsersFromCsv` | `InputCsv` |

<a id='private'></a>
## PRIVATE FUNCTIONS

| **COMMAND** | **PARAMETER** |
|:------------|:--------------|
| `Get-EgnyteHeaders` | `Token` |
| `New-EgnyteRequest` | `Method` |
 |	| `Session` |
 |	| `Resource` |
 |	| `OutFile` |
 |	| `InFile` |
| `New-EgnyteSession` | `Username` |
 |	| `Password` |
 |	| `Instance` |
 |	| `APIKey` |
 |	| `JsonSessionDir` |
