#Requires -Modules activedirectory
#Requires -Modules localAccount
#Requires -Module localAccount
#Requires -Version 2.0

<# 
.SYNOPSIS 
    Script Adds users to the "Remote Desktop users" group on a remote machines 

.DESCRIPTION 
    Adds User(s) to specified WorkStation(s)


.EXAMPLE 
    .\Add_10 "server1","server2","serverN" "user1","user2","userN" 10

.Functionality 
    Takes Users, Workstations and Expiry date(in days) as command line arguments  
    Checks if users(in both AD and on the workstation) exists, if so adds else returns already exists
    When user's date expires, user access on the WorkStation will be removed    

.NOTES 
    NAME: Add_10 
    AUTHOR: Tshepo Kgiba 
    LASTEDIT: 17/04/2018 
    #Requires:
        Powershell -Version 2.0 
        ActiveDirectory Module
        Admin Access on the WorkStation
        localAccount Module
#>
# $username = 'sbicza01\c800557'
# $password = 'Nov@2018'
#  
# # Convert to a single set of credentials
# $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
# $credential = New-Object System.Management.Automation.PSCredential $username, $securePassword
#  
# # Launch PowerShell (runas) as another user
# Start-Process powershell.exe -Credential $credential -WindowStyle Maximized

if (Get-Module -ListAvailable -Name activedirectory) {
#    Write-Host "Module activedirectory exists"
} 
if (Get-Module -ListAvailable -Name localAccount) {
#    Write-Host "Module localAccount exists"
}
else {
    Write-Host "Module localAccount does not exists."
	$selfPath = (Get-Item -Path "." -Verbose).FullName	
	$dllRelativePath = "\Modules"	
	$dllAbsolutePath = Join-Path $selfPath $dllRelativePath
	Write-Host $dllAbsolutePath
	$env:PSModulePath
	$env:PSModulePath = $env:PSModulePath + ";"+$dllAbsolutePath
	if (Get-Module -ListAvailable -Name localAccount) {
	   Write-Host "Module Added"
	}
	else
	{
	Write-Host "Module Added Fail"
	}
    # Exit
}
Import-Module activedirectory
Import-Module localAccount


# [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Specifying arguments to taken
[string[]]$comp = $args[0]
[string[]]$UserIDs = $args[1]
[int]$NumberOfDays = $args[2]
[string]$IncidentNumber = $args[3]

# specifying the username currently running the powershell script
$currentUser =  [Security.Principal.WindowsIdentity]::GetCurrent() | select Name

# specifying group to which user(s) are to be added to on a remote machine
$group = "Remote Desktop Users"


# create expiry date and current date variables
$expiryDate = (Get-Date).AddDays($NumberOfDays)
$expD = $expiryDate.ToString("yyyy/MM/dd")
$when = (Get-date).ToString("yyyy/MM/dd")


# Using local Global Catalog (GC) server to verify user
$LocalSite = (Get-ADDomainController -Discover).Site
$NewTargetGC = Get-ADDomainController -Discover -Service 6 -SiteName $LocalSite

# creating an arraylist to hold users
$ArrayList = New-Object System.Collections.Generic.List[System.Object]


foreach ($UserID in $UserIDs)
        {
           if (!$NewTargetGC)
           { $NewTargetGC = Get-ADDomainController -Discover -Service 6 -NextClosestSite }
           $NewTargetGCHostName = $NewTargetGC.HostName
           $LocalGC = “$NewTargetGCHostName” + “:3268”

# fetches user from domain forrest if exits, if so adds user to $ArrayList variable         
           $U = Get-ADUser -Server $LocalGC -Filter {sAMAccountName -eq $UserID } | Select sAMAccountName
           
               if($U -ne $null)
               {
                   $U = $UserID
                   
                   $ArrayList.Add($U)
                   
                      
               }
               else
               {
                   Write-Host "Invalid User : $UserID"
               }
        }

