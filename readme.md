# Weather Aggregator

Perl scripts to aggregate forecast data from various weather APIs.

Requires API Keys to access AccuWeather and WeatherAPI.
These are stored in `config.ini`.

To run the Redis and Web servers, run `docker-compose up`.
The application is available at http://localhost:8080/cgi-bin/weather/forecast?location=Fishers+Island,+NY.
Change the query parameter to any City, State pair.

The Web server is running in development mode.
Any changes made to the code locally will immediately be reflected on the server.
Just refresh the web page.

CPAN dependencies are listed in the `Dockerfile` as Debian packages.
Add new entries here as needed.
