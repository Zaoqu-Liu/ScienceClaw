# devtu-auto-discover-apis — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Quality Gates

### Gate 1: Post-Discovery (Human Approval)

**Review**: discovery_report.md

**Decision**:
- ✅ Approve: Prioritization looks good → proceed to creation
- 🔄 Modify: Change priorities, focus domains
- ❌ Abort: No suitable APIs found

### Gate 2: Post-Creation (Human Approval)

**Review**: Generated .py and .json files

**Decision**:
- ✅ Approve: Implementation looks good → proceed to validation
- 🔄 Modify: Adjust parameters, schemas, examples
- ❌ Abort: API integration not feasible

### Gate 3: Post-Validation (Human Approval)

**Review**: validation_report.md

**Decision**:
- ✅ Approve: All tests passing → proceed to integration
- 🔄 Fix: Apply devtu-fix-tool patterns, retry validation
- ❌ Abort: Fundamental issues with API

### Gate 4: Pre-PR (Human Approval)

**Review**: Full PR description

**Decision**:
- ✅ Approve: Create PR and push
- 🔄 Modify: Edit commit messages, PR description
- ❌ Abort: Not ready for integration

---

## Common Patterns

### Pattern 1: Batch Processing

Process multiple APIs in one execution:

```
Discovery → [API1, API2, API3] → Create All → Validate All → Single PR
```

**Benefits**: Efficient, cohesive PR
**Use When**: APIs from same domain, similar structure

### Pattern 2: Iterative Single-API

Process one API at a time with validation:

```
Discovery → API1 → Create → Validate → Integrate
         → API2 → Create → Validate → Integrate
```

**Benefits**: Catch issues early, smaller PRs
**Use When**: APIs have complex authentication, novel patterns

### Pattern 3: Discovery-Only Mode

Just discover and document APIs, create tools later:

```
Discovery → Generate Report → [Manual Review] → Schedule Implementation
```

**Benefits**: Rapid survey of landscape
**Use When**: Planning long-term roadmap, research phase

### Pattern 4: Validation-Only Mode

Validate previously created tools:

```
[Existing Tools] → Validation → Fix Issues → Re-validate → Report
```

**Benefits**: Quality assurance for existing tools
**Use When**: Reviewing PRs, auditing tool quality

---

## Troubleshooting

### Issue 1: API Documentation Not Found

**Symptom**: Web search finds API reference but no programmatic docs

**Solutions**:
1. Check for OpenAPI/Swagger spec (often at `/api/docs` or `/openapi.json`)
2. Look for SDKs in GitHub (reverse-engineer from SDK code)
3. Inspect browser network tab on web interface
4. Contact API provider for documentation
5. Document as "low priority" for future manual integration

### Issue 2: Authentication Too Complex

**Symptom**: OAuth flow requires interactive login, token management

**Solutions**:
1. Document OAuth setup in skill README
2. Implement token refresh logic
3. Use environment variables for tokens
4. Create setup guide for users
5. Consider if API worth the complexity

### Issue 3: No Real Test Examples Available

**Symptom**: Can't find valid IDs for test_examples

**Solutions**:
1. Use List endpoint to discover IDs
2. Search API documentation for examples
3. Check API GitHub issues/discussions for sample data
4. Use API playground/sandbox if available
5. Contact API provider for test IDs
6. Last resort: Create test data via API POST endpoints

### Issue 4: Tools Won't Load

**Symptom**: ToolUniverse doesn't see new tools

**Solutions**:
1. Check `default_config.py` registration (Step 2 of 3-step process)
2. Verify JSON syntax: `python -m json.tool file.json`
3. Check class decorator: `@register_tool("ClassName")`
4. Run verification script (see Phase 3, Step 3.3)
5. Clear Python cache: `find . -type d -name __pycache__ -exec rm -rf {} +`
6. Regenerate wrappers: `python -m tooluniverse.generate_tools --force`

### Issue 5: Schema Validation Fails

**Symptom**: return_schema doesn't match actual API response

**Solutions**:
1. Call API directly, inspect raw response
2. Update return_schema to match actual structure
3. Add nullable types for optional fields: `{"type": ["string", "null"]}`
4. Use oneOf for fields with multiple possible structures
5. Ensure data wrapper in success schema
6. Check for nested data structures

### Issue 6: Rate Limits Hit During Testing

**Symptom**: API returns 429 Too Many Requests

**Solutions**:
1. Add rate limiting to tool: `time.sleep(1)` between requests
2. Use optional API key if available (higher limits)
3. Reduce number of test examples
4. Implement exponential backoff on retry
5. Document rate limits in tool description

### Issue 7: API Changed Since Documentation

**Symptom**: Parameters/endpoints don't match docs

