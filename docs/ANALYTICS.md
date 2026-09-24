# Product analytics events

Generic `page/open` and diagnostic telemetry remains available for exploratory
analysis. Typed events below add stable semantics where a route alone is
ambiguous. Analytics failures must never block navigation or schedule access.

## `schedule/home_open` (schema version 1)

Product question: which saved primary groups, courses, and faculties open the
home schedule?

Trigger: once when a `HomePage` instance resolves a complete saved primary
group. It is not emitted when the user has no primary group and is redirected
to selection. A new `HomePage` instance may emit a new event, so use
AppMetrica's deduplicated users rather than event totals to count people.

Attributes:

- `schema_version`: `1`;
- `relationship`: always `primary`;
- `scope`: always `group`;
- `group_id`: stable public schedule group ID encoded as a string;
- `group_name`: normalized public group code, or `unknown` when empty or longer
  than 64 characters;
- `course`: bounded course value encoded as a string;
- `faculty_id`: stable public faculty ID encoded as a string.

The event identifies the schedule assigned to home. It does not mean that a
fresh network schedule loaded successfully and must not be used as a substitute
for the planned `schedule/view_ready` event. Favorites and temporarily viewed
schedules must not emit `schedule/home_open` for their displayed group.

Recommended report: deduplicated users of `schedule/home_open`, broken down by
`group_id` or `group_name`, then by `course` or `faculty_id`, segmented by app
version and complete calendar days. Do not sum daily unique-user rows to obtain
a multi-day unique-user total.

Never add lesson contents, notes, professor names, notification payloads,
credentials, tokens, full URLs, or other user-authored/free-form values to this
event.
