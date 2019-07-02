DROP VIEW IF EXISTS hrm.office_hour_scrud_view;

CREATE VIEW hrm.office_hour_scrud_view
AS
SELECT
    hrm.office_hours.office_hour_id,
    core.offices.office_code || ' (' || core.offices.office_name || ')' AS office,
    core.offices.logo as photo,
    hrm.shifts.shift_code || ' (' || hrm.shifts.shift_name || ')' AS shift,
    hrm.week_days.week_day_code || ' (' || hrm.week_days.week_day_name || ')' AS week_day,
    hrm.office_hours.begins_from,
    hrm.office_hours.ends_on
FROM hrm.office_hours
LEFT JOIN core.offices
ON core.offices.office_id = hrm.office_hours.office_id
LEFT JOIN hrm.shifts
ON hrm.shifts.shift_id = hrm.office_hours.shift_id
LEFT JOIN hrm.week_days
ON hrm.week_days.week_day_id = hrm.office_hours.week_day_id
WHERE NOT hrm.office_hours.deleted;
