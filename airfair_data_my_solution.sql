select DISTINCT Year
from airfare_data_1;

select min(year) as 'starting_year',
	max(year) as 'ending_year'
from airfare_data_1;

select DISTINCT city1,
	city2,
	case when nsmiles = (select max(nsmiles) from airfare_data_1) then nsmiles
	end as 'max_distance',
	case when nsmiles = (select min(nsmiles) from airfare_data_1) then nsmiles
	end as 'min_distance'
from airfare_data_1
where max_distance is not null or min_distance is not null;

with tot_count as (
select distinct city1
from airfare_data_1
union
select distinct city2
from airfare_data_1
)

select 	count(*)
from tot_count;

select carrier_low,
	count(*) as 'freq'
from airfare_data_1
group by 1
order by 2 desc;

select carrier_lg,
	count(*) as 'freq'
from airfare_data_1
group by 1
order by 2 desc;

select carrier_lg,
	round(100.0 * sum(passengers) / (select sum(passengers) from airfare_data_1), 2) as 'market_share'
from airfare_data_1
group by 1
order by 2 desc;

select count(*)
from airfare_data_1
where carrier_lg = 'WN'
	and fare_lg > fare_low;

select round(avg(fare_lg - fare_low), 2) as 'fare_difference'
from airfare_data_1
where carrier_lg = 'WN'
		and fare_lg > fare_low;

with avg_fare_1997 as (
select round(avg(fare_lg), 2) as 'avg_97',
	city1,
	city2
from airfare_data_1
where year = '1997'
group by city1, city2
),
avg_fare_2007 as (
select round(avg(fare_lg), 2) as 'avg_07',
	city1,
	city2
from airfare_data_1
where year = '2007'
group by city1, city2
),
avg_fare_2017 as (
select round(avg(fare_lg), 2) as 'avg_17',
	city1,
	city2
from airfare_data_1
where year = '2017'
group by city1, city2
),
merge_97_17 as (
select a.city1,
	a.city2,
	a.avg_97,
	b.avg_17
from avg_fare_1997 as a
join avg_fare_2017 as b
	on a.city1 = b.city1
	and a.city2 = b.city2
),
merge_07_17 as (
select a.city1,
	a.city2,
	a.avg_07,
	b.avg_17
from avg_fare_2007 as a
join avg_fare_2017 as b
	on a.city1 = b.city1
	and a.city2 = b.city2
)

select city1,
	city2,
	round(100.0 * (avg_17 - avg_97) / avg_97, 2) as 'per_change_07_17'
from merge_97_17
order by 3 DESC;

select city1,
	city2,
	round(100.0 * (avg_17 - avg_07) / avg_07, 2) as 'per_change_07_17'
from merge_07_17
order by 3 DESC;

with quarters as (
select year,
	quarter,
	round(avg(fare), 2) as 'avg_fare'
from airfare_data_1
group by 1, 2
order by 1, 2
)

select year,
	quarter,
	case when avg_fare = (select min(avg_fare) from quarters) then avg_fare
	end as 'max_avg',
	case when avg_fare = (select max(avg_fare) from quarters) then avg_fare
	end as 'min_avg'
from quarters
where max_avg is not null or min_avg is not null;






with quarters as (
select city1,
	city2,
	quarter
from airfare_data_1
group by 1, 2, 3
order by 1, 2, 3
),
quarters_count as (
select city1,
	city2,
	count(quarter) as 'n_q'
from quarters
group by 1, 2
),
merge_quarters as (
select a.*,
	b.n_q
from airfare_data_1 as 'a'
left join quarters_count as 'b'
	on a.city1 = b.city1
	and a.city2 = b.city2
)

select quarter,
	round(avg(fare), 2) as 'avg_fare'
from merge_quarters
where n_q != 4
group by 1;

with quarters_1 as (
select city1,
	city2,
	year,
	quarter
from airfare_data_1
group by 1, 2, 3, 4
order by 1, 2, 3, 4
),
only_4q as (
select city1,
	city2,
	year,
	count(quarter) as 'count_q'
from quarters_1
group by 1, 2, 3
having count_q = 4
),
merge_4q as (
select a.*,
	b.count_q
from airfare_data_1 as a
left join only_4q as b
	on a.city1 = b.city1
	and a.city2 = b.city2
	and a.year = b.year
)

select quarter,
	round(avg(fare), 2) as 'avg_fare'
from merge_4q
where count_q = 4
group by 1;