---
name: browser-automation
description: Browser automation for accessing scientific databases that lack REST APIs. Uses the browser-use Python framework (81k+ GitHub stars) to control a real browser via LLM vision. Enables data extraction from web-only databases like GEPIA2, GeneCards advanced features, COSMIC public data, and journal full-text access. Use as a fallback when curl-based API access fails or when the target database has no programmatic API. Requires pip install browser-use and a Chromium browser.
---

# Browser Automation for Scientific Data Collection

Access scientific databases that have no REST API by controlling a real browser programmatically. Uses the browser-use framework (vision-based LLM browser automation).

## When to Use

- Target database has **no REST API** (e.g., GEPIA2, some COSMIC pages)
- curl returns **403/captcha/login required** and the data is publicly viewable in a browser
- Need to **navigate multi-step web forms** (e.g., TIMER2.0 correlation analysis)
- Need to **download files** from web interfaces (e.g., GEO supplementary data)
- API exists but is **severely rate-limited** and web access is faster

**When NOT to use**:
- REST API is available and working → use `curl`
- Data requires paid subscription → do not circumvent paywalls
- Data can be obtained from an alternative open API → prefer the API

---

## Installation Check

Before using browser automation, verify the environment:

```bash
bash: python3 -c "
try:
    import browser_use
    print('✅ browser-use installed')
except ImportError:
    print('❌ browser-use not installed')
    print('   Install: pip install browser-use')

import shutil
if shutil.which('chromium') or shutil.which('chromium-browser') or shutil.which('google-chrome'):
    print('✅ Chromium/Chrome found')
else:
    print('⚠️  No Chromium/Chrome found')
    print('   Install: apt-get install chromium-browser (Linux)')
    print('   Or: brew install --cask chromium (macOS)')

try:
    import playwright
    print('✅ Playwright installed')
except ImportError:
    print('❌ Playwright not installed')
    print('   Install: pip install playwright && python -m playwright install chromium')
"
```

If not installed:
```bash
pip install -q browser-use playwright && python -m playwright install chromium
```

---

## Usage Pattern

### Basic: Extract data from a web page

```python
from browser_use import Agent, Browser, BrowserConfig
from langchain_openai import ChatOpenAI
import asyncio

async def extract_gepia2_data(gene: str, cancer: str):
    """Extract gene expression data from GEPIA2 (no API available)."""
    browser = Browser(config=BrowserConfig(headless=True))
    llm = ChatOpenAI(model="gpt-4o", api_key=os.environ["OPENAI_API_KEY"])

    agent = Agent(
        task=f"""Go to http://gepia2.cancer-pku.cn/#analysis
        1. Click on 'Expression DIY' in the left menu
        2. In the gene input box, type '{gene}'
        3. Select '{cancer}' from the cancer type dropdown
        4. Click 'Plot' button
        5. Wait for the plot to load
        6. Extract the median expression values for Tumor and Normal from the plot
        7. Return the values as JSON: {{"gene": "{gene}", "cancer": "{cancer}", "tumor_median": X, "normal_median": Y}}
        """,
        llm=llm,
        browser=browser,
    )

    result = await agent.run()
    await browser.close()
    return result

result = asyncio.run(extract_gepia2_data("THBS2", "PAAD"))
print(result)
```

### Batch: Collect data across multiple databases

```python
async def collect_multi_source(gene: str):
    """Collect gene info from multiple web-only sources."""
    browser = Browser(config=BrowserConfig(headless=True))
    llm = ChatOpenAI(model="gpt-4o")

    tasks = [
        {
            "source": "GeneCards",
            "url": f"https://www.genecards.org/cgi-bin/carddisp.pl?gene={gene}",
            "extract": "Gene summary, aliases, protein class, pathways, diseases"
        },
        {
            "source": "GEPIA2",
            "url": "http://gepia2.cancer-pku.cn/#analysis",
            "extract": f"Expression of {gene} across TCGA cancer types"
        }
    ]

    results = {}
    for task in tasks:
        agent = Agent(
            task=f"Navigate to {task['url']} and extract: {task['extract']}. Return as structured JSON.",
            llm=llm,
            browser=browser,
        )
        results[task["source"]] = await agent.run()

    await browser.close()
    return results
```

---

## Target Database Recipes

### GEPIA2 (no API)

```
Task: Go to http://gepia2.cancer-pku.cn/#analysis
1. Select 'Expression DIY' → 'Box Plot'
2. Enter gene symbol: {GENE}
3. Select cancer types or 'All'
4. Click Plot
5. Extract expression values from the resulting visualization
```

### GeneCards (enhanced data)

```
Task: Navigate to https://www.genecards.org/cgi-bin/carddisp.pl?gene={GENE}
1. Extract: Gene summary paragraph
2. Extract: Protein expression table (tissues)
3. Extract: Pathways & interactions section
4. Extract: Disorders associated section
5. Return all as structured JSON
```

### TIMER2.0 (immune analysis, web-only)

```
Task: Go to http://timer.cistrome.org/
1. Select 'Gene' module
2. Enter gene symbol: {GENE}
3. Select cancer type: {CANCER}
4. Select immune cell types: all
5. Click Submit
6. Extract correlation coefficients and p-values from the result table
```

### HPA (Human Protein Atlas)

```
Task: Navigate to https://www.proteinatlas.org/{ENSEMBL_ID}-{GENE}/pathology
1. Extract cancer expression data table
2. Extract prognostic significance across cancer types
3. Extract immunohistochemistry images metadata
```

---

## Safety and Ethics

1. **Respect robots.txt**: Check before scraping any site
2. **Rate limiting**: Wait 2-5 seconds between page navigations
3. **No credential storage**: Never save login credentials to disk
4. **Public data only**: Do not circumvent paywalls or access restrictions
5. **Attribution**: Record the source URL and access date for every data extraction
6. **Minimize requests**: Cache extracted data in the project `data/` directory

---

## Integration with Research Recipes

When a recipe step fails due to API unavailability:

```
curl API call for [DATABASE] failed (404/no API).
Attempting browser-based extraction via browser-use...
```

The browser fallback should:
1. Try the browser approach
2. If browser-use is not installed, suggest installation
3. If the browser approach also fails, document what was attempted and move on

---

## Limitations

- Requires a display server or headless Chromium (may not work in minimal Docker containers)
- Slower than API calls (5-30 seconds per page vs <1 second for curl)
- Vision-based extraction may misread complex layouts
- Some sites actively block automation (detect and skip gracefully)
- Requires an LLM API key for the browser agent (uses GPT-4o by default)
