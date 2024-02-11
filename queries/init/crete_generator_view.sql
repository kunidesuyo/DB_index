CREATE OR REPLACE VIEW generator_16
AS SELECT 0 n UNION ALL SELECT 1  UNION ALL SELECT 2  UNION ALL
   SELECT 3   UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL
   SELECT 6   UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL
   SELECT 9   UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
   SELECT 12  UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL
   SELECT 15;

CREATE OR REPLACE VIEW generator_256
AS SELECT ( ( hi.n << 4 ) | lo.n ) AS n
     FROM generator_16 lo, generator_16 hi;

CREATE OR REPLACE VIEW generator_4k
AS SELECT ( ( hi.n << 8 ) | lo.n ) AS n
     FROM generator_256 lo, generator_16 hi;
     
CREATE OR REPLACE VIEW generator_64k
AS SELECT ( ( hi.n << 8 ) | lo.n ) AS n
     FROM generator_256 lo, generator_256 hi;

CREATE OR REPLACE VIEW generator_1m
AS SELECT ( ( hi.n << 4 ) | lo.n ) AS n
     FROM generator_16 lo, generator_64k hi;