## 2025-02-23 - Accessibility gaps in form help text
**Learning:** The app uses `small.form-text.text-muted` for help text but consistently fails to link them to inputs using `aria-describedby`. Also, time inputs are often placed next to date inputs without their own labels.
**Action:** When working on forms, systematically check for orphaned help text and unlabeled secondary inputs (like time fields) and link/label them.

## 2026-02-08 - Orphaned File Inputs
**Learning:** Several file inputs (`file_field`) were missing labels, making them inaccessible to screen readers. This often happened when a `div` or `p` with a class like `text-divider` was used as a visual label instead of a `<label>` tag.
**Action:** Always verify that `file_field` inputs have a corresponding `label` tag. If a visual divider style is needed, apply the style class to the label itself (e.g., `class: "text-divider d-block"`) rather than using a separate non-semantic element.
