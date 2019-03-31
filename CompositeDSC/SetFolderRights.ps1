configuration SetFolderRights 
{ 
   param 
   ( 

        [Parameter(Mandatory)]
        [String]$FirstGroupName,
        [Parameter(Mandatory)]
        [String]$SecondGroupName,

        [String]$PathOne = ("H:\$FirstGroupName" + "Data"),
        [String]$PathTwo = ("I:\$SecondGroupName" + "Data"),
        [Int]$RetryCount=80,
        [Int]$RetryIntervalSec=120

    ) 
    
    Import-DscResource -ModuleName xStorage,xSmbShare,PSDesiredStateConfiguration,cNtfsAccessControl,FileServerCompositeResource


    Node localhost
    {

        SetFileServer 'FileServerOne'

            {

                 FirstGroupName = $FirstGroupName
                 SecondGroupName = $SecondGroupName
            
            }

        xWaitForVolume 'FirstVolume' 
        
            {
                DriveLetter = 'H'
                RetryCount = $RetryCount
                RetryIntervalSec =$RetryIntervalSec
            }
        
        xWaitForVolume 'SecondVolume' 
        
            {
                DriveLetter = 'I'
                RetryCount = $RetryCount
                RetryIntervalSec =$RetryIntervalSec
            }
        
        
        cNtfsPermissionEntry 'FileShareRightsOne'

            {
                 Ensure = 'Present'
                 DependsOn = '[SetFileServer]FileServerOne','[xWaitForVolume]FirstVolume'
                 Principal = $FirstGroupName +'SecurityGroup'
                 Path = $PathOne
                 AccessControlInformation = @(

                       cNtfsAccessControlInformation

                       {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'ReadAndExecute'
                            Inheritance = 'ThisFolderSubfoldersAndFiles'
                            NoPropagateInherit = $false
                       }
                 )

            }


        cNtfsPermissionEntry 'FileShareRightsTwo'

            {
                 Ensure = 'Present'
                 DependsOn = '[SetFileServer]FileServerOne','[xWaitForVolume]SecondVolume' 
                 Principal = $SecondGroupName +'SecurityGroup'
                 Path = $PathTwo
                 AccessControlInformation = @(

                       cNtfsAccessControlInformation

                       {
                            AccessControlType = 'Allow'
                            FileSystemRights = 'ReadAndExecute'
                            Inheritance = 'ThisFolderSubfoldersAndFiles'
                            NoPropagateInherit = $false
                       }
                 )

            }

      }

}