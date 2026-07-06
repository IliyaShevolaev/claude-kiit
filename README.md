# claude-kit

Переиспользуемый набор для Claude Code под проекты на **Laravel 11 + Vue 3**: агенты, скиллы, воркфлоу-команды и команды первичной настройки проекта.

## Что внутри

- **Агенты** — backend-dev, frontend-dev, ревьюеры (code / security / performance / architecture / feature-integration), тестировщики, документаторы.
- **Скиллы** — переносимые каноны backend/frontend (`*-conventions-knowledge`, `*-crud-flow-knowledge`), скиллы проектной правды (`*-utilities-knowledge` — заполняются `setup`), а также i18n, вёрстка, тесты, документация.
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

1. `/claude-kit:setup` — два Explore-агента исследуют кодовую базу (back + front), затем команда сама пишет два скилла проектной правды — `backend-utilities-knowledge` и `frontend-utilities-knowledge` (`SKILL.md` + `references/crud-examples.md`) — и генерирует `.claude/CLAUDE.md`. Агенты и портируемые скиллы (`*-conventions-knowledge`, `*-crud-flow-knowledge`) не трогаются: вся специфика проекта живёт в двух utilities-скиллах.
2. `/claude-kit:mcp` — проверка доступности нужных MCP (serena, postgres) и генерация `.mcp.json`.
3. `/claude-kit:lint` — установка/подключение линтеров и хуков авто-фикса.

## Вендоринг (редактируемые файлы в репозитории)

Если команде нужно править агентов/скиллы/команды прямо в репозитории, а не тянуть их из плагина:

- `/claude-kit:vendor` — копирует `agents/skills/commands/hooks/templates` в `.claude/` проекта, прописывает хуки в `.claude/settings.json` и переводит пути на проектные. После этого плагин для проекта не нужен — удалить его: `claude plugin uninstall claude-kit`.

Дальше как обычно `/claude-kit:setup` (он уже работает с вендоренными копиями в `.claude/`). Всё под `.claude/` становится обычными файлами репозитория — каждый может редактировать, изменения коммитятся и разъезжаются по команде.
