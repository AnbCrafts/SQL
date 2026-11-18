select DATENAME(WEEKDAY,'2020-10-11') as day

select DATEADD(day,10,'2020-10-11') as day

select  DATEADD(day,10,CAST(DATENAME(WEEKDAY,'2020-10-11') as date)) as day