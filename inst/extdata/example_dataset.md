# Sleep Diaries – Example Research Dataset

**Protocol period:** 14 days (2025-03-03 → 2025-03-16)  
**App version:** Sleep Diaries v1.1.1  

---

## Dataset contents

| File | Participant | Code |
|------|-------------|------|
| `sleep_diaries_export_P001_sarah_chen.json` | Sarah Chen | CIRCADIA-2025-P001 |
| `sleep_diaries_export_P002_james_okonkwo.json` | James Okonkwo | CIRCADIA-2025-P002 |
| `sleep_diaries_export_P003_priya_mehta.json` | Priya Mehta | CIRCADIA-2025-P003 |

Each file is a direct export from the Sleep Diaries app in its native JSON format, containing:
- **`entries`** — one object per morning or evening diary entry (28 entries per participant = 14 morning + 14 evening)
- **`questionnaires`** — one object per completed one-time instrument (8 questionnaires per participant)
- **`studyMetadata`** — study-level context appended at export

---

## Participant profiles

### P001 – Sarah Chen
**Profile:** 34-year-old office worker with chronic insomnia. Evening chronotype (MEQ = 31, moderate evening type; MCTQ MSF_sc = 4.58 h, late chronotype). Social jetlag = 1.83 h. Regularly uses 3 mg melatonin but reports limited efficacy.

**Key findings:**
- ISI = 19 → clinical insomnia (moderate–severe)
- PSQI = 14 → severe sleep difficulties
- ESS = 17 → excessive daytime sleepiness
- DBAS-16 mean = 6.9 → clinically relevant dysfunctional sleep beliefs
- RU-SATED = 5 / 24 → poor multidimensional sleep health
- Diary: average SOL ~65 min, average WASO ~35 min, average sleep quality 2.3/5, frequent night wakings (2–4/night). Sleep efficiency substantially below the 85% clinical threshold on workdays.
- Weekend vs workday contrast: bedtime shifts ~1–1.5 h later on free days, consistent with her late chronotype and significant social jetlag.

**Research relevance:** Textbook case for CBT-I referral research. High DBAS-16 scores alongside elevated ISI suggest that dysfunctional beliefs may be maintaining her insomnia independently of circadian misalignment. The melatonin use documented in diary entries (`mq10b`/`eq4b`) provides a medication-tracking use case.

---

### P002 – James Okonkwo
**Profile:** 28-year-old gym instructor. Definite morning chronotype (MEQ = 85; MCTQ MSF_sc = 1.33 h, early chronotype). Social jetlag = 0.33 h — near zero, indicating excellent alignment between biological and social clock.

**Key findings:**
- ISI = 0 → no insomnia
- PSQI = 1 → good sleep quality
- ESS = 2 → normal daytime alertness
- DBAS-16 mean = 1.6 → healthy sleep beliefs
- RU-SATED = 24 / 24 → perfect multidimensional sleep health
- STOP-BANG = 1 → low OSA risk
- Diary: remarkably consistent 22:00 bedtime, ~10-minute SOL, virtually zero WASO, sleep quality 4–5/5 on all but two nights, wake time 06:15–06:30 on workdays. Minimal alcohol. High exercise frequency.

**Research relevance:** Healthy reference/control participant. Demonstrates what the app looks like with a well-aligned, high-quality sleeper. Useful for:
- Establishing normative diary metric ranges
- Testing export/analysis pipelines
- Illustrating the contrast between subjective ratings (consistently 5/5) and objective-proxy metrics (efficiency >95%)

---

### P003 – Priya Mehta
**Profile:** 41-year-old NHS nurse on a 4-nights-on / 4-nights-off rotating night shift. Intermediate chronotype by MEQ (51), but MCTQ reveals extreme social jetlag (SJL = 4.92 h) due to the forced misalignment between shift schedule and biological clock. Prescribed zopiclone 7.5 mg to aid daytime sleep during shift blocks.

