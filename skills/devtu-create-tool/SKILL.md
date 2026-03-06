---
name: devtu-create-tool
description: Create new scientific tools for ToolUniverse framework with proper structure, validation, and testing. Use when users need to add tools to ToolUniverse, implement new API integrations, create tool wrappers for scientific databases/services, expand ToolUniverse capabilities, or follow ToolUniverse contribution guidelines. Supports creating tool classes, JSON configurations, validation, error handling, and test examples.
---

# ToolUniverse Tool Creator

Create new scientific tools for the ToolUniverse framework following established best practices.

---

## Table of Contents

1. [Critical Knowledge](#critical-knowledge)
2. [Core Concepts](#core-concepts)
3. [Implementation Guide](#implementation-guide)
4. [Testing Strategy](#testing-strategy)
5. [Common Patterns](#common-patterns)
6. [Troubleshooting](#troubleshooting)
7. [Reference](#reference)

---

## Critical Knowledge

### Top 7 Mistakes (90% of Failures)

1. **Missing `default_config.py` Entry** - Tools silently won't load
2. **Non-nullable Mutually Exclusive Parameters** - Validation errors (NEW #1 issue in 2026)
3. **Fake test_examples** - Tests fail, agents get bad examples
4. **Single-level Testing** - Misses registration bugs
5. **Skipping `test_new_tools.py`** - Misses schema/API issues
6. **Tool Names > 55 chars** - Breaks MCP compatibility
7. **Raising Exceptions** - Should return error dicts instead

**Most Common (2026)**: Mistake #2 affects 60% of new tools. Always make mutually exclusive parameters nullable: `{"type": ["string", "null"]}`

### Tool Creator vs SDK User

| SDK User (Using) | Tool Creator (Building) |
|------------------|-------------------------|
| `tu.tools.ToolName()` | `@register_tool()` + JSON |
| Handle responses | Design schemas |
| One-level usage | Three-step registration |

---

## Core Concepts

### Two-Stage Architecture

```
Stage 1: Tool Class              Stage 2: Wrappers (Auto-Generated)
Python Implementation            From JSON Configs
       ↓                                  ↓
@register_tool("MyTool")         MyAPI_list_items()
class MyTool(BaseTool):          MyAPI_search()
    def run(arguments):          MyAPI_get_details()
```

**Key Points**:
- One class handles multiple operations
- JSON defines individual tool wrappers
- Users call wrappers, which route to class
- Need BOTH for tools to work

### Three-Step Registration

**Step 1: Class Registration**
```python
@register_tool("MyAPITool")  # Decorator registers class
class MyAPITool(BaseTool):
    pass
```

**Step 2: Config Registration** ⚠️ MOST COMMONLY MISSED
```python
# In src/tooluniverse/default_config.py
TOOLS_CONFIGS = {
    "my_category": os.path.join(current_dir, "data", "my_category_tools.json"),
}
```

**Step 3: Wrapper Generation** (Automatic)
```bash
tu = ToolUniverse()
tu.load_tools()  # Auto-generates wrappers in tools/
```

**Verification Script**:
```python
import sys
sys.path.insert(0, 'src')

# Step 1: Check class registered
from tooluniverse.tool_registry import get_tool_registry
import tooluniverse.your_tool_module
registry = get_tool_registry()
assert "YourToolClass" in registry, "❌ Step 1 FAILED"
print("✅ Step 1: Class registered")

# Step 2: Check config registered
from tooluniverse.default_config import TOOLS_CONFIGS
assert "your_category" in TOOLS_CONFIGS, "❌ Step 2 FAILED"
print("✅ Step 2: Config registered")

# Step 3: Check wrappers generated
from tooluniverse import ToolUniverse
tu = ToolUniverse()
tu.load_tools()
assert hasattr(tu.tools, 'YourCategory_operation1'), "❌ Step 3 FAILED"
print("✅ Step 3: Wrappers generated")
print(f"✅ All steps complete!")
```

### Standard Response Format

**All tools must return**:
```json
{
  "status": "success" | "error",
  "data": {...},        // On success
  "error": "message"    // On failure
}
```

**Why**: Consistent error handling, composability, user expectations

---

## Implementation Guide

### File Structure

**Required Files**:
- `src/tooluniverse/my_api_tool.py` - Implementation
- `src/tooluniverse/data/my_api_tools.json` - Tool definitions
- `tests/tools/test_my_api_tool.py` - Tests
- `examples/my_api_examples.py` - Usage examples

**Auto-Generated** (don't create manually):
- `src/tooluniverse/tools/MyAPI_*.py` - Wrappers

### Pattern 1: Multi-Operation Tool (Recommended)

**Python Class**:
```python
from typing import Dict, Any
from tooluniverse.tool import BaseTool
from tooluniverse.tool_utils import register_tool
import requests

@register_tool("MyAPITool")
class MyAPITool(BaseTool):
    """Tool for MyAPI database."""
    
    BASE_URL = "https://api.example.com/v1"
    
    def __init__(self, tool_config):
        super().__init__(tool_config)
        self.parameter = tool_config.get("parameter", {})
        self.required = self.parameter.get("required", [])
    
    def run(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Route to operation handler."""
        operation = arguments.get("operation")
        
        if not operation:
            return {"status": "error", "error": "Missing: operation"}
        
        if operation == "list_items":
            return self._list_items(arguments)
        elif operation == "search":
            return self._search(arguments)
        else:
            return {"status": "error", "error": f"Unknown: {operation}"}
    
    def _list_items(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """List items with pagination."""
        try:
            params = {}
            if "limit" in arguments:
                params["limit"] = arguments["limit"]
            
            response = requests.get(
                f"{self.BASE_URL}/items",
                params=params,
                timeout=30
            )
            response.raise_for_status()
            
            data = response.json()
            return {
                "status": "success",
                "data": data.get("items", []),
                "total": data.get("total", 0)
            }
        except requests.exceptions.Timeout:
            return {"status": "error", "error": "Timeout after 30s"}
        except requests.exceptions.HTTPError as e:
            return {"status": "error", "error": f"HTTP {e.response.status_code}"}
        except Exception as e:
            return {"status": "error", "error": str(e)}
    
    def _search(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Search items by query."""
        query = arguments.get("query")
        if not query:
            return {"status": "error", "error": "Missing: query"}
        
        try:
            response = requests.get(
                f"{self.BASE_URL}/search",
                params={"q": query},
                timeout=30
            )
            response.raise_for_status()
            
            data = response.json()
            return {
                "status": "success",
                "results": data.get("results", []),
                "count": data.get("count", 0)
            }
        except requests.exceptions.RequestException as e:
            return {"status": "error", "error": f"API failed: {str(e)}"}
```

**JSON Configuration**:
```json
[
  {
    "name": "MyAPI_list_items",
    "class": "MyAPITool",
    "description": "List items from database with pagination. Returns item IDs and names. Supports filtering by status and type. Example: limit=10 returns first 10 items.",
    "parameter": {
      "type": "object",
      "required": ["operation"],
      "properties": {
        "operation": {
          "const": "list_items",
          "description": "Operation type (fixed)"
        },
        "limit": {
          "type": "integer",
          "description": "Max results (1-100)",
          "minimum": 1,
          "maximum": 100
        }
      }
    },
    "return": {
      "type": "object",
      "properties": {
        "status": {"type": "string", "enum": ["success", "error"]},
        "data": {"type": "array"},
        "total": {"type": "integer"},
        "error": {"type": "string"}
      },
      "required": ["status"]
    },
    "test_examples": [
      {
        "operation": "list_items",
        "limit": 10
      }
    ]
  }
]
```

### Pattern 2: Async Polling (Job-Based APIs)

```python
import time

def _submit_job(self, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """Submit job and poll for results."""
    try:
        # Submit
        submit_response = requests.post(
            f"{self.BASE_URL}/jobs/submit",
            json={"data": arguments.get("data")},
            timeout=30
        )
        submit_response.raise_for_status()
        job_id = submit_response.json().get("job_id")
        
        # Poll
        for attempt in range(60):  # 2 min max
            status_response = requests.get(
                f"{self.BASE_URL}/jobs/{job_id}/status",
                timeout=30
            )
            status_response.raise_for_status()
            
            result = status_response.json()
            if result.get("status") == "completed":
                return {
                    "status": "success",
                    "data": result.get("results"),
                    "job_id": job_id
                }
            elif result.get("status") == "failed":
                return {
                    "status": "error",
                    "error": result.get("error"),
                    "job_id": job_id
                }
            
            time.sleep(2)  # Poll every 2s
        
        return {"status": "error", "error": "Timeout after 2 min"}
    except requests.exceptions.RequestException as e:
        return {"status": "error", "error": str(e)}
```

### API Key Configuration

Tools can specify API key requirements in JSON config:

**`required_api_keys`** - Tool won't load without these:
```json
{
  "name": "NVIDIA_ESMFold_predict",
  "required_api_keys": ["NVIDIA_API_KEY"],
  ...
}
```

**`optional_api_keys`** - Tool loads and works without keys, but with reduced performance:
```json
{
  "name": "PubMed_search_articles",
  "optional_api_keys": ["NCBI_API_KEY"],
  "description": "Search PubMed. Rate limits: 3 req/sec without key, 10 req/sec with NCBI_API_KEY.",
  ...
}
```

**When to use `optional_api_keys`**:
- APIs with rate limits that improve with a key (NCBI: 3→10 req/sec, Semantic Scholar: 1→100 req/sec)
- APIs that work anonymously but have better quotas with authentication
- Tools that should always be available, even for users without API keys

**Implementation pattern for optional keys**:
```python
def __init__(self, tool_config):
    super().__init__(tool_config)
    # Read from environment variable only (not as parameter)
    self.api_key = os.environ.get("NCBI_API_KEY", "")

def run(self, arguments):
    # Adjust behavior based on key availability
    has_key = bool(self.api_key)
    rate_limit = 0.1 if has_key else 0.4  # Faster with key
    ...
```

**Key rules**:
- ❌ Don't add `api_key` as a tool parameter for optional keys
- ✅ Read optional keys from environment variables only
- ✅ Include rate limit info in tool description
- ✅ Tool must work (with degraded performance) when key is missing

### JSON Best Practices

**Tool Naming** (≤55 chars for MCP):
- Template: `{API}_{action}_{target}`
- ✅ Good: `FDA_get_drug_info` (20 chars)
- ❌ Bad: `FDA_get_detailed_drug_information_with_history` (55+ chars)

**Description** (150-250 chars, high-context):
```json
{
  "description": "Search database for items. Returns up to 100 results with scores. Supports wildcards (* ?) and Boolean operators (AND, OR, NOT). Example: 'protein AND membrane' finds membrane proteins."
}
```

Include: What it returns, data source, use case, input format, example

**test_examples** (MUST be real):
```json
{
  "test_examples": [
    {
      "operation": "search",
      "query": "protein",     // ✅ Real, common term
      "limit": 10
    }
  ]
}
```

❌ Don't use: `"id": "XXXXX"`, `"placeholder": "example_123"`
✅ Do use: Real IDs from actual API documentation

### JSON Config Conventions

- The `"type"` field in JSON must match the Python class name from `@register_tool`
- Include `return_schema` to define tool output structure (not just `return`)
- Put example inputs in `test_examples` only; **avoid** `examples` blocks inside `parameter`/`return_schema` — they bloat configs and drift from reality
- For large allow-lists, document values in `description` and enforce in Python (avoid giant schema `enum`)
- Auto-discovery: tools placed in `src/tooluniverse/` are auto-discovered; no `__init__.py` modification needed
- Optional: implement `validate_parameters(arguments)` for custom validation

> For the full implementation plan, maintenance checklist, and large API expansion guidance, see [references/implementation-guide.md](references/implementation-guide.md)

---

## Testing Strategy

### Final Validation with test_new_tools.py (MANDATORY)

**All new tools MUST pass `scripts/test_new_tools.py` before submission.**

This script tests tools using their `test_examples` from JSON configs and validates responses against `return_schema`.

```bash
# Test your specific tools
python scripts/test_new_tools.py your_tool_name

# Test with verbose output
python scripts/test_new_tools.py your_tool_name -v

# Test all tools (for full validation)
python scripts/test_new_tools.py

# Stop on first failure
python scripts/test_new_tools.py your_tool_name --fail-fast
```

**What it validates**:
- Tool execution succeeds (no exceptions)
- Response matches `return_schema` (if defined)
- 404 errors tracked separately (indicates bad test_examples)
- Tools with missing API keys are skipped gracefully

**Common failures and fixes**:
| Failure | Cause | Fix |
|---------|-------|-----|
| 404 ERROR | Invalid ID in test_examples | Use real IDs from API docs |
| Schema Mismatch | Response doesn't match return_schema | Update schema or fix response format |
| Exception | Code bug or missing dependency | Check error message, fix implementation |

---

### Two-Level Testing (MANDATORY)

**Level 1: Direct Class Testing**
```python
import json
from tooluniverse.your_tool_module import YourToolClass

def test_direct_class():
    """Test implementation logic."""
    with open("src/tooluniverse/data/your_tools.json") as f:
        tools = json.load(f)
        config = next(t for t in tools if t["name"] == "YourTool_operation1")
    
    tool = YourToolClass(config)
    result = tool.run({"operation": "operation1", "param": "value"})
    
    assert result["status"] == "success"
    assert "data" in result
```

**Level 2: ToolUniverse Interface Testing**
```python
import pytest
from tooluniverse import ToolUniverse

class TestYourTools:
    @pytest.fixture
    def tu(self):
        tu = ToolUniverse()
        tu.load_tools()  # CRITICAL
        return tu
    
    def test_tools_load(self, tu):
        """Verify registration."""
        assert hasattr(tu.tools, 'YourTool_operation1')
    
    def test_execution(self, tu):
        """Test via ToolUniverse (how users call it)."""
        result = tu.tools.YourTool_operation1(**{
            "operation": "operation1",
            "param": "value"
        })
        assert result["status"] == "success"
    
    def test_error_handling(self, tu):
        """Test missing params."""
        result = tu.tools.YourTool_operation1(**{
            "operation": "operation1"
            # Missing required param
        })
        assert result["status"] == "error"
```

**Level 3: Real API Testing**
```python
def test_real_api():
    """Verify actual API integration."""
    tu = ToolUniverse()
    tu.load_tools()
    
    result = tu.tools.YourTool_operation1(**{
        "operation": "operation1",
        "param": "real_value_from_docs"
    })
    
    if result["status"] == "success":
        assert "data" in result
        print("✅ Real API works")
    else:
        print(f"⚠️  API error (may be down): {result['error']}")
```

**Why Both Levels**:
- Level 1: Tests implementation, catches code bugs
- Level 2: Tests registration, catches config bugs
- Level 3: Tests integration, catches API issues

---

### Systematic Testing for Multiple New Tools

When creating multiple tools at once (e.g., 5-15 tools for an API), use this systematic approach:

**Step 1: Sample Testing (Quick validation)**
```python
# Test 1-2 tools per API to catch common issues
python scripts/test_new_tools.py MyAPI_get_item -v
python scripts/test_new_tools.py MyAPI_search -v
```

**Step 2: Identify Patterns**

Group errors by type:
- **Parameter validation errors**: "None is not of type 'integer'" → Make parameters nullable
- **API errors**: 404, 400 → Fix test_examples with real IDs
- **Schema errors**: "Data: None" → Check return format
- **Wrong parameter names**: "unexpected keyword" → Verify against config

**Step 3: Fix Systematically**

Fix all tools with same issue together:
```python
# Fix all nullable parameter issues in JSON
# Then regenerate once:
python -m tooluniverse.generate_tools
```

**Step 4: Verify All**

Test all tools comprehensively:
```python
# Test entire tool set
python scripts/test_new_tools.py MyAPI -v

# Verify count
python3 << 'EOF'
from tooluniverse import ToolUniverse
tu = ToolUniverse()
tu.load_tools()
my_tools = [t for t in dir(tu.tools) if t.startswith('MyAPI_')]
print(f"✅ {len(my_tools)} MyAPI tools loaded")
EOF
```

**Step 5: Verify Parameter Names**

Before testing, verify parameter names match the config:
```python
import json
with open('src/tooluniverse/data/myapi_tools.json') as f:
    tools = json.load(f)
    for tool in tools:
        print(f"{tool['name']}: {list(tool['parameter']['properties'].keys())}")
```

Don't assume parameter names like `query`, `id`, `taxon` - always verify!

**Step 6: Data Structure Verification**

Test understanding of return data structure:
```python
result = tu.tools.MyAPI_get_item(id="123")

# For object data
if isinstance(result.get('data'), dict):
    print("✅ Returns single object")
    value = result['data'].get('field')

# For array data
elif isinstance(result.get('data'), list):
    print("✅ Returns array of items")
    count = len(result['data'])
    first = result['data'][0] if result['data'] else {}
```

---

## Common Patterns

### Error Handling Checklist

✅ Always set timeout (30s recommended)
✅ Catch specific exceptions (Timeout, ConnectionError, HTTPError)
✅ Return error dicts, never raise in run()
✅ Include helpful context in error messages
✅ Handle JSON parsing errors
✅ Validate required parameters

### Parameter Design Best Practices

#### Mutually Exclusive Parameters (CRITICAL)

When creating tools that accept EITHER parameterA OR parameterB, **both parameters MUST be nullable**.

**❌ WRONG - Will cause validation errors**:
```json
{
  "parameter": {
    "type": "object",
    "properties": {
      "id": {
        "type": "integer",
        "description": "Numeric ID"
      },
      "name": {
        "type": "string",
        "description": "Name string (alternative to id)"
      }
    }
  }
}
```

**Problem**: When user provides only `name`, validation fails because `id` is `None` and not of type `integer`.

**✅ CORRECT - Make mutually exclusive parameters nullable**:
```json
{
  "parameter": {
    "type": "object",
    "properties": {
      "id": {
        "type": ["integer", "null"],
        "description": "Numeric ID"
      },
      "name": {
        "type": ["string", "null"],
        "description": "Name string (alternative to id)"
      }
    }
  }
}
```

**Common patterns requiring nullable parameters**:
- `id` OR `name` (get by ID or by name)
- `acronym` OR `name` (search by symbol or full name)
- `gene_id` OR `gene_symbol`
- `neuron_id` OR `neuron_name`
- Optional filter parameters (`filter_field`, `filter_value`)

#### Optional Parameters

**All optional parameters should be nullable**:
```json
{
  "filter_field": {
    "type": ["string", "null"],
    "description": "Optional filter field"
  },
  "limit": {
    "type": ["integer", "null"],
    "description": "Optional result limit",
    "default": 10
  }
}
```

#### Parameter Naming Consistency

**Use consistent, descriptive parameter names**:
- ✅ `gene_id`, `gene_symbol`, `tax_id` - Clear and specific
- ❌ `id`, `query`, `q` - Too generic, causes confusion

**Check API documentation for parameter names**:
- Match official API parameter names when possible
- Use snake_case for Python/JSON consistency
- Document the mapping if API uses different names

#### Test Examples

**Use REAL IDs in test_examples, never placeholders**:
```json
{
  "test_examples": [
    {
      "gene_id": "7157"  // ✅ Real TP53 gene ID
    },
    {
      "gene_symbol": "BRCA1",  // ✅ Real gene symbol
      "taxon": "9606"  // ✅ Real human tax ID
    }
  ]
}
```

**❌ AVOID**:
```json
{
  "test_examples": [
    {
      "gene_id": "TEST123"  // ❌ Fake ID
    },
    {
      "gene_id": "example_id"  // ❌ Placeholder
    }
  ]
}
```

#### Return Schema and Data Structure

**Document whether `data` is object, array, or string**:
```json
{
  "name": "MyAPI_get_item",
  "description": "Get single item by ID. Returns object with item details.",
  "return_schema": {
    "oneOf": [
      {
        "type": "object",
        "properties": {
          "data": {
            "type": "object",  // ← Specify: single object
            "properties": {
              "id": {"type": "string"},
              "name": {"type": "string"}
            }
          }
        }
      }
    ]
  }
}
```

```json
{
  "name": "MyAPI_search",
  "description": "Search items. Returns array of matching items.",
  "return_schema": {
    "oneOf": [
      {
        "type": "object",
        "properties": {
          "data": {
            "type": "array",  // ← Specify: array of results
            "items": {
              "type": "object",
              "properties": {
                "id": {"type": "string"}
              }
            }
          }
        }
      }
    ]
  }
}
```

### Dependency Management

**Check package size FIRST**:
```bash
curl -s https://pypi.org/pypi/PACKAGE/json | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(f'Dependencies: {len(data[\"info\"][\"requires_dist\"] or [])}')
"
```

**Classification**:
- Core (<100MB, universal use) → `[project.dependencies]`
- Optional (>100MB or niche) → `[project.optional-dependencies]`

**In code**:
```python
try:
    import optional_package
except ImportError:
    return {
        "status": "error",
        "error": "Install with: pip install optional_package"
    }
```

### Pagination Pattern

```python
def _list_items(self, arguments):
    params = {}
    if "page" in arguments:
        params["page"] = arguments["page"]
    if "limit" in arguments:
        params["limit"] = arguments["limit"]
    
    response = requests.get(url, params=params, timeout=30)
    data = response.json()
    
    return {
        "status": "success",
        "data": data.get("items", []),
        "page": data.get("page", 0),
        "total_pages": data.get("total_pages", 1),
        "total_items": data.get("total", 0)
    }
```

---

## Troubleshooting

### Tool Doesn't Load (90% of Issues)

**Symptoms**: Tool count doesn't increase, no error, `AttributeError` when calling

**Cause**: Missing Step 2 of registration (default_config.py)

**Solution**:
```python
# Edit src/tooluniverse/default_config.py
TOOLS_CONFIGS = {
    # ... existing ...
    "your_category": os.path.join(current_dir, "data", "your_category_tools.json"),
}
```

**Verify**:
```bash
grep "your_category" src/tooluniverse/default_config.py
ls src/tooluniverse/tools/YourCategory_*.py
python3 -c "from tooluniverse import ToolUniverse; tu = ToolUniverse(); tu.load_tools(); print(hasattr(tu.tools, 'YourCategory_op1'))"
```

### Tests Fail with Real APIs

**Mock vs Real Testing**:
- Mocks test code structure
- Real calls test API integration
- Both needed for confidence

**What Real Testing Catches**:
- Response structure differences
- Parameter name mismatches
- Unexpected pagination
- Timeout issues
- Data type surprises

---

## Reference

### Complete Workflow

1. **Create** Python class with `@register_tool`
2. **Create** JSON config with realistic test_examples and `return_schema`
3. **Add** to `default_config.py` ← CRITICAL
4. **Generate** wrappers: `tu.load_tools()`
5. **Test** Level 1 (direct class)
6. **Test** Level 2 (ToolUniverse interface)
7. **Test** Level 3 (real API calls)
8. **Run** `python scripts/test_new_tools.py your_tool -v` ← MANDATORY
9. **Run** `python scripts/check_tool_name_lengths.py --test-shortening`
10. **Create** examples file
11. **Verify** all 3 registration steps
12. **Document** in verification report

> For the full development checklist and maintenance phases, see [references/implementation-guide.md](references/implementation-guide.md)

### Quick Commands

```bash
# Validate JSON
python3 -m json.tool src/tooluniverse/data/your_tools.json

# Check Python syntax
python3 -m py_compile src/tooluniverse/your_tool.py

# Verify registration
grep "your_category" src/tooluniverse/default_config.py

# Generate wrappers
PYTHONPATH=src python3 -m tooluniverse.generate_tools --force

# List wrappers
ls src/tooluniverse/tools/YourCategory_*.py

# Run unit tests
pytest tests/tools/test_your_tool.py -v

# MANDATORY: Run test_new_tools.py validation
python scripts/test_new_tools.py your_tool -v

# Count tools
python3 << 'EOF'
from tooluniverse import ToolUniverse
tu = ToolUniverse()
tu.load_tools()
print(f"Total: {len([t for t in dir(tu.tools) if 'YourCategory' in t])} tools")
EOF
```

### Critical Reminders

⚠️ **ALWAYS** add to default_config.py (Step 2)
⚠️ **NEVER** raise exceptions in run()
⚠️ **ALWAYS** use real test_examples
⚠️ **ALWAYS** test both levels
⚠️ **RUN** `python scripts/test_new_tools.py your_tool -v` before submitting
⚠️ **KEEP** tool names ≤55 characters
⚠️ **RETURN** standard response format
⚠️ **SET** timeout on all HTTP requests
⚠️ **VERIFY** all 3 registration steps
⚠️ **USE** `optional_api_keys` for rate-limited APIs that work without keys
⚠️ **NEVER** add `api_key` parameter for optional keys - use env vars only

### Success Criteria

✅ All 3 registration steps verified
✅ Level 1 tests passing (direct class)
✅ Level 2 tests passing (ToolUniverse interface)
✅ Real API calls working (Level 3)
✅ **`test_new_tools.py` passes with 0 failures** ← MANDATORY
✅ Tool names ≤55 characters
✅ test_examples use real IDs
✅ Standard response format used
✅ Helpful error messages
✅ Examples file created
✅ No raised exceptions in run()

When all criteria met → **Production Ready** 🎉
