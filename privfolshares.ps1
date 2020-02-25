Import-Module ActiveDirectory
	$path = "\\fileserver01\Shared\"
	$newFolderName = Read-Host -Prompt "Enter Name of New Folder"
	$newFolderFull = $path + $newFolderName
	Write-Output "New Folder will be: $newFolderFull"
	$confirm = Read-Host "Confirm? Y/N"

If(($confirm) -ne "y")
{
 # End
}

Else
{
	Write-Output "Create AD Groups"
	$groupnameRW = "Shared.$newFolderName.RW"
	$groupnameR = "Shared.$newFolderName.R"
		New-AdGroup $groupNameRW -samAccountName $groupNameRW -GroupScope DomainLocal -path "OU=NTFS Groups,DC=TR12R,DC=local"
		New-AdGroup $groupNameR -samAccountName $groupNameR -GroupScope DomainLocal -path "OU=NTFS Groups,DC=TR12R,DC=local"
	Write-Output "Add Folder"
	New-Item $newFolderFull -ItemType Directory
	Write-Output "Remove Inheritance"
		icacls $newFolderFull /inheritance:d
	# Rights
		$readOnly = [System.Security.AccessControl.FileSystemRights]"ReadAndWrite"
		$readWrite = [System.Security.AccessControl.FileSystemRights]"Modify"
	# Inheritance
		$inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	# Propagation
		$propagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	# User
		$userRW = New-Object System.Security.Principal.NTAccount($groupNameRW)
		$userR = New-Object System.Security.Principal.NTAccount($groupNameR)
	# Type
		$type = [System.Security.AccessControl.AccessControlType]::Allow
		$accessControlEntryDefault = New-Object System.Security.AccessControl.FileSystemAccessRule @("Domain Users", $readOnly, $inheritanceFlag, $propagationFlag, $type)
		$accessControlEntryRW = New-Object System.Security.AccessControl.FileSystemAccessRule @($userRW, $readWrite, $inheritanceFlag, $propagationFlag, $type)
		$accessControlEntryR = New-Object System.Security.AccessControl.FileSystemAccessRule @($userR, $readOnly, $inheritanceFlag, $propagationFlag, $type)
		$objACL = Get-ACL $newFolderFull
		$objACL.RemoveAccessRuleAll($accessControlEntryDefault)
		$objACL.AddAccessRule($accessControlEntryRW)
		$objACL.AddAccessRule($accessControlEntryR)
		Set-ACL $newFolderFull $objACL
}