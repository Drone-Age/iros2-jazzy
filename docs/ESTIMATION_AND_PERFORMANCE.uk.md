# Політика оцінки, обліку часу та продуктивності

Ця політика є нормативною для оцінювання роботи, вимірювання task effort,
навчання на завершених задачах і підвищення throughput без послаблення quality
gates.

## ClickUp estimate і timer

До implementation пов'язана ClickUp task повинна містити:

- built-in **Time Estimate** з initial P50 tracked work;
- P50 і P80 tracked work, calendar range та confidence (`low`, `medium` або
  `high`) в описі;
- task type із `metrics/task-types.json`;
- estimation basis, comparable task IDs, risks, unknowns, expected machine
  time й external wait.

P50 є median expected tracked work. P80 має покривати приблизно 80%
comparable outcomes. Initial estimate є незмінною history; re-estimation додає
timestamped entry з previous/new values, reason та evidence.

ClickUp start/stop tracker є авторитетним для total task work:

1. перевірте відсутність active unrelated timer;
2. запустіть його перед analysis, implementation, review, supervised build,
   verification, documentation або publication;
3. зазначте stage у description;
4. зупиніть перед очікуванням user input, credentials, hardware, external
   approval або unsupervised long-running operation;
5. запустіть новий entry після відновлення активної роботи;
6. при завершенні перенесіть ClickUp total до repository task record.

Активно контрольована machine work трекінгується. Unsupervised execution є
`machine_minutes`, очікування зовнішніх даних — `external_wait_minutes`.
Calendar duration вимірюється окремо. Якщо ClickUp недоступний, запишіть UTC
start/end локально та додайте manual entry після відновлення доступу.

## Оцінка та перерахунок

Оцінюйте bottom-up. Кожен stage записує expected tracked work, machine time,
external wait, uncertainty, prerequisites і completion evidence.
Re-estimate виконується після initial audit, першого minimal build, першого
complete build, material blocker/scope change і перед release gate.

Repository estimation database:

- `metrics/task-types.json` — taxonomy та calibration settings;
- `metrics/tasks/<id>.json` — один record на GitHub/ClickUp task pair;
- `docs/task-reports/<id>.md` — completion report;
- `schema/task-record.schema.json` — record contract;
- `scripts/task_metrics.py` — validation, calibration і report generation.

За можливості використовуйте ID `github-<issue-number>`. Не зберігайте
credentials, tokens, private host addresses або non-public personal data.

## Operations та errors

Кожна material operation записує stage, category, duration, attempt,
`PASS`/`FAIL`/`BLOCKED`/`SKIPPED`, commit, evidence і reusability.

Кожна material error записує stage, category, symptom, root cause, correction,
prevention, tracked/machine time lost та invalidated evidence. Failed attempts
є calibration inputs і не приховуються.

## Калібрування

Для completed comparable task:

```text
estimate ratio = actual ClickUp tracked minutes / initial P50 minutes
```

Використовуйте останні 5–10 completed records того самого type. Median ratio
калібрує P50, empirical 80th percentile — P80. Якщо samples менше п'яти,
застосовуйте явний risk factor і залишайте confidence `low`. Outliers
залишаються в history з annotations.

## Completion report

До закриття task створіть і закомітьте report, що містить:

- linked GitHub і ClickUp tasks;
- initial/final estimates та confidence;
- ClickUp tracked total, calendar, machine й external-wait durations;
- stage estimate-versus-actual table;
- operations, retries, errors, causes, fixes і prevention;
- commits, tags, releases, checks та evidence;
- escaped defects або підтвердження їх відсутності;
- reusable improvements і future estimation recommendations.

Task не закривається, поки record має `active`, tracked time відсутній або
report не створено.

## Performance guardrails

Оптимізуйте так: усунення duplicate work, resume verified checkpoints,
preflight checks, exact-input caches, parallelization independent stages, а
потім tuning workers/resources.

Optimization приймається лише коли mandatory gates не послаблено; cache keys
містять source lock/toolchain/flags/OS/architecture; clean uncached comparison
успішний; outputs еквівалентні; recovery залишається fail-closed; escaped
defects не зростають.

Не покращуйте reported speed зупинкою timer під час активної роботи,
приховуванням failed attempts, перенесенням роботи до untracked task або
пропуском gate.
