# claude-kit

Переиспользуемый набор для Claude Code под проекты на **Laravel 11 + Vue 3**: агенты, скиллы, воркфлоу-команды и команды первичной настройки проекта.

## Что внутри

- **Агенты** — backend-dev, frontend-dev, ревьюеры (code / security / performance / architecture / feature-integration), тестировщики, документаторы.
- **Скиллы** — знания о канонах backend/frontend CRUD, i18n, вёрстке, тестах, документации.
- **Команды** — воркфлоу (`feature`, `review`, `tests`, `doc`, `deep-review`, `handoff`, `phpstan-safe-fix`) и настройка проекта (`setup`, `mcp`, `lint`).
- **Хуки** — авто-фикс PHP (`php -l` + phpcbf/pint) и фронта (prettier + eslint) после правок. Безопасны без тулинга: нет бинаря — тихо пропускают.

## Установка

1. Поставить serena (обязательный MCP, ставится отдельно):
   ```
   claude plugin install serena
   ```
2. Добавить marketplace:
   ```
   claude plugin marketplace add github:your-org/claude-kit
   ```
3. Установить плагин:
   ```
   claude plugin install claude-kit
   ```

## Первичная настройка проекта

В корне нового проекта прогнать по очереди:

1. `/claude-kit:setup` — детект стека (composer/package/.env), пара уточняющих вопросов, генерация `.claude/CLAUDE.md` под проект.
2. `/claude-kit:mcp` — проверка доступности нужных MCP (serena, postgres) и генерация `.mcp.json`.
3. `/claude-kit:lint` — установка/подключение линтеров и хуков авто-фикса.