**Key findings:**
- ISI = 15 → clinical insomnia (moderate)
- PSQI = 13 → severe sleep difficulties
- ESS = 17 → excessive daytime sleepiness
- RU-SATED = 8 / 24 → poor sleep health
- STOP-BANG = 2 → low–intermediate OSA risk (snoring + tiredness endorsed)
- DBAS-16 mean = 5.8 → clinically relevant dysfunctional beliefs
- Diary: highly variable sleep timing across the protocol (bedtimes ranging from 08:15 to 00:30, wake times from 12:30 to 22:30). Post-shift daytime sleep consistently rated 1–2/5 quality. Recovery days show gradual improvement but never full restoration within the 4-day off block. High caffeine use during shift blocks (4–5 drinks/day). Zopiclone documented in `mq10b` on all shift-day entries.

**Research relevance:** Shift worker with clinically significant circadian disruption. This dataset is particularly useful for:
- Validating that the app handles atypical sleep timing (daytime sleep, post-midnight wake times)
- Studying the relationship between social jetlag magnitude and sleep quality ratings
- Medication adherence tracking (zopiclone use, dose, and timing captured via medication entries)
- Demonstrating within-participant sleep quality variance across shift vs. off-day periods

---

## JSON data structure reference

### Diary entry object
```json
{
  "id": "YYYY-MM-DD-{morning|evening}",
  "type": "morning" | "evening",
  "date": "YYYY-MM-DD",
  "completedAt": "ISO-8601 timestamp",
  "answers": { ... }
}
```

### Morning entry answer fields

| Field | Type | Description |
|-------|------|-------------|
| `mq1` | `{hour, minute}` | Time got into bed |
| `mq2` | `{hour, minute}` | Time tried to sleep |
| `mq3` | `{hours, minutes}` | Sleep onset latency |
| `mq4` | `"yes"/"no"` | Woke during night? |
| `mq4b` | integer | Number of night wakings (if mq4=yes) |
| `mq5` | `{hours, minutes}` | Total WASO |
| `mq6` | `{hour, minute}` | Final awakening time |
| `mq7` | `{hour, minute}` | Time got out of bed |
| `mq8` | `"yes"/"no"` | Woke earlier than planned? |
| `mq8b` | `{hours, minutes}` | How much earlier (if mq8=yes) |
| `mq9` | integer | Alcoholic drinks (previous day) |
| `mq10` | `"yes"/"no"` | Used sleep aids? |
| `mq10b` | array | Medications used (if mq10=yes) |
| `mq11` | 1–5 | Sleep quality rating |
| `mq12` | 1–5 | Morning restedness rating |
| `mq13` | string\|null | Optional free-text comments |

### Evening entry answer fields

| Field | Type | Description |
|-------|------|-------------|
| `eq1` | `"yes"/"no"` | Napped today? |
| `eq1b` | `{hours, minutes}` | Nap duration (if eq1=yes) |
| `eq2` | integer | Caffeinated drinks today |
| `eq3` | `"yes"/"no"` | Exercised today? |
| `eq4` | `"yes"/"no"` | Used sleep medications? |
| `eq4b` | array | Medications (if eq4=yes) |
| `eq5` | string\|null | Optional free-text comments |

### Medication entry structure (mq10b / eq4b)
```json
{
  "id": 1741042800000,
  "name": "Melatonin",
  "dose": "3",
  "times": ["22:00"]
}
```

### Questionnaire result object
```json
{
  "id": "ess" | "isi" | "dbas16" | "meq" | "psqi" | "rusated" | "stopbang" | "mctq",
  "completedAt": "ISO-8601 timestamp",
  "answers": { "itemId": value, ... },
  "score": number | { "msf_sc": number, "sjl": number }
}
```

MCTQ is the only instrument returning a composite score object. All others return a single number.

---

## Notes for analysis

- Time fields (`mq1`, `mq2`, `mq6`, `mq7`) use singular keys `{"hour": H, "minute": M}`.
- Duration fields (`mq3`, `mq5`, `mq8b`, `eq1b`) use plural keys `{"hours": H, "minutes": M}`.
- When computing sleep timing for P003 during shift blocks, bedtime (`mq1`) values in the morning (e.g., `08:30`) represent post-shift daytime sleep and must be interpreted on a 24-hour + wrap-around basis.
- Unused conditional fields are stored as `null` (scalar) or `[]` (medication arrays).
- All timestamps are UTC ISO-8601. The study site is UTC+0 (Newcastle upon Tyne, UK, during GMT period).
