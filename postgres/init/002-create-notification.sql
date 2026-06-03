CREATE USER notificationt_user WITH PASSWORD 'uat-notification-password';

CREATE SCHEMA notification_service_uat AUTHORIZATION notification_user;

GRANT USAGE ON SCHEMA notification_service_uat TO notification_user;
GRANT CREATE ON SCHEMA notification_service_uat TO notification_user;