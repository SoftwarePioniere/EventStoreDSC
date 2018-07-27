Configuration Sample1
{
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName EventStoreDSC

    Node $AllNodes.NodeName
    {
        foreach($clusterNode in $Node.ClusterNodes) {
            EventStoreNode ('esNode_' + $clusterNode.ProjectName)
            {
                RootDrive = $Node.RootDrive
                ExtIp = $Node.ExtIp
                UseSecure = $false
                IsClusterNode = $true
                CheckRunning = $true
                ClusterSize = $Node.ClusterSize

                ProjectName =    $clusterNode.ProjectName
                IntHttpPort = $clusterNode.IntHttpPort
                ExtHttpPort = $clusterNode.ExtHttpPort
                IntTcpPort = $clusterNode.IntTcpPort
                ExtTcpPort = $clusterNode.ExtTcpPort
                ExtSecureTcpPort = $clusterNode.ExtSecureTcpPort

                GossipSeed = $clusterNode.GossipSeed
          }
        }
    }
}

$MyData =
@{
    AllNodes =
    @(
        @{
            NodeName    = 'localhost'
            ExtIp       = '127.0.0.1'
            RootDrive   = 'c:'
            ClusterSize = '3'

            ClusterNodes = @(
                @{
                    ProjectName = 'cluster1-node1'
                    IntTcpPort  = '3111'
                    ExtTcpPort  = '3112'
                    IntHttpPort = '3113'
                    ExtHttpPort = '3114'
                    GossipSeed = '127.0.0.1:3123,127.0.0.1:3133'
                },
                @{
                    ProjectName = 'cluster1-node2'
                    IntTcpPort  = '3121'
                    ExtTcpPort  = '3122'
                    IntHttpPort = '3123'
                    ExtHttpPort = '3124'
                    GossipSeed = '127.0.0.1:3113,127.0.0.1:3133'
                },
                @{
                    ProjectName = 'cluster1-node3'
                    IntTcpPort  = '3131'
                    ExtTcpPort  = '3132'
                    IntHttpPort = '3133'
                    ExtHttpPort = '3134'
                    GossipSeed = '127.0.0.1:3113,127.0.0.1:3123'
                }
            )
        }
    )
}

Sample1 -Verbose -ConfigurationData $MyData
Start-DscConfiguration .\Sample1 -Wait -Force -Verbose -Debug

Start-Process "http://127.0.0.1:3114"
Start-Process "http://127.0.0.1:3124"
Start-Process "http://127.0.0.1:3134"