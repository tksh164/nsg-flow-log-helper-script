param (
    [Parameter(Mandatory = $true)]
    [string[]] $NsgFlowLogJsonFilePath
)

$NsgFlowLogJsonFilePath | ForEach-Object -Process {
    $logFilePath = $_
    Get-Content -Raw -LiteralPath $logFilePath | ConvertFrom-Json | ForEach-Object -Process {
        $nsgFlowLog = $_
        $nsgFlowLog.records | Foreach-Object -Process {
            $record = $_
            $record.properties.flows | ForEach-Object -Process {
                $flowsByRule = $_
                $flowsByRule.flows | ForEach-Object -Process {
                    $flow = $_
                    $flow.flowTuples | ForEach-Object -Process {
                        $flowTuple = $_
                        $flowTuplePros = $flowTuple.Split(',')
                        [PSCustomObject]@{
                            Time               = $record.time
                            Rule               = $flowsByRule.Rule
                            SourceIP           = $flowTuplePros[1]
                            DestinationIP      = $flowTuplePros[2]
                            SourcePort         = $flowTuplePros[3]
                            DestinationPort    = $flowTuplePros[4]
                            Protocol           = if ($flowTuplePros[5] -eq 'T') { 'TCP' } elseif ($flowTuplePros[5] -eq 'U') { 'UDP' } else { 'Unknown ({0})' -f $flowTuplePros[5] }
                            TrafficFlow        = if ($flowTuplePros[6] -eq 'I') { 'Inbound' } elseif ($flowTuplePros[6] -eq 'O') { 'Outbound' } else { 'Unknown ({0})' -f $flowTuplePros[6] }
                            TrafficDecision    = if ($flowTuplePros[7] -eq 'A') { 'Allowed' } elseif ($flowTuplePros[7] -eq 'D') { 'Denied' } else { 'Unknown ({0})' -f $flowTuplePros[7] }
                            FlowState          = if ($flowTuplePros[8] -eq 'B') { 'Begin' } elseif ($flowTuplePros[8] -eq 'C') { 'Continuing' } elseif ($flowTuplePros[8] -eq 'E') { 'End' } else { 'Unknown ({0})' -f $flowTuplePros[8] }
                            PacketsSent        = $flowTuplePros[9]
                            BytesSent          = $flowTuplePros[10]
                            PacketsReceived    = $flowTuplePros[11]
                            BytesReceived      = $flowTuplePros[12]
                            SystemId           = $record.systemId
                            MacAddress         = $record.macAddress
                            Category           = $record.category
                            ResourceId         = $record.resourceId
                            OperationName      = $record.operationName
                            LogSchemaVersion   = $record.properties.Version
                            Mac                = $flow.mac
                            FlowTupleRaw       = $flowTuple
                            UnixEpochTimestamp = $flowTuplePros[0]
                        }
                    }
                }
            }
        }
    }
}
