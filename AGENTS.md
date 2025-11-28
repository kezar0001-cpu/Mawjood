# AGENTS.md
## Code Assistant Instructions for the Mawjood Mobile App (Flutter + Supabase)

This file defines how AI code agents (Codex, Gemini Code Assist, ChatGPT Coding Mode, Claude Artifacts, Replit Agents, etc.) must behave when generating or editing code for the Mawjood project.

The goal is to maintain consistency, reliability, and correctness across all AI-assisted development.

---

# 1. Project Summary

Mawjood is an Arabic-first business directory mobile application for Iraq. It is built in Flutter and integrates with Supabase for backend data.

Agents must always prioritize Flutter, Dart, and Supabase code.

---

# 2. Hard Rules for Code Agents

## 2.1 Output Format Rules
- Output Flutter (Dart) code only.
- Follow the existing folder structure.
- Never output React, JS, TS, Node, HTML, CSS, or web code.
- Never convert the app to a web project.
- Never modify pubspec.yaml unless explicitly instructed.

## 2.2 Design & Architecture Rules
- Respect RTL layout.
- Follow Material Design guidelines.
- Use composable widgets.
- Keep screens clean and readable.
- Use the project’s utils (colors, text styles).
- Maintain naming conventions.
- Separate UI from backend logic.

## 2.3 Supabase Interaction Rules
When mock mode is ON:
- Keep mock logic intact.
- UI must work without internet.

When mock mode is OFF:
- Use Supabase `from(table).select()` queries.
- Avoid raw SQL unless instructed.
- Handle errors safely.
- Add loading states.

## 2.4 Forbidden Behaviors
Agents must never:
- Suggest converting the app to a web project.
- Generate code in another language.
- Replace Flutter with React Native.
- Add packages without permission.
- Break folder structure.
- Modify architecture without approval.

---

# 3. Project Architecture Guidelines

## 3.1 Folder Structure
Agents must respect:

```
lib/
 ├── main.dart
 ├── screens/
 ├── widgets/
 ├── models/
 ├── services/
 └── utils/
```

Agents must not introduce new top-level folders unless instructed.

---

# 4. Coding Style Standards

## 4.1 Dart Style
- CamelCase variables and methods.
- PascalCase classes.
- Use const when possible.
- Prefer composition over inheritance.

## 4.2 UI/UX
- RTL-friendly.
- Clean spacing.
- Consistent typography.
- Minimal and intuitive icons.

## 4.3 Widget Rules
- Prefer StatelessWidget when possible.
- Use StatefulWidget only when necessary.
- Avoid overly nested UI trees.

---

# 5. Agent Behavior Rules

## 5.1 When adding features
- Add only the feature requested.
- Do not rewrite working files.
- Follow existing architecture.

## 5.2 When fixing issues
- Apply minimal, targeted fixes.
- Provide explanation + patch.
- Do not reformat the entire file.

## 5.3 When answering questions
- Keep explanations short.
- Provide Flutter examples.
- Maintain consistency with architecture.

## 5.4 When unsure
- Ask clarifying questions.
- Do not guess.
- Never introduce large changes without approval.

---

# 6. Future Integration Guidelines

Future planned features:
- Reviews system.
- Business dashboard.
- Branch support.
- Push notifications.
- Featured listings.
- Offline mode.

Code should remain modular for scalability.

---

# 7. Testing Guidelines
Agents must ensure:
- Code builds error-free.
- App runs in mock mode.
- UI elements work.
- RTL alignment remains correct.

---

# 8. Deployment Rules
Agents may:
- Assist with building APKs/IPA.
- Provide deployment instructions.
- Help configure CI/CD.

Agents may not:
- Modify signing keys.
- Add external automation without permission.

---

# 9. Example Agent Behavior

### Good:
- “Here is the updated widget with RTL fix.”
- “I added a helper widget to simplify your layout.”
- “I extended your Business model safely.”

### Bad:
- “Let’s rewrite this in React.”
- “I added Firebase automatically.”
- “I changed your whole architecture.”

---

# 10. Summary

Agents must:
- Produce Flutter-only output.
- Follow structure.
- Respect RTL.
- Maintain Supabase compatibility.
- Avoid architecture changes without explicit approval.

This AGENTS.md file defines all development rules for AI-driven contributions to Mawjood.
