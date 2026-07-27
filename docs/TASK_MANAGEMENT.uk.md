# Керування задачами та продовження між сесіями

Ця політика є нормативною для implementation, process, documentation і
release-робіт у цьому репозиторії.

Time estimates, використання ClickUp timer, historical metrics і completion
reports регулюються `ESTIMATION_AND_PERFORMANCE.md`.
Статуси ClickUp, transitions і task comments регулюються `SCRUMNEO.md`.

## 1. Обов'язкові work items

Суттєва робота повинна мати:

1. одну відкриту GitHub Issue в репозиторії;
2. одну ClickUp task у відповідному component list;
3. взаємні посилання між ними;
4. явний стан approval до початку реалізації.

Невеликі виправлення лише друкарських помилок можна записати безпосередньо в
pull request або commit, якщо вони не змінюють поведінку, scope чи процес.

Після затвердження scope назва GitHub Issue має використовувати
`[APPROVED]`. Додайте label `approved` і відповідний type label, наприклад
`release`, `enhancement`, `bug` або `documentation`.

## 2. Розподіл джерел істини

GitHub є авторитетним для:

- snapshots source code і документації;
- commits, branches, pull requests, tags і releases;
- technical scope та definition of done;
- build/test commands, logs, checksums, manifests і gate evidence;
- незмінного історичного стану.

ClickUp є авторитетним для:

- planning status, priority, owner, schedule і coordination;
- business objective та cross-component impact;
- stage checklist і поточного blocker summary;
- посилань на пов'язані задачі поза цим репозиторієм.

Дубльована інформація має залишатися технічно еквівалентною. Якщо системи
відрізняються, незмінний Git evidence визначає технічні факти, а ClickUp —
поточний planning state. Розбіжність виправляється на наступному checkpoint.

## 3. Обов'язковий вміст задачі

Обидва пов'язані work items мають визначати:

- мету та user-visible result;
- затверджений scope і явні exclusions;
- product version/tag та process version/tag, якщо застосовно;
- поточний source або build commit;
- впорядковані етапи з checkboxes;
- acceptance criteria;
- відомі risks, зовнішні dependencies і blockers;
- evidence links для завершених gate.

Не позначайте етап завершеним лише тому, що написано код. Завершення потребує
зазначеної перевірки або evidence.

## 4. Відповідність статусів

Застосовуйте таку mapping. Детальні transition rules визначено в
`SCRUMNEO.md`:

| Стан роботи | GitHub | ClickUp |
|---|---|---|
| Запропоновано | Open Issue без `approved` | `backlog` |
| Затверджено, готово до початку | Open Issue з `approved` | `todo` |
| Супровідна підготовка | Open Issue | `preparation` |
| Analysis | Open Issue | `analyse` |
| Planning | Open Issue | `planning` |
| Активна реалізація або gate | Open Issue | `in progress` |
| Review | Open Issue або Pull Request | `in review` |
| Checks завершено, очікується acceptance | Open Issue | `completed` |
| Owner прийняв | Open Issue з acceptance comment | `accepted` |
| Review або acceptance не пройдено | Open Issue з rejection evidence | `rejected` |
| Потрібні зовнішні дані | Open Issue з blocker comment | `blocked` |
| Прийнято й повністю зафіксовано | Closed as completed | `complete` |
| Скасовано або замінено | Closed as not planned | `cancelled` |
| Архівовано після terminal outcome | Closed | `closed` |

Blocker не закриває задачу. Запишіть точні відсутні дані, останній успішний
checkpoint і безпечну resume command.

## 5. Checkpoints та оновлення прогресу

Оновлюйте обидві системи після кожного material checkpoint:

- затвердженої зміни scope або версії;
- commit, відправленого для review/build;
- результату build, test, audit або release gate;
- появи, зміни або усунення blocker;
- фіналізації manifest;
- публікації tag або release;
- post-release verification.

Запустіть ClickUp timer перед активною роботою над checkpoint і зупиніть його,
коли активна робота призупиняється. Chat session не є time record.

Кожне checkpoint update містить:

- UTC timestamp, якщо його створює automation;
- точний commit SHA;
- завершений і наступний етап;
- commands/checks та результат PASS/FAIL;
- посилання на logs, artifacts, pull requests, releases або evidence;
- blocker і потрібну дію owner, якщо є.

GitHub отримує довговічний technical evidence. ClickUp отримує стислий
planning summary і посилання на цей evidence. Суттєві події також фіксуються
як хронологічні ClickUp task comments згідно з `SCRUMNEO.md`. Оновлення лише
description задачі або chat не виконує цю політику, коли comment posting
доступний.

## 6. Зміни scope і версії

Коли затверджений scope змінюється:

1. оновіть GitHub Issue та ClickUp task до продовження реалізації;
2. запишіть, хто затвердив зміну і чому;
3. оновіть застосовні normative documents і version files;
4. визначте checks або artifacts, що стали недійсними;
5. повторіть кожен affected gate.

Product і process versions підпорядковуються `VERSIONING.md`. Ніколи не
пересувайте й не використовуйте tag повторно заради видимої узгодженості
task tracking.

## 7. Startup protocol нової сесії

`AGENTS.md` є автоматичним entrypoint для нової agent session. До внесення
змін сесія повинна:

1. прочитати `docs/README.md` і цю політику;
2. перевірити repository status, current branch, `VERSION` і
   `PROCESS_VERSION`;
3. знайти пов'язані GitHub Issue та ClickUp task у поточному work context;
4. прочитати їхній останній стан і порівняти його з Git;
5. визначити останній verified checkpoint, наступний unchecked stage і
   blockers;
6. публікувати update лише за material state change.

Якщо пов'язану задачу неможливо безпечно визначити, зупиніть реалізацію,
повідомте про відсутній linkage і запросіть task identifier. Не створюйте
duplicate work items на припущеннях.

## 8. Завершення

Перед закриттям пов'язаних задач:

1. усі acceptance criteria та mandatory gates успішні;
2. final commits і незмінні tags відправлені;
3. release/evidence links наявні в обох системах;
4. документація та версії відповідають опублікованому стану;
5. GitHub Issue закрита як completed;
6. ClickUp checklist завершений і status дорівнює `complete`; `closed` може
   слідувати лише як archival transition.

Post-release defects створюють нову пов'язану task і PATCH version. Вони не
відкривають повторно й не переписують immutable release history.
