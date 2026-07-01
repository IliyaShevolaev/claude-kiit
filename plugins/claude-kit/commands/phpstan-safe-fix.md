---
name: quality-workflow
description: "Fix an already-sent static-analysis result: safe fixes yourself, report complex ones"
disable-model-invocation: true
---

The user has already sent you the output of the project's static analyzer (phpstan/larastan, if configured — see CLAUDE.md). Analyze it and split the errors into two groups.

**SAFE TO FIX YOURSELF** (don't change logic, safe):
- Add a missing return type hint / param type hint where the type is obvious from the code
- Add a PHPDoc @var where the variable type is ambiguous for the analyzer
- Fix an incorrect PHPDoc (type mismatch in the annotation)
- Add a null-check / assert where the variable can be null according to the analyzer, but you can see it's impossible by the logic
- Remove dead code (unreachable code, unused variables) — only if you're 100% sure it isn't used
- Fix incorrect use of array<> types in annotations
- Add an explicit cast where the analyzer requires it (for example (string) $value)
- Fix typos in method/property names that the analyzer highlights

**DON'T TOUCH** (may break logic — only report them):
- Any changes to the business logic of methods
- Refactoring of architecture, renaming classes/methods
- Changing signatures of public methods
- Changes to the DB structure or models
- Anything requiring an understanding of business context
- Anything you're not 100% sure about

Fix the safe errors directly yourself (no agents, no delegation). Then report the result:

=== ПРОСТЫЕ ОШИБКИ ИСПРАВЛЕНЫ ===
<кратко что исправлено>

=== СЛОЖНЫЕ ОШИБКИ ===
<for each unresolved error:>
File: <path:line>
Error: <text from the analyzer>
Reason not to fix: <why it affects logic or architecture>
Suggestion: <what needs to be done to resolve it>

Don't run the analyzer, don't ask for confirmation to proceed further — just fix and report.
