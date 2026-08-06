# 🤝 Contributing to PetSewa Platform

Thank you for contributing to **PetSewa**! To maintain production-grade quality, security, and performance across the ecosystem, please adhere to these guidelines.

---

## 🔀 Git Branching Strategy

- **`main`**: Production-ready release branch. All code in `main` MUST pass CI/CD pipeline checks.
- **`staging`**: Staging deployment branch for integration testing.
- **`feature/<short-description>`**: New features (e.g. `feature/rewards-streak-tracker`).
- **`fix/<issue-description>`**: Bug fixes (e.g. `fix/booking-typeorm-overload`).

---

## 🚀 Pull Request Checklist

Before submitting a Pull Request:

1. **Local Verification**:
   - NestJS Backend: `npx tsc --noEmit` must return 0 errors.
   - Flutter App: `flutter analyze --no-fatal-infos` must return 0 fatal errors.
2. **Commit Messages**: Use clean conventional commits:
   - `feat: ...` for new features
   - `fix: ...` for bug fixes
   - `docs: ...` for documentation updates
   - `ci: ...` for workflow changes
3. **No Secrets**: Never commit `.env` files or secret keys to source control.

---

## 🧪 Code Style & Formatting

- **NestJS Backend**: Follow standard TypeScript rules, ESLint configuration, and explicit return types on async services.
- **Flutter App**: Follow standard Dart guidelines, maintain structured widgets, and use `ApiConfig` for backend URL constants.
