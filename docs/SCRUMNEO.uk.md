# Життєвий цикл задач ScrumNEO

Ця політика визначає життєвий цикл статусів ClickUp і правила коментарів до
задач у цьому репозиторії. `TASK_MANAGEMENT.md` залишається авторитетним щодо
зв'язку GitHub/ClickUp і власності evidence.

## Групи статусів

| Група | Статус | Значення |
|---|---|---|
| Not started | `backlog` | Зареєстровано, але ще не затверджено або не заплановано. |
| Not started | `todo` | Затверджено, оцінено та готово до початку. |
| Active | `preparation` | Активна супровідна робота з process, environment, documentation, access або coordination, яка безпосередньо не виконує deliverable задачі. |
| Active | `analyse` | Досліджуються вимоги, обмеження, ризики або defect. |
| Active | `planning` | Готуються scope, етапи, оцінки, acceptance criteria та owners. |
| Active | `in progress` | Активна реалізація або execution gate. |
| Active | `in review` | Code, documentation, evidence або результати проходять review. |
| Active | `completed` | Реалізацію та обов'язкові checks завершено; очікується acceptance. |
| Active | `accepted` | Owner прийняв результат; очікується адміністративне завершення. |
| Active | `rejected` | Review або acceptance не пройдено; фіксуються причина й необхідна доробка. |
| Active | `blocked` | Робота не може тривати без визначених input, event, permission або dependency. |
| Done | `complete` | Прийнятий результат і всі пов'язані work items завершено. |
| Done | `cancelled` | Роботу свідомо припинено або замінено без delivery. |
| Closed | `closed` | Архівний terminal state; лише після `complete` або `cancelled`. |

## Переходи

Типовий успішний потік:

```text
backlog -> todo -> preparation -> analyse -> planning -> in progress -> in review
        -> completed -> accepted -> complete -> closed
```

`preparation` використовується лише тоді, коли основною поточною діяльністю є
супровідна робота, наприклад створення regulations, access, tooling, build
infrastructure або task coordination. Дослідження technical requirements
задачі є `analyse`; визначення execution stages та estimates є `planning`;
створення deliverable є `in progress`.

Задача може пропустити `preparation`, `analyse` або `planning` лише тоді, коли
відповідні результати вже існують і пов'язані із задачею або етап не потрібен.
Після з'ясування причини `rejected` повертається до `analyse`, `planning` або
`in progress`. Після `blocked` задача повертається до стану поновленої роботи.
Тимчасовий `preparation` після завершення повертається до попереднього delivery
state. Checkpoint comment має визначати цей попередній статус і умову
поновлення.

`complete` означає успішний delivery. `cancelled` означає відсутність delivery.
`closed` є архівним і не повинен приховувати terminal outcome.

Статус має відображати стан усієї задачі, а не коротку підоперацію агента.

## Коментарі до задачі

Коментарі ClickUp є хронологічним coordination log. Description містить
поточні objective, scope, estimate, checklist і summary; коментарі фіксують
суттєві події без переписування історії.

Пишіть коментар для:

- змін approval, scope, version, estimate або priority;
- завершення analysis або planning;
- commit або pull request, відправленого для review;
- PASS/FAIL результатів build, test, audit, migration або release gate;
- появи, зміни або усунення blocker;
- rejection і точної необхідної доробки;
- acceptance owner;
- публікації tag, release, artifact або post-release verification;
- cancellation або остаточного completion.

Не пишіть коментарі для звичайних команд, незмінного polling, проміжного
прогресу або інформації з попереднього коментаря. Об'єднуйте пов'язані
низькорівневі дії в один checkpoint.

Кожен checkpoint comment повинен містити:

```text
Stage/status:
Result: PASS | FAIL | BLOCKED | INFO
Completed:
Evidence: commit, issue, PR, log, artifact або release link
Next:
Blocker/owner action: none або точна необхідна дія
Estimate impact: none або уточнені P50/P80 з причиною
```

Автоматичні коментарі використовують UTC timestamp. Сповіщайте assignees лише
коли потрібне їх рішення чи дія або опубліковано прийнятий release. Коментар
не замінює довговічний GitHub technical evidence.

## Резервний шлях інтеграції коментарів

Після публікації перевірте всі умови:

- editor очищено;
- Activity показує окремий comment entry з author і timestamp;
- свіже читання comments повертає новий comment або його identifier.

Текст, який залишився в editor або лише присутній деінде на сторінці, не є
publication evidence. Якщо ClickUp comment API не працює:

1. не повторюйте багаторазово ту саму mutation;
2. опублікуйте через authenticated ClickUp interface, якщо він доступний,
   використовуючи підтримуваний submit shortcut або control, а потім виконайте
   всі перевірки вище;
3. якщо interface недоступний, оновіть current summary задачі та запишіть
   обмеження connector до repository task error log;
4. збережіть durable evidence і повний checkpoint у пов'язаній GitHub Issue;
5. відновіть відсутній ClickUp comment після виправлення integration access.
