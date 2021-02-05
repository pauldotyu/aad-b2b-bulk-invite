# Bulk invite Azure AD B2B Users

## Scenario

* Organization has multiple Azure AD tenants
* One of the tenants is being sync'd from an on-premises AD using Azure AD Connect
	* This will be considered the `source` tenant
* Users in the **source** tenant need to be able to manage Azure resources in subscriptions that trust a different Azure AD tenant
	* This will be considered the `target` tenant
* Azure AD B2C functionality wiill be used to allow users from the `source` tenant to manage resources in the `target` tenant
	* Users from the `source` tenant can be invited as guests in the `target` tenant

## References:
* [Add B2B collaboration guest users without an invitation link or email](https://docs.microsoft.com/en-us/azure/active-directory/external-identities/add-user-without-invite)
* [Microsoft Graph > v1.0 reference > Identity and access > Identity and sign-in > Invitation manager > Create invitation
](https://docs.microsoft.com/en-us/graph/api/invitation-post?view=graph-rest-1.0&tabs=http)
* [Quickstart: Add a guest user with PowerShell](https://docs.microsoft.com/en-us/azure/active-directory/external-identities/b2b-quickstart-invite-powershell)
* [Tutorial: Use PowerShell to bulk invite Azure AD B2B collaboration users](https://docs.microsoft.com/en-us/azure/active-directory/external-identities/bulk-invite-powershell)
* [Tutorial: Use Azure portal to bulk invite Azure AD B2B collaboration users](https://docs.microsoft.com/en-us/azure/active-directory/external-identities/tutorial-bulk-invite)
* [Create an Azure service principal with Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-5.4.0)

## Prerequisite

* In the `source` tenant, create a new group, assign members into this group that you would like to grant RBAC to in the `target` tenant
* In the `target` tenant, create a new group, assign the group proper RBAC permissions to manage resources within Azure subscriptions. Ideally, RBAC at management group scope would be best.

## Make sure you have the proper PowerShell modules

```powershell
# Check if you have the latest AzureADPreview module
Get-Module -ListAvailable AzureAD*

# If you don't have the module, then go install it
Install-Module AzureADPreview

# Make sure you have the modules imported
Import-Module AzureAD
Import-Module AzureADPreview
```

### The PowerShell script assumes you have the ability to access both tenants. Make sure to sign into the right tenant using the `-TenantDomain` switch as you export users and invite users

```powershell
Connect-AzureAD -TenantDomain "<Tenant_Domain_Name>"
```

### If you will be inviting using Microsoft Graph, you should create a service principal and grant it proper permissions to add guest users. You should grant the service principal the `Guest Inviter` role within Azure AD

```powrshell
Install-Module -Name Az -AllowClobber -Scope CurrentUser
$sp = New-AzADServicePrincipal -DisplayName GuestInviterSP
```