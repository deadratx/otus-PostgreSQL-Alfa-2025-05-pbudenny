set search_path to bookings;

-- Табло вылетов
create index on flights(scheduled_departure);
drop index if exists flights_scheduled_departure_idx;
analyze flights;

explain (costs, verbose, format text, analyze)
select
  flights.flight_no,
  flights.status,
  flights.scheduled_departure,
  flights.departure_airport,
  departure_airports_data.airport_name ->> 'ru' AS departure_airport_name,
  flights.scheduled_arrival,
  flights.arrival_airport,
  arrival_airports_data.airport_name ->> 'ru' AS arrival_airport_name
from flights
  inner join airports_data AS departure_airports_data
    on flights.departure_airport = departure_airports_data.airport_code
  inner join airports_data AS arrival_airports_data
    on flights.arrival_airport = arrival_airports_data.airport_code
where
  flights.departure_airport = 'DME'
  and flights.scheduled_departure between cast('2017-08-11 00:00:00+03' as timestamp with time zone) and cast('2017-08-17 23:59:59+03' as timestamp with time zone)
order by flights.scheduled_departure;


-- Табло вылетов с функцией
explain (costs, verbose, format text, analyze)
select
  flights.flight_no,
  flights.status,
  flights.scheduled_departure,
  flights.departure_airport,
  departure_airports_data.airport_name ->> 'ru' AS departure_airport_name,
  flights.scheduled_arrival,
  flights.arrival_airport,
  arrival_airports_data.airport_name ->> 'ru' AS arrival_airport_name
from flights
  inner join airports_data AS departure_airports_data
    on flights.departure_airport = departure_airports_data.airport_code
  inner join airports_data AS arrival_airports_data
    on flights.arrival_airport = arrival_airports_data.airport_code
where
  flights.departure_airport = 'DME'
  and date_trunc('day', flights.scheduled_departure) between cast('2017-08-11' as date) and cast('2017-08-17' as date)
order by flights.scheduled_departure;


-- Задержка вылетов
create index on flights((actual_departure - scheduled_departure));
drop index if exists flights_expr_idx;
analyze flights;

explain (costs, verbose, format text, analyze)
select
  flights.flight_no,
  flights.scheduled_departure,
  flights.actual_departure,
  flights.actual_departure - flights.scheduled_departure AS departure_delay
from flights
where flights.departure_airport = 'DME'
  and flights.actual_departure is not null
  and flights.actual_departure - flights.scheduled_departure >= cast('00:30:00' as interval);


-- Поиск билетов с email
create index on tickets using gin (contact_data);
drop index if exists tickets_contact_data_idx;
analyze tickets;

explain (costs, verbose, format text, analyze)
select 
  passenger_id,
  passenger_name,
  contact_data ->> 'email' AS email
from tickets
where contact_data ? 'email';