#requires -Version 2.0

#$PSVersionTable
<# 
.SYNOPSIS 
    Script Removes users in the "Remote Desktop users" group on a remote machines 

.DESCRIPTION 
    Removes User(s) access from specified WorkStation(s)

.EXAMPLE 
    .\remove_v4 "server1","server2","serverN" "user1","user2","userN" 

.Functionality 
    Takes Users and Workstations as command line arguments  
    Checks if users(in both AD and on the workstation) exists, if so removes else returns user does not exist

.NOTES 
    NAME: remove_v4 
    AUTHOR: Tshepo Kgiba 
    LASTEDIT: 17/04/2018 
    #Requires:
        Powershell -Version 2.0 
        ActiveDirectory Module
        Admin Access on the WorkStation
        localAccount Module
#>


if (Get-Module -ListAvailable -Name activedirectory) {
#    Write-Host "Module activedirectory exists"
} 
if (Get-Module -ListAvailable -Name localAccount) {
#    Write-Host "Module localAccount exists"
}
else {
    Write-Host "Ensure Modules activedirectory and localAccount version 1.6 are installed"
    Exit
}
Import-Module activedirectory
Import-Module localAccount

# Specifying arguments to taken
$comp = $args[0]
$UserIDs=$args[1]
[string]$IncidentNumber = $args[2]
$group = "Remote Desktop Users"

$expiryDate = (Get-Date).AddDays($NumberOfDays)
$expD = $expiryDate.ToString("yyyy/MM/dd")
$when = (Get-date).ToString("yyyy/MM/dd")

# specifying the username currently running the powershell script
$currentUser =  [Security.Principal.WindowsIdentity]::GetCurrent() | select Name


# creating an arraylist to hold users
$ArrayList = New-Object System.Collections.Generic.List[System.Object]

#Using local Global Catalog (GC) server to verify user
$LocalSite = (Get-ADDomainController -Discover).Site
$NewTargetGC = Get-ADDomainController -Discover -Service 6 -SiteName $LocalSite

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
 # remove user if exists in the "Remote Desktop Users" group           
foreach($com in $comp){

    
    if(Test-Connection -ComputerName $com -Count 2 -Quiet)
    {
         Write-Host "Connection established to $com"
         
         foreach($arr in $ArrayList)
         {

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
                      #Write-Host "User already exists in the group : $arr"
                     try
                      {
                          # specifying Remote Destop group on the workstation to which user will be removed 
                           $Groupname =[ADSI]"WinNT://$com/$group,group"
                      
                      
                          # specifying user to be removed
                           # Write-Verbose "Removing  : $($arr)" -Verbose
                           $usersExp = ([ADSI]"WinNT://$arr")
                      
                         # Removing user from the group
                           $Remove =  $Groupname.psbase.Invoke("Remove",($usersExp).path)
                           
                           if($Remove -eq $null)
                           {
                           
                            Write-Host "User Removed : $arr"
							$Global:SCCMSQLSERVER = "WIP-441005999\SQLEXPRESS"						   
							$Global:DBNAME = "WorkstationAccess"
							$SQLConnection = New-Object System.Data.SQLClient.SQLConnection
							$SQLConnection.ConnectionString ="server=$SCCMSQLSERVER;database=$DBNAME;Integrated Security=True;"
							$SQLConnection.Open()
							$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
							$SQLCommand.CommandText = "select * from Workstation_access where UserID='$arr' and Workstation='$com' and Exp_Indicator='ACTIVE'"
							$SQLCommand.Connection = $SQLConnection
							$Reader = $SQLCommand.ExecuteReader()
							$count = 0
							while ($Reader.Read()) {
																		
								$count = $count +1 
								
							}						
							$SQLConnection.close()
		
							if ($count -ge 1)	{								
								$SQLConnection.Open()
								$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
								$SQLCommand.CommandText = "update  Workstation_access set IncidentNo='$IncidentNumber',Expiry_date='$when',Exp_Indicator='EXPIRED'  where UserID='$arr' and Workstation='$com' and Exp_Indicator='ACTIVE'"
								Write-Host $SQLCommand.CommandText
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
								$SQLCommand.CommandText = "insert into Workstation_access (UserID,IncidentNo,Workstation,Expiry_date,Exp_Indicator) values ('$arr','$IncidentNumber','$com','$when','EXPIRED')"
								$SQLCommand.Connection = $SQLConnection									                
								$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
								$SqlAdapter.SelectCommand = $SQLCommand                 
								$SQLDataset = New-Object System.Data.DataSet
								$SqlAdapter.fill($SQLDataset) | out-null
								$SQLConnection.close()
								
							}
                           }
                           else
                           {
                                 Write-Host "Invalid!!!!"
                           }
                      
                      
                       }    
                       catch [System.Management.Automation.ExtendedTypeSystemException] 
                       {
                            Write-Host "$arr  does not exist on $com"
                            continue
                        }
                        catch [System.UnauthorizedAccessException]
                        {
                            Write-Host "You are not part of the admin group on $com"
                            break
                        }
                        catch [System.AccessViolationException]
                        {
                            Write-Host "You are not having Access in this machine : $com"
                            break
                        }
                  }
                  else
                  {
                      Write-Host "User does not exists in the group : $arr "

                  }
         }

        
    }
    else
    {
        Write-Host "Server not reachable : $com"
    }
}