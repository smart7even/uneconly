const minScheduleWeek = 1;
const maxScheduleWeek = 53;

bool isValidScheduleWeek(int week) =>
    week >= minScheduleWeek && week <= maxScheduleWeek;
