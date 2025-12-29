---
publishDate: 2024-12-28T00:00:00Z
title: 'Building a High-Performance IP Scanner with Go and AWS Lambda'
excerpt: How we built an enterprise-scale vulnerability detection platform that scans 10,000+ IPs in under an hour using serverless architecture.
image: https://images.unsplash.com/photo-1558494949-ef010cbdcc31?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80
category: Security Engineering
tags:
  - golang
  - aws
  - lambda
  - security
  - automation
metadata:
  canonical: https://shernsecurity.com/ip-scanner-platform
---

## The Challenge

In enterprise environments, identifying vulnerabilities across thousands of IP addresses is a critical security function. Traditional scanning approaches are often slow, resource-intensive, and struggle to scale. We needed a solution that could:

- Scan 10,000+ IP addresses in under an hour
- Work both internally and externally
- Integrate with existing IPAM (IP Address Management) tools
- Capture compliance data like cookie consent screenshots
- Scale automatically based on demand

## From Python to Go: Performance Matters

The project started in Python, which provided rapid development and great libraries for network scanning. However, as we scaled to enterprise workloads, performance bottlenecks emerged. Converting to Go Lang delivered:

- **10x faster execution** - Go's concurrency model and compiled performance
- **Lower memory footprint** - Critical for Lambda functions
- **Better error handling** - Go's explicit error handling caught edge cases
- **Easier deployment** - Single binary with no dependency management

## Serverless Architecture: SQS + Lambda

The key architectural decision was embracing serverless:

```
┌─────────────┐
│   Trigger   │
│  (Schedule/ │
│   Manual)   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Scanner   │
│  Orchestrator│
│   (Lambda)  │
└──────┬──────┘
       │
       │ Splits IP ranges
       ▼
┌─────────────┐
│     SQS     │
│    Queue    │
└──────┬──────┘
       │
       │ Parallel processing
       ▼
┌─────────────┐       ┌─────────────┐
│   Worker    │  ...  │   Worker    │
│  Lambda(s)  │       │  Lambda(s)  │
└──────┬──────┘       └──────┬──────┘
       │                     │
       ▼                     ▼
┌──────────────────────────────┐
│      Results Aggregator      │
│         (DynamoDB)           │
└──────────────────────────────┘
```

### Why This Works

1. **Parallel Processing**: Lambda functions can process hundreds of IPs simultaneously
2. **Cost Efficiency**: Pay only for execution time, no idle resources
3. **Auto-scaling**: AWS handles all scaling automatically
4. **Fault Tolerance**: Failed scans automatically retry via SQS

## Key Features

### 1. IPAM Integration

The scanner integrates with enterprise IPAM tools to:
- Fetch current IP allocations
- Update vulnerability findings
- Track remediation status
- Generate compliance reports

### 2. Dual-Mode Scanning

**External Mode**: Scans from outside the corporate network
- Identifies publicly exposed vulnerabilities
- Tests perimeter defenses
- Validates firewall rules

**Internal Mode**: Scans from within the network
- Finds internal misconfigurations
- Checks for lateral movement risks
- Validates segmentation

### 3. Compliance Automation

Automated screenshot capture for:
- Cookie consent validation
- Banner compliance
- UI/UX security checks
- Regulatory documentation

Uses headless Chrome in Lambda to capture full-page screenshots.

### 4. Results Aggregation

Real-time aggregation provides:
- Vulnerability trending
- Risk scoring
- Asset inventory updates
- Executive dashboards

## Technical Deep Dive

### Go Lambda Handler

```go
func handler(ctx context.Context, event events.SQSEvent) error {
    for _, record := range event.Records {
        var scanRequest ScanRequest
        json.Unmarshal([]byte(record.Body), &scanRequest)
        
        results := performScan(scanRequest)
        storeResults(results)
    }
    return nil
}
```

### Concurrent Scanning

```go
func scanIPRange(ipRange []string) []ScanResult {
    resultsChan := make(chan ScanResult)
    var wg sync.WaitGroup
    
    for _, ip := range ipRange {
        wg.Add(1)
        go func(ip string) {
            defer wg.Done()
            result := scanIP(ip)
            resultsChan <- result
        }(ip)
    }
    
    go func() {
        wg.Wait()
        close(resultsChan)
    }()
    
    results := []ScanResult{}
    for result := range resultsChan {
        results = append(results, result)
    }
    return results
}
```

## Performance Results

- **10,000 IPs scanned in 45 minutes**
- **Average cost: $2.50 per scan**
- **99.9% success rate**
- **Zero maintenance overhead**

## Lessons Learned

1. **Start simple, optimize later**: Python prototype validated the concept
2. **Serverless isn't always the answer**: But it's perfect for bursty workloads
3. **Monitoring is critical**: CloudWatch metrics caught issues before users did
4. **Go's concurrency is powerful**: But requires careful error handling
5. **Cost optimization matters**: Right-sizing Lambda memory saved 40%

## What's Next

Future enhancements include:
- Machine learning for vulnerability prioritization
- Automated remediation workflows
- Integration with security orchestration platforms
- Real-time alerting for critical findings

## Conclusion

Building this platform taught valuable lessons about:
- Serverless architecture at scale
- Go performance optimization
- Enterprise security automation
- Cloud cost management

The result is a tool that security teams use daily to maintain visibility and reduce risk across enterprise networks.

---

*Interested in building similar security automation? [View my resume](/resume) or [reach out](/contact).*
