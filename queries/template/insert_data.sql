INSERT INTO employees (employee_id,  first_name,
                       last_name,    date_of_birth, 
                       phone_number, junk)
SELECT gen.n +1,
       GROUP_CONCAT(CHAR((RAND() * 25)+97) SEPARATOR ''),
       GROUP_CONCAT(CHAR((RAND() * 25)+97) SEPARATOR ''),
       SUBDATE(CURDATE(), INTERVAL (RAND()*3650 + 40*365) DAY),
       FLOOR(RAND()*9000+1000),
       'junk'
  FROM generator_4k gen, generator_16 rand
 WHERE gen.n < 1000
 GROUP BY gen.n;