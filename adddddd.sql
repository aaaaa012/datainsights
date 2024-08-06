-- 	Loading the database and verifying the table name.
SELECT name FROM sqlite_master WHERE type='table'; 

-- Understanding the data and exploring the database schema.
PRAGMA table_info(call_statuses);
PRAGMA table_info(calls);
PRAGMA table_info(counters);
PRAGMA table_info(jobs);
PRAGMA table_info(languages);
PRAGMA table_info(permissions);
PRAGMA table_info(queues);
PRAGMA table_info(role_has_permissions);
PRAGMA table_info(roles);
PRAGMA table_info(services);
PRAGMA table_info(sqlite_sequence);	
PRAGMA table_info(users);

-- Counter Summary for a specific date
SELECT 
     c.id as counter_id,
	 c.name as counter_name,
	 COUNT(DISTINCT cll.id ) AS total_queue_called,
	 SUM(css.name='serving') AS total_serving,
	 SUM(css.name='served') AS total_served,
	 SUM(css.name='noshow') AS total_no_show
FROM 
   calls cll
JOIN
   queues q ON cll.queue_id = q.id
JOIN 
   call_statuses css ON cll.call_status_id = css.id
JOIN 
   counters c ON cll.counter_id = c.id
WHERE 
    DATE(cll.created_at) = '2024-02-14'
GROUP BY 
c.id, c.name;


-- Service summary for a specific date
SELECT
    s.id as service_id,
	s.name as service_name,
	COUNT(DISTINCT q.id) AS total_visitors,
	COUNT(DISTINCT CASE WHEN q.called = 0 THEN q.id END) AS total_queued,
	COUNT(DISTINCT CASE WHEN q.called = 1 THEN q.id END) AS total_called,
	SUM(css.name= 'serving') AS total_serving,
	SUM(css.name='served') AS total_served,
	SUM(css.name = 'noshow') AS total_no_show
FROM 
   queues q
JOIN
    services s ON q.service_id  = s.id
LEFT JOIN 
  calls cll ON q.id = cll.queue_id 
LEFT JOIN 
call_statuses css on cll.call_status_id = css.id
WHERE
   DATE(q.created_at) = '2024-02-14'
GROUP BY
s.id, s.name


-- Service X counter summary for a specific date

SELECT 
   s.id as service_id,
   s.name as service_name,
   c.id as counter_id,
   c.name as counter_name,
   COUNT(DISTINCT q.id) AS total_visitors,
   COUNT(DISTINCT cll.id) AS total_queue_called,
   SUM(CASE WHEN css.name='serving' THEN 1 ELSE 0 END) AS total_serving,
   SUM(CASE WHEN css.name='served' THEN 1 ELSE 0 END) AS total_served,
   SUM(CASE WHEN css.name='noshow' THEN 1 ELSE 0 END)AS total_no_show
FROM 
   queues q
JOIN 
   services s on q.service_id= s.id
JOIN 
  calls cll on q.id = cll.queue_id
JOIN
   counters c on cll.counter_id = c.id
JOIN 
    call_statuses css on cll.call_status_id = css.id
WHERE
   DATE(q.created_at) = '2024-02-14'
GROUP BY
  s.id, s.name, c.id, c.name
ORDER BY
  s.id, c.id;
  
  
-- Summarize the activity of agent for a specific date
SELECT 
    u.id AS agent_id,
	u.name AS agent_name,
	COUNT(DISTINCT q.id) AS total_visitors,
	COUNT(DISTINCT CASE WHEN q.called =0 THEN q.id END) AS total_queued,
	COUNT(DISTINCT CASE WHEN q.called=1 THEN q.id END) AS total_called,
	SUM(CASE WHEN css.name='serving' THEN 1 ELSE 0 END) AS total_serving,
	SUM(CASE WHEN css.name='served' THEN 1 ELSE 0 END) AS total_served,
	SUM(CASE WHEN css.name='noshow' THEN 1 ELSE 0 END) AS total_no_show
FROM 
  queues q
JOIN 
   calls cll on q.id = cll.queue_id
JOIN 
   call_statuses css ON cll.call_status_id = css.id
JOIN users u on cll.user_id = u.id
WHERE 
   DATE(q.created_at) = '2024-02-14'
GROUP BY
  u.id,  u.name
ORDER BY
 u.id;