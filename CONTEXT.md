# Baby Burrito

An iPhone app for parents to log a baby's feedings in one tap and always know when the next one is
due. All data lives on the device and in the parents' own iCloud; there is no server.

## Feedings

**Baby**:
The child whose feedings are logged. Has a name, a birth date and a feeding interval.
_Avoid_: child, infant, profile

**Feeding**:
One occasion of the baby being fed: either a nursing or a bottle.
_Avoid_: feed, meal, entry, event

**Kind**:
What a feeding was: nursing, breast milk or formula.
_Avoid_: type, category

**Nursing**:
A feeding at the breast. Has a duration and a side, never an amount.
_Avoid_: breastfeeding, breast milk

**Bottle**:
A feeding of breast milk or formula from a bottle. Has an amount, never a duration or side.

**Breast milk**:
Expressed milk given in a bottle. Not the same as nursing.
_Avoid_: pumped milk, EBM

**Formula**:
Infant formula given in a bottle.

**Side**:
Which breast a nursing used: left, right or both.
_Avoid_: breast, breast side

**Duration**:
How long a nursing lasted, in whole minutes.
_Avoid_: length, time

**Amount**:
How much a bottle held, in whole millilitres. Millilitres are the only unit.
_Avoid_: volume, quantity

**Fed at**:
When a feeding started. Intervals are measured start to start.
_Avoid_: time, logged at, created at, end time

**Birth date**:
The local calendar day the baby was born. Always set. No feeding can be fed at before it.
_Avoid_: birthday, DOB

## Timing

**Feeding interval**:
How long the baby should go between feedings. Belongs to the baby and is shared by everyone who
sees that baby's log.
_Avoid_: schedule, reminder interval

**Last feeding**:
The feeding with the latest fed at.
_Avoid_: previous feeding, most recent

**Next feeding**:
The time the next feeding is expected: the last feeding's fed at plus the feeding interval.
_Avoid_: next due, reminder

**Due**:
The state once the next feeding time has passed. Calm, never an alarm.
_Avoid_: overdue, late, missed

**Local day**:
A calendar day in the phone's current time zone. Statistics and Today's sections group by it.
_Avoid_: UTC day, 24 hours

## Logging

**Log** (verb):
To record a feeding.
_Avoid_: add, track, save, enter

**Repeat**:
Logging a copy of the last feeding: a bottle keeps its kind and amount and is fed at now; a
nursing keeps its duration, switches to the other side (both stays both) and is fed at now minus
the duration.
_Avoid_: quick log, duplicate, same again

**Logged confirmation**:
What the app shows right after a repeat: the new feeding, editable in place, with Undo.
_Avoid_: success screen, toast

**Undo window**:
The short time after a repeat or a delete during which it can be taken back.

**Author**:
The participant who logged a feeding. Shown only when it is someone other than you.
_Avoid_: creator, logged by, user

## Sharing

**Baby log**:
Everything recorded about one baby: the baby and all its feedings. Shared as a whole, never
feeding by feeding. Stored as one CloudKit zone, which is why code and plans call it a "zone".
_Avoid_: household, family, account

**Owner**:
The parent who created a baby log. Can invite, change roles and stop sharing.
_Avoid_: admin, primary parent, mom

**Participant**:
Someone the owner invited to a baby log. Is either an editor or a viewer.
_Avoid_: member, partner, guest

**Editor**:
A participant who can log, edit and delete feedings and edit the baby.
_Avoid_: read-write user, co-parent

**Viewer**:
A participant who can only see the baby log.
_Avoid_: read-only user, observer

**Invite**:
The link an owner sends to make someone a participant. Accepting it on a phone that already holds
an owned baby log replaces that log.
_Avoid_: share link, invitation code

A phone holds exactly one baby log: either one it owns or one it participates in.

## Screens and surfaces

**Today**:
The app's only main screen: next feeding, last feeding, last-24-hour totals and every feeding ever,
newest first.
_Avoid_: home, dashboard, history

**Trends**:
The screen with daily charts over 7 or 30 days.
_Avoid_: statistics, stats, reports

**Log sheet**:
The sheet for logging a feeding by hand or editing one.
_Avoid_: form, entry screen, add screen

**Live Activity**:
The Lock Screen, Dynamic Island and Apple Watch Smart Stack view of last and next feeding. Each
phone runs its own.
_Avoid_: widget, notification, banner

**Show on Lock Screen**:
The per-phone setting that keeps the Live Activity running.
