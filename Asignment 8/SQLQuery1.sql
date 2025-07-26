-- STEP 01 ---
CREATE TABLE DateDimension (
    SKDate INT PRIMARY KEY, -- Format: YYYYMMDD
    KeyDate DATE,
    CalendarDay INT,
    CalendarMonth INT,
    CalendarQuarter INT,
    CalendarYear INT,
    DayNameLong VARCHAR(20),
    DayNameShort VARCHAR(10),
    DayNumberOfWeek INT,
    DayNumberOfYear INT,
    DaySuffix VARCHAR(5),
    FiscalWeek INT,
    FiscalPeriod INT,
    FiscalQuarter INT,
    FiscalYear INT,
    FiscalYearPeriod VARCHAR(6)
);

-- STEP 02 ---
CREATE PROCEDURE PopulateDateDimension
    @InputDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE = DATEFROMPARTS(YEAR(@InputDate), 1, 1);
    DECLARE @EndDate DATE = DATEFROMPARTS(YEAR(@InputDate), 12, 31);

    ;WITH DateSeries AS (
        SELECT @StartDate AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateSeries
        WHERE DateValue < @EndDate
    )
    INSERT INTO DateDimension (
        SKDate, KeyDate, CalendarDay, CalendarMonth, CalendarQuarter,
        CalendarYear, DayNameLong, DayNameShort, DayNumberOfWeek,
        DayNumberOfYear, DaySuffix, FiscalWeek, FiscalPeriod,
        FiscalQuarter, FiscalYear, FiscalYearPeriod
    )
    SELECT
        CONVERT(INT, FORMAT(DateValue, 'yyyyMMdd')) AS SKDate,
        DateValue AS KeyDate,
        DAY(DateValue) AS CalendarDay,
        MONTH(DateValue) AS CalendarMonth,
        DATEPART(QUARTER, DateValue) AS CalendarQuarter,
        YEAR(DateValue) AS CalendarYear,
        DATENAME(WEEKDAY, DateValue) AS DayNameLong,
        LEFT(DATENAME(WEEKDAY, DateValue), 3) AS DayNameShort,
        DATEPART(WEEKDAY, DateValue) AS DayNumberOfWeek,
        DATEPART(DAYOFYEAR, DateValue) AS DayNumberOfYear,
        CAST(DAY(DateValue) AS VARCHAR(2)) +
            CASE
                WHEN DAY(DateValue) IN (11,12,13) THEN 'th'
                WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR(2)),1) = '1' THEN 'st'
                WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR(2)),1) = '2' THEN 'nd'
                WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR(2)),1) = '3' THEN 'rd'
                ELSE 'th'
            END AS DaySuffix,
        DATEPART(WEEK, DateValue) AS FiscalWeek,
        MONTH(DateValue) AS FiscalPeriod,
        DATEPART(QUARTER, DateValue) AS FiscalQuarter,
        YEAR(DateValue) AS FiscalYear,
        CAST(YEAR(DateValue) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(DateValue) AS VARCHAR(2)), 2) AS FiscalYearPeriod
    FROM DateSeries
    OPTION (MAXRECURSION 366);
END;

-- STEP 03 ---

EXEC PopulateDateDimension @InputDate = '2020-07-14';

-- STEP 04 ---
SELECT * FROM DateDimension WHERE CalendarYear = 2020;