# Looping and ping workstation, if ping is successfull proceeds to attempt to 
# add user if does not exists in the "Remote Desktop Users" group           
foreach($com in $comp){

    
    if(Test-Connection -ComputerName $com -Count 2 -Quiet)
    {
         # Write-Host "Connection established to $com"

         #Write-Host "Progressing Request.."
         foreach($arr in $ArrayList)
         {

                  # specifying Remote Desktop group on the workstation to which user will be added  
                  $Groupname =[ADSI]"WinNT://$com/$group,group"
                  
                  try
                  {
                  $members = Get-LocalGroupMember -Name $group  -Computername $com
                  }
                      catch [System.Management.Automation.MethodInvocationException]
                  {
                      Write-host "Problem encountered while verifying user on machine"
                      break
                  }  
                  
                  if($members -contains $arr)
                  {						
						
						$Global:SCCMSQLSERVER = "PSDC-SF002FAPV\DADB001"						   
						$Global:DBNAME = "WorkstationAccess"
						$SQLConnection = New-Object System.Data.SQLClient.SQLConnection
						$SQLConnection.ConnectionString ="server=$SCCMSQLSERVER;database=$DBNAME;Integrated Security=True;"
						$SQLConnection.Open()
						$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
						$SQLCommand.CommandText = "select Expiry_date from Remote_Workstation where UserID='$arr' and Workstation='$com' and Exp_Indicator='ACTIVE'"
						$SQLCommand.Connection = $SQLConnection
						$Reader = $SQLCommand.ExecuteReader()
						$count = 0
						while ($Reader.Read()) {
									
							$exp=$Reader.GetValue(0)
							$count = $count +1 
							
						}						
						$SQLConnection.close()
	
						if ($count -ge 1)	{
							$Temp = [datetime]::ParseExact($exp,"yyyy/MM/dd",$null)
							$Temp = $Temp.AddDays($NumberOfDays)
							$expD = $Temp.ToString("yyyy/MM/dd") 							
							$SQLConnection.Open()
							$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
							$SQLCommand.CommandText = "update  Remote_Workstation set IncidentNo='$IncidentNumber',Access_Received_on ='$when',Expiry_date='$expD'  where UserID='$arr' and Workstation='$com' and Exp_Indicator='ACTIVE'"
							$SQLCommand.Connection = $SQLConnection
							$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
							$SqlAdapter.SelectCommand = $SQLCommand                 
							$SQLDataset = New-Object System.Data.DataSet
							$SqlAdapter.fill($SQLDataset) | out-null
							$SQLConnection.close()								
							
						}
						else	{

							$SQLConnection.Open()
							$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
							$SQLCommand.CommandText = "insert into Remote_Workstation (UserID,IncidentNo,Workstation,Access_Received_on,Expiry_date,Exp_Indicator) values ('$arr','$IncidentNumber','$com','$when','$expD','ACTIVE')"
							$SQLCommand.Connection = $SQLConnection									                
							$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
							$SqlAdapter.SelectCommand = $SQLCommand                 
							$SQLDataset = New-Object System.Data.DataSet
							$SqlAdapter.fill($SQLDataset) | out-null
							$SQLConnection.close()
							
						}
						Write-Host "$arr already exists in the group"
                      
                  }
                  else
                  {
                      #Write-Host "User does not exists in the group : $arr "
                      
                      try
                      {
                      # specifying user to be added
                       #Write-Verbose "Adding  : $($arr)" -Verbose
                      $usersExp = ([ADSI]"WinNT://$arr")
                      
                      # Adding user from the group
                      $add =  $Groupname.psbase.Invoke("Add",($usersExp).path)
                      
                          if($add -eq $null)
                          {
                          
                           Write-Host "User Added : $arr "
                          
                           # on succefull adding of user, adding user to database and also specifying expiry date of access in the DB
                           $Global:SCCMSQLSERVER = "PSDC-SF002FAPV\DADB001"
                           #$Global:SCCMSQLSERVER = "WIP-441005999\SQLEXPRESS"						   
				           $Global:DBNAME = "WorkstationAccess"
				               try
				               {
				                $SQLConnection = New-Object System.Data.SQLClient.SQLConnection
				                $SQLConnection.ConnectionString ="server=$SCCMSQLSERVER;database=$DBNAME;Integrated Security=True;"
				                $SQLConnection.Open()
				               }
				               catch
				               {
				                   [System.Windows.Forms.MessageBox]::Show("Failed to connect SQL Server:")
				               }
                                        
				               $SQLCommand = New-Object System.Data.SqlClient.SqlCommand
				               $SQLCommand.CommandText = "insert into Remote_Workstation (UserID,IncidentNo,Workstation,Access_Received_on,Expiry_date,Exp_Indicator) values ('$arr','$IncidentNumber','$com','$when','$expD','ACTIVE')"
				               $SQLCommand.Connection = $SQLConnection
                                        
				               $SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
				               $SqlAdapter.SelectCommand = $SQLCommand                 
				               $SQLDataset = New-Object System.Data.DataSet
				               $SqlAdapter.fill($SQLDataset) | out-null
                                        
				               $SQLConnection.close()
                          }
                          else
                          {
                              Write-Host "invalid!!!!"
                          }
                      
                      
                      } 
                      catch [System.Management.Automation.MethodInvocationException] 
                      {
                          Write-Host "Problem encountered while verifying user on machine"
                          break
                      }
                      catch [System.UnauthorizedAccessException]
                      {
                          Write-Host "You are not part of the admin group on $com"
                          break
                      }
                      catch [System.AccessViolationException]
                      {
                          Write-Host "You are not having Access in this machine: $com"
                          break
                     }
               }
         }

        
    }
    else
    {
        Write-Host "Server not reachable : $com"
    }
}