**Solutions**:
1. Check API version (may need to specify in base URL)
2. Look for API changelog or migration guide
3. Test with different API versions
4. Update documentation URL to correct version
5. Contact API maintainers about discrepancy

---

## Advanced Features

### Async Polling Support

For job-based APIs (submit → poll → retrieve):

```python
def _submit_job(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """Submit job and poll for completion."""
    # Submit
    submit_resp = requests.post(
        f"{self.BASE_URL}/jobs",
        json={"data": arguments.get("data")},
        timeout=30
    )
    job_id = submit_resp.json().get("job_id")

    # Poll (with timeout)
    for attempt in range(60):  # 2 min max
        status_resp = requests.get(
            f"{self.BASE_URL}/jobs/{job_id}",
            timeout=30
        )
        result = status_resp.json()

        if result.get("status") == "completed":
            return {"status": "success", "data": result.get("results")}
        elif result.get("status") == "failed":
            return {"status": "error", "error": result.get("error")}

        time.sleep(2)

    return {"status": "error", "error": "Job timeout after 2 minutes"}
```

**JSON Config**:
```json
{
  "is_async": true,
  "poll_interval": 2,
  "max_wait_time": 120
}
```

### SOAP API Support

For SOAP-based APIs:

```python
# Add operation parameter
def run(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
    operation = arguments.get("operation")
    if not operation:
        return {"status": "error", "error": "SOAP APIs require 'operation' parameter"}
    # ... rest of implementation
```

**JSON Config**:
```json
{
  "parameter": {
    "properties": {
      "operation": {
        "const": "search_items",
        "description": "SOAP operation name (required)"
      }
    }
  }
}
```

### Pagination Handling

For paginated APIs:

```python
def _list_all(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """Fetch all pages."""
    all_results = []
    page = 1

    while True:
        response = requests.get(
            f"{self.BASE_URL}/items",
            params={"page": page, "limit": 100},
            timeout=30
        )
        data = response.json()

        results = data.get("results", [])
        if not results:
            break

        all_results.extend(results)

        if len(results) < 100:  # Last page
            break

        page += 1

    return {
        "status": "success",
        "data": all_results,
        "metadata": {"total_pages": page, "total_items": len(all_results)}
    }
```

---

## Success Criteria

### Discovery Phase Success
- ✅ Coverage analysis complete with tool counts
- ✅ ≥3 high-priority APIs identified
- ✅ API documentation URLs verified accessible
- ✅ Authentication methods documented
- ✅ Discovery report generated

### Creation Phase Success
- ✅ All tool classes implement `@register_tool()`
- ✅ All JSON configs have proper structure
- ✅ return_schema has oneOf with data wrapper
- ✅ test_examples use real IDs (no placeholders)
- ✅ Tool names ≤55 characters
- ✅ default_config.py updated

### Validation Phase Success
- ✅ All tools load into ToolUniverse
- ✅ test_new_tools.py shows 100% pass rate
- ✅ No schema validation errors
- ✅ devtu compliance checklist complete
- ✅ Validation report generated

### Integration Phase Success
- ✅ Git branch created successfully
- ✅ Commits follow format with Co-Authored-By
- ✅ PR description comprehensive
- ✅ PR created and URL provided
- ✅ All files included in PR

---

## Maintenance

### Updating Discovered APIs

Re-run discovery periodically to find:
- New APIs in existing domains
- Emerging technologies (new domains)
- API version updates
- Deprecated APIs to remove

**Recommended**: Quarterly discovery runs

### Monitoring Tool Health

Track tool success rates:
```python
# Periodic health check
from tooluniverse import ToolUniverse

tu = ToolUniverse()
tu.load_tools()

for tool_name in tu.all_tool_dict.keys():
    # Run with test_examples
    # Log success/failure rates
    # Alert on degradation
```

### Gap Analysis Automation

Set up automated gap detection:
1. Weekly: Scan ToolUniverse for new tools
2. Update coverage metrics
3. Compare with target coverage goals
4. Generate gap report
5. Trigger discovery for critical gaps

---

## Summary

The `devtu-auto-discover-apis` skill provides a complete automation pipeline for:

1. **Discovery**: Systematic identification of API gaps and candidates
2. **Creation**: Automated tool generation following devtu-create-tool patterns
3. **Validation**: Comprehensive testing with devtu-fix-tool integration
4. **Integration**: Git workflow management with PR generation

**Key Benefits**:
- Reduces manual tool creation time by 80%
- Ensures consistent quality through automated validation
- Systematic gap filling improves ToolUniverse coverage
- Lowers barrier to adding new APIs

**Best Practices**:
- Always verify API documentation before creation
- Use real test examples (never placeholders)
- Follow devtu validation workflow strictly
- Include human approval at quality gates
- Document authentication requirements clearly

Apply this skill to systematically expand ToolUniverse with high-quality, validated tools for life science research.
