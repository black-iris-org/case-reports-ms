WITH recent_revisions AS (
        SELECT DISTINCT ON (case_report_id) case_report_id, id
        FROM revisions
        ORDER BY case_report_id, incident_at DESC
    ),
     counts AS (
        SELECT case_report_id, COUNT(*) AS revisions_count
        FROM revisions
        GROUP BY case_report_id
    )
SELECT case_reports.id,
       case_reports.incident_number,
       recent_revisions.id AS revision_id,
       counts.revisions_count,
       CASE WHEN counts.revisions_count = 1 THEN 0 ELSE 1 END AS report_type
FROM case_reports
         JOIN recent_revisions ON (case_reports.id = recent_revisions.case_report_id)
         JOIN counts ON (case_reports.id = counts.case_report_id);