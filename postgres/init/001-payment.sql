CREATE USER payment_user WITH PASSWORD 'uat-payment-password';

CREATE SCHEMA payment_service_uat
AUTHORIZATION payment_user;

GRANT CONNECT ON DATABASE ecommerce TO payment_user;
GRANT USAGE ON SCHEMA payment_service_uat TO payment_user;
GRANT CREATE ON SCHEMA payment_service_uat TO payment_user;