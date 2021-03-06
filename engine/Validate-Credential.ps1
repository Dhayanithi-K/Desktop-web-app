#function Validate-Credential([String]$UserName,[String]$Password){
#<#
 #.Sysnopsis
 #this fuction takes user credentials as a paremeter and verifies them
 #.Example
 #$cred = (Get-Credential)
 #$validate = Validate-Credential $cred

#>


  #      $UserName = Read-Host "Enter Username -> domain\UserId"
   #     $Password = Read-Host "Enter Password" #-AsSecureString
	#	Write-Output "$UserName"
	#	Write-Output "$Password"
	#	
     #   Add-Type -assemblyname System.DirectoryServices.AccountManagement
      #  $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
       # Try {
        #$ValidCredential = $DS.ValidateCredentials($UserName, $Password)
		#Write-Output "COOL"
        #} Catch {
        #if the account does not have required logon rights to the local machine, validation failed.
		#Write-Output "FAIL"
        #$ValidCredential = $false
        #}
 #       Return $ValidCredential
#}
# Validate-Credential($User,$Pass)
#>
$UserName = $args[0]
$Password = $args[1]

#Write-Output "$UserName"
#Write-Output "$Password"

Add-Type -assemblyname System.DirectoryServices.AccountManagement
$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
Try {
$ValidCredential = $DS.ValidateCredentials($UserName, $Password)

} Catch {
#if the account does not have required logon rights to the local machine, validation failed.
$ValidCredential = $false
}
#Return $ValidCredential
Write-Output "$ValidCredential"
