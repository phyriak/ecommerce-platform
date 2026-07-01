NGINX – Reverse Proxy i Rate Limiting
Cel

Resilience4j (Bulkhead, CircuitBreaker) chroni zasoby aplikacji dopiero po przyjęciu żądania przez Spring Boot. W przypadku bardzo dużego ruchu problem może pojawić się wcześniej – na poziomie serwera HTTP (Tomcat). Jeżeli wszystkie wątki Tomcata są zajęte, nowe żądania oczekują w kolejce lub kończą się timeoutem.

Aby ograniczyć liczbę żądań trafiających do aplikacji zastosowano NGINX jako Reverse Proxy z mechanizmami Rate Limiting oraz Connection Limiting.

Architektura:

                Clients
                    │
                    ▼
               +-----------+
               |   NGINX   |
               |-----------|
               | RateLimit |
               | ConnLimit |
               +-----------+
                    │
                    ▼
          Spring Boot (Tomcat)
                    │
     +--------------+--------------+
     |                             |
     ▼                             ▼
Bulkhead                  Circuit Breaker
│                             │
└──────────────┬──────────────┘
▼
HikariCP
│
▼
PostgreSQL
Reverse Proxy

NGINX pełni rolę pojedynczego punktu wejścia do aplikacji.

Cały ruch HTTP trafia najpierw do NGINX, który następnie przekazuje go do kontenera payment-service.

upstream payment_service {
server payment-service:8082;
}

server {

    listen 80;

    location / {
        proxy_pass http://payment_service;
    }
}

Dzięki temu klienci komunikują się wyłącznie z NGINX:

http://server/api/v1/payments/15

zamiast bezpośrednio z:

http://server:8082/api/v1/payments/15
Rate Limiting

Rate Limiting ogranicza liczbę żądań wykonywanych przez pojedynczego klienta.

Konfiguracja:

limit_req_zone $binary_remote_addr zone=payment_rate:10m rate=500r/s;

location / {
limit_req zone=payment_rate burst=200;
}
Jak działa?

rate=500r/s

Maksymalnie 500 requestów na sekundę z jednego adresu IP.

burst=200

Dodatkowe 200 requestów może zostać chwilowo zaakceptowanych podczas krótkiego wzrostu ruchu.

Po przekroczeniu limitu NGINX zwraca:

HTTP 429 Too Many Requests

zamiast przekazywać żądanie do aplikacji.

Connection Limiting

Drugim mechanizmem jest ograniczenie liczby jednoczesnych połączeń.

limit_conn_zone $binary_remote_addr zone=payment_conn:10m;

location / {
limit_conn payment_conn 100;
}

Każdy klient może utrzymywać maksymalnie 100 aktywnych połączeń.

Po przekroczeniu limitu NGINX również zwraca:

HTTP 429 Too Many Requests
Logowanie odrzuconych żądań

NGINX loguje wszystkie przypadki przekroczenia limitów.

limit_req_log_level notice;
limit_conn_log_level notice;

Przykładowy wpis:

limiting requests, excess: 15.000 by zone "payment_rate"

Pozwala to łatwo monitorować momenty przeciążenia aplikacji.

Przepływ żądania
HTTP Request
│
▼
NGINX
│
├── Rate Limit
├── Connection Limit
│
▼
Spring Boot
│
▼
Bulkhead
│
▼
Circuit Breaker
│
▼
HikariCP
│
▼
PostgreSQL
Dlaczego NGINX?

Mechanizmy Resilience4j chronią zasoby aplikacji, jednak działają dopiero po przekazaniu żądania do Spring Boot.

Jeżeli wszystkie wątki Tomcata są zajęte, nowe żądania nie dotrą do kodu aplikacji i zakończą się timeoutem.

NGINX działa przed Tomcatem i odrzuca nadmiarowy ruch jeszcze przed jego przetworzeniem.

Dzięki temu:

Tomcat nie wyczerpuje puli wątków,
aplikacja pozostaje responsywna,
zmniejsza się liczba timeoutów,
baza danych nie jest zalewana nadmierną liczbą zapytań.
Efekt podczas testów obciążeniowych
Bez NGINX
JMeter
│
▼
Tomcat
│
├── wyczerpanie puli wątków
├── timeouty
├── SocketException
└── NoHttpResponseException
Z NGINX
JMeter
│
▼
NGINX
│
├── 200 OK
├── 429 Too Many Requests
└── tylko część ruchu trafia do aplikacji
│
▼
Spring Boot

Zamiast przeciążać aplikację, nadmiarowy ruch jest odrzucany przez NGINX, dzięki czemu Spring Boot oraz baza danych obsługują wyłącznie liczbę żądań, którą są w stanie przetworzyć.

Współpraca z Resilience4j

NGINX i Resilience4j pełnią różne role i wzajemnie się uzupełniają:

Mechanizm	Odpowiedzialność
NGINX	Ochrona przed nadmiernym ruchem (Rate Limiting, Connection Limiting)
Tomcat	Obsługa żądań HTTP
Bulkhead	Ograniczenie liczby równoległych operacji wykorzystujących zasoby aplikacji (np. połączenia z bazą danych)
Circuit Breaker	Ochrona przed awarią bazy danych lub zewnętrznych usług
Fallback	Zwrócenie kontrolowanej odpowiedzi zamiast błędu lub timeoutu
Global Exception Handler	Mapowanie wyjątków na odpowiedzi HTTP
HikariCP	Zarządzanie pulą połączeń z bazą danych

Takie wielowarstwowe podejście odpowiada architekturze stosowanej w środowiskach produkcyjnych, gdzie ochrona przed przeciążeniem rozpoczyna się na poziomie infrastruktury (NGINX), a następnie jest uzupełniana przez mechanizmy odporności zaimplementowane w aplikacji.