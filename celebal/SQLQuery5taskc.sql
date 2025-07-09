
SELECT *
  FROM (
    VALUES
      (15758, 'Rose'),
      (20703, 'Angela'),
      (36396, 'Frank'),
      (38289, 'Patrick'),
      (44065, 'Lisa'),
      (53473, 'Kimberly'),
      (62529, 'Bonnie'),
      (79722, 'Michael');

  INSERT INTO submission (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 60),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76187, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-06', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);















WITH dates AS (
    SELECT DISTINCT submission_date 
    FROM Submissions
    WHERE submission_date BETWEEN '2016-03-01' AND '2016-03-15'
),

daily_submissions AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(*) AS submissions_count
    FROM Submissions
    GROUP BY submission_date, hacker_id
),

daily_top_hacker AS (
    SELECT 
        submission_date,
        hacker_id,
        ROW_NUMBER() OVER (
            PARTITION BY submission_date 
            ORDER BY submissions_count DESC, hacker_id
        ) AS rank
    FROM daily_submissions
),

consecutive_hackers AS (
    SELECT 
        hacker_id,
        submission_date,
        DENSE_RANK() OVER (ORDER BY submission_date) AS day_num,
        DENSE_RANK() OVER (PARTITION BY hacker_id ORDER BY submission_date) AS hacker_day_num
    FROM (SELECT DISTINCT hacker_id, submission_date FROM Submissions) AS s
)

SELECT 
    d.submission_date,
    (SELECT COUNT(DISTINCT ch.hacker_id) 
     FROM consecutive_hackers ch 
     WHERE ch.submission_date = d.submission_date AND ch.day_num = ch.hacker_day_num
    ) AS consecutive_hackers_count,
    (SELECT dth.hacker_id 
     FROM daily_top_hacker dth 
     WHERE dth.submission_date = d.submission_date AND dth.rank = 1
    ) AS hacker_id,
    (SELECT h.name 
     FROM Hackers h 
     WHERE h.hacker_id = (
         SELECT dth.hacker_id 
         FROM daily_top_hacker dth 
         WHERE dth.submission_date = d.submission_date AND dth.rank = 1
     )
    ) AS name
FROM dates d
ORDER BY d.submission_date;