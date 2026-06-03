CREATE USER payment_user
WITH PASSWORD 'payment_service_uat';

CREATE SCHEMA payment_service_uat
AUTHORIZATION payment_user;