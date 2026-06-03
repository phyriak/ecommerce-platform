CREATE USER notification_user
WITH PASSWORD 'uat-notification-password';

CREATE SCHEMA notification_service_uat
AUTHORIZATION notification_user;