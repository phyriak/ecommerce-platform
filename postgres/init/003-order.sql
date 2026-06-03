CREATE USER order_user
WITH PASSWORD 'uat-order-password';

CREATE SCHEMA order_service_uat
AUTHORIZATION order_user;