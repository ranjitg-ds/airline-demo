-- 
-- create.cql
--
-- Author: Jeff Davies (jeff.davies@datastax)
-- Description: Handle the creation of the database tables for the airline demo.

--
-- The followng command is commented out because it has already been executed
-- in Astra web UI
-- create keyspace airline;

use airline;

-- User table
-- The password is encrypted using SHA256
drop table if exists user;
create table user (
    id uuid,
    email text,
    create_date timestamp,
    PRIMARY KEY(id)
);

insert into user(id, email, create_date) values (11110000-1111-1111-1111-111100001111, 'jeff.davies@datastax.com', '2021-01-01');
insert into user(id, email, create_date) values (22220000-1111-1111-1111-000011110000, 'ranjit.gundarlahalli@datastax.com', '2021-01-01');
insert into user(id, email, create_date) values (33330000-1111-1111-1111-000011110000, 'demo@datastax.com', '2021-01-01');

drop table if exists login;
create table login (
    id uuid,
    email text,
    password text,
    PRIMARY KEY((email), password)
);

-- emails are always stored in lower case!
-- Password is SHA256 hash of "demo"
insert into login(id, email, password) values (11110000-1111-1111-1111-111100001111, 'jeff.davies@datastax.com', '2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea');
insert into login(id, email, password) values (22220000-1111-1111-1111-000011110000, 'ranjit.gundarlahalli@datastax.com', '2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea');
insert into login(id, email, password) values (33330000-1111-1111-1111-000011110000, 'demo@datastax.com', '2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea');


-- The flights table contains a list of all possible flights
-- drop table if exists city;
-- create table city(
--     name text,
--     PRIMARY KEY(name)
-- );

-- The flights table contains a list of all possible flights
-- drop table if exists flight_by_id;
-- create table flight_by_id(
--     id text, -- This is the flight number. ex ABC0021
--     origin_city text, -- The city where this flight begins
--     destination_city text, -- The city where this flight ends
--     departure_time text, -- the scheduled time for the flight to depart. ex 10:00 AM
--     departure_gate text,  -- The gate where this flight boards. ex A12 or C27
--     PRIMARY KEY(id)
-- );

-- The flights table contains a list of all possible flights
-- drop table if exists flight_by_city;
-- create table flight_by_id(
--     id text, -- This is the flight number. ex ABC0021
--     origin_city text, -- The city where this flight begins
--     destination_city text, -- The city where this flight ends
--     departure_time text, -- the scheduled time for the flight to depart. ex 10:00 AM
--     departure_gate text,  -- The gate where this flight boards. ex A12 or C27
--     PRIMARY KEY(origin_city, destination_city)
-- );


-- The tickets table shows current tickets for customer 
-- (about to fly, in-flight and after flight) for a day or so
drop table if exists ticket;
create table ticket(
    id uuid,
    passenger_id uuid,
    passenger_name text,
    flight_id text,
    origin_city text,
    destination_city text,
    departure_time text,
    departure_gate text,
    checkin_time text,
    carousel text,
    PRIMARY KEY(id)
);

-- Search for tickets by passenger_id or flight_id
CREATE CUSTOM INDEX ON ticket (passenger_id) USING 'StorageAttachedIndex';
CREATE CUSTOM INDEX ON ticket (flight_id) USING 'StorageAttachedIndex';

drop table if exists baggage;
create table baggage(
    id uuid,
    ticket_id uuid,
    passenger_id uuid,
    passenger_name text,
    image text,
    flight_id text, 
    origin_city text, 
    destination_city text,
    carousel text,
    PRIMARY KEY((flight_id), id)
);

-- Search for bags by passenger_id
CREATE CUSTOM INDEX ON baggage (passenger_id) USING 'StorageAttachedIndex';
