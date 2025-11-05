AzureDiagnostics
| where ResourceType == "POSTGRESQLFLEXIBLESERVERS"
| sort by TimeGenerated desc
| take 50
SELECT version();