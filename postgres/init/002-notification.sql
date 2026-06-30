CREATE USER notification_user
WITH PASSWORD 'uat-notification-password';

GRANT CONNECT ON DATABASE ecommerce TO notification_user;

CREATE SCHEMA notification_service_uat
AUTHORIZATION notification_user;

GRANT USAGE ON SCHEMA notification_service_uat TO notification_user;
GRANT CREATE ON SCHEMA notification_service_uat TO notification_user;