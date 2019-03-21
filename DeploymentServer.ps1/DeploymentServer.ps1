Configuration WindowsDeploymentServices
{
    param ($MachineName)

    Node $MachineName
    { 
        #Install Windows Deployment Services
        WindowsFeature WDS
        {
          Ensure = "Present"
          Name = "WDS-Deployment"
        }
    }
}
