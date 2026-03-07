# create-tooluniverse-skill — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Integration with Other Skills

### When to Use devtu-create-tool

**Invoke when**:
- Critical functionality has no existing tool
- Analysis phase completely blocked
- Alternative approaches inadequate

**Don't invoke when**:
- Similar tool exists with minor differences
- Can restructure analysis to use existing tools
- Tool would duplicate functionality

### When to Use devtu-fix-tool

**Invoke when**:
- Test reveals tool returns errors
- Tool fails validation
- Response format unexpected
- Parameter validation fails

### When to Use devtu-optimize-skills

**Reference when**:
- Need evidence grading patterns
- Want report optimization strategies
- Implementing completeness checking
- Designing synthesis sections

---

## Quality Indicators

**High-Quality Skill Has**:
✅ 100% test coverage before documentation
✅ Implementation-agnostic SKILL.md
✅ Multi-implementation QUICK_START (Python SDK + MCP)
✅ Complete error handling with fallbacks
✅ Tool parameter corrections table
✅ Response format documentation
✅ All tools verified through testing
✅ Working examples in both interfaces

**Red Flags**:
❌ Documentation written before testing tools
❌ Python code in SKILL.md
❌ Assumed parameters from function names
❌ No fallback strategies
❌ SOAP tools missing `operation`
❌ No test script or failing tests
❌ Single implementation only

---

## Time Investment Guidelines

**Per Skill Breakdown**:
- Phase 1 (Domain Analysis): 15 min
- Phase 2 (Tool Testing): 30-45 min
- Phase 3 (Tool Creation): 0-60 min (if needed)
- Phase 4 (Implementation): 30-45 min
- Phase 5 (Documentation): 30-45 min
- Phase 6 (Validation): 15-30 min
- Phase 7 (Packaging): 15 min

**Total**: ~1.5-2 hours per skill (without tool creation)
**With tool creation**: +30-60 minutes per tool

---

## References

- **Tool testing workflow**: See `references/tool_testing_workflow.md`
- **Implementation-agnostic format**: See `references/implementation_agnostic_format.md`
- **Standards checklist**: See `references/skill_standards_checklist.md`
- **devtu-optimize integration**: See `references/devtu_optimize_integration.md`

---

## Templates

All templates available in `assets/skill_template/`:
- `python_implementation.py` - Pipeline template
- `SKILL.md` - Documentation template
- `QUICK_START.md` - Multi-implementation guide
- `test_skill.py` - Test suite template

---

## Summary

**Create ToolUniverse Skill** provides systematic 7-phase workflow:

1. ✅ **Domain Analysis** - Understand requirements
2. ✅ **Tool Testing** - Verify before documenting (TEST FIRST!)
3. ✅ **Tool Creation** - Add missing tools if needed
4. ✅ **Implementation** - Build working pipeline
5. ✅ **Documentation** - Implementation-agnostic format
6. ✅ **Validation** - 100% test coverage
7. ✅ **Packaging** - Complete summary

**Result**: Production-ready skills with Python SDK + MCP support, complete testing, and quality documentation

**Time**: ~1.5-2 hours per skill (tested and documented)
