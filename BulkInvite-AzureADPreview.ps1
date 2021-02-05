Connect-AzureAD -TenantDomain <YOUR_SOURCE_TENANT_DOMAIN>

# Get the group name and pull the object id
$groupId = Get-AzureADGroup -SearchString "Contoso IT" | Select -ExpandProperty ObjectId

# Get users within the group
Get-AzureADGroupMember -ObjectId $groupId | Select-Object -Property DisplayName, UserPrincipalName | Export-Csv -Path .\invitations.csv -NoTypeInformation

Disconnect-AzureAD

Connect-AzureAD -TenantDomain <YOUR_TARGET_TENANT_DOMAIN>

$invitations = Import-Csv .\invitations.csv

$groupName = "Cloud Contributors"
$groupId = Get-AzureADGroup -SearchString $groupName | Select -ExpandProperty ObjectId

foreach ($invitee in $invitations)
{
    Write-Host "Inviting" $invitee.UserPrincipalName "to tenant"

    $guest = New-AzureADMSInvitation `
        -InvitedUserEmailAddress $invitee.UserPrincipalName `
        -InvitedUserDisplayName $invitee.DisplayName `
        -InviteRedirectUrl https://portal.azure.com/ `
        -SendInvitationMessage $false 
  
    if ((Get-AzureADUserMembership -ObjectId $guest.InvitedUser.Id | Where ObjectId -eq $groupId).Length -eq 0)
    {
        Write-Host "Adding" $invitee.UserPrincipalName "to" $groupName "group"
        Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $guest.InvitedUser.Id
    }
    else
    {
        Write-Host $invitee.UserPrincipalName "already exists in" $groupName "group"
    }
}

Disconnect-AzureAD

# Users will need to log into https://portal.azure.com/<YOUR_TARGET_TENANT_ID>