SELECT 
    contest_id,
    hacker_id,
    name,
    (
        SELECT SUM(total_submissions) 
        FROM Submission_Stats s 
        WHERE s.challenge_id IN (
            SELECT challenge_id 
            FROM Challenges 
            WHERE contest_id = c.contest_id
        )
    ) AS total_submissions,

    (
        SELECT SUM(total_accepted_submissions) 
        FROM Submission_Stats s 
        WHERE s.challenge_id IN (
            SELECT challenge_id 
            FROM Challenges 
            WHERE contest_id = c.contest_id
        )
    ) AS total_accepted_submissions,

    (
        SELECT SUM(total_views) 
        FROM View_Stats v 
        WHERE v.challenge_id IN (
            SELECT challenge_id 
            FROM Challenges 
            WHERE contest_id = c.contest_id
        )
    ) AS total_views,

    (
        SELECT SUM(total_unique_views) 
        FROM View_Stats v 
        WHERE v.challenge_id IN (
            SELECT challenge_id 
            FROM Challenges 
            WHERE contest_id = c.contest_id
        )
    ) AS total_unique_views

FROM Contests c
WHERE (
    -- Filter out contests where all 4 sums would be NULL or 0
    (
        SELECT SUM(total_submissions) 
        FROM Submission_Stats 
        WHERE challenge_id IN (SELECT challenge_id FROM Challenges WHERE contest_id = c.contest_id)
    ) IS NOT NULL OR

    (
        SELECT SUM(total_accepted_submissions) 
        FROM Submission_Stats 
        WHERE challenge_id IN (SELECT challenge_id FROM Challenges WHERE contest_id = c.contest_id)
    ) IS NOT NULL OR

    (
        SELECT SUM(total_views) 
        FROM View_Stats 
        WHERE challenge_id IN (SELECT challenge_id FROM Challenges WHERE contest_id = c.contest_id)
    ) IS NOT NULL OR

    (
        SELECT SUM(total_unique_views) 
        FROM View_Stats 
        WHERE challenge_id IN (SELECT challenge_id FROM Challenges WHERE contest_id = c.contest_id)
    ) IS NOT NULL
)
ORDER BY contest_id;
