# GPS Collector
​
**Time frame:** 1 week
​
The task is to stand up a simple Ruby/Rack application backed by a
Postgres/PostGIS database. Your code should be tested, linted, and documented.
The GitHub repository should also include a functional README.md with full
instructions on how to lint, test, and start the app and render the software
documentation. You should use a Docker container for your Postgres/PostGIS db,
to save yourself some time on setup. Feel free to ask any questions you need.
​
### Requirements
​
##### Endpoints
​
1) `POST` - Accepts GeoJSON point(s) to be inserted into a database table
   params: Array of GeoJSON Point objects or Geometry collection
​
2) `GET` - Responds w/GeoJSON point(s) within a radius around a point
   params: GeoJSON Point and integer radius in feet/meters
​
3) `GET` - Responds w/GeoJSON point(s) within a geographical polygon
   params: GeoJSON Polygon with no holes
​
##### Dependencies
​
These are the bare minimum tools required to complete this project. You will
need and can install as many other tools as you want (except `Rails`).
​
- [docker](https://docs.docker.com/install/)
- [docker-compose](https://docs.docker.com/compose/install/)
- [psql](https://www.postgresql.org/download/)
- [ruby](https://www.ruby-lang.org/en/downloads/)
- [rack](https://github.com/rack/rack)
​
### Helpful Links
​
- [GeoJSON examples](https://tools.ietf.org/html/rfc7946#appendix-A)
- [Docker install](https://docs.docker.com/install/)
- [PostGIS/Postgres Docker container](https://hub.docker.com/r/mdillon/postgis)
- [Linter](https://docs.rubocop.org/en/stable/)
- [RDoc](https://ruby.github.io/rdoc/) [YARD](https://yardoc.org)
​
### Setup
​
To stand up the database image:
​
```bash
docker-compose up -d db
```
​
To verify the container is up run `docker ps`:
```bash
➜ docker ps
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                    NAMES
d22806639140        mdillon/postgis:9.4   "docker-entrypoint.s…"   3 seconds ago       Up 2 seconds        0.0.0.0:5432->5432/tcp   gps_collector_db
```
​
You should now be able to log into it and make queries against it on
`localhost:5432`. See `docker-compose.yml` for db name, user, and password
information.
```bash
➜ psql -h localhost  -p 5432 -U gps_collector -d gps_collector
psql (12.2, server 9.4.21)
Type "help" for help.
​
gps_collector=#
```