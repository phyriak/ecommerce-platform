CREATE USER order_user WITH PASSWORD 'uat-order-password';

CREATE SCHEMA order_service_uat AUTHORIZATION order_user;

GRANT USAGE ON SCHEMA order_service_uat TO order_user;
GRANT CREATE ON SCHEMA order_service_uat TO order_user;