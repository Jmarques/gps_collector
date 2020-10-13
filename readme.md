

# GPS Collector
This is Jeremy Marques App for the Bus Patrol challenge.

## Philosophy

The instruction were about using a simple Rack app instead of bringing Rails with all its dependencies.
This is what I focused on, having fun with the idea of not being bound by the Rails conventions.

It translate into 2 noticeable choices:
- low dependencies. There are only 3: json, pg and sequel.
- layers: the traditional Rails model was split into a Persist and a Repository class.

## Installation
### Configuration
An .env is provided with the default database configuration in docer-compose. If you are not using the default configuration please edit the .env.

### Creating table
Before starting the app we will need to create the table.
```bash
rake db:create
```
It is important to notice that there are no production, development, test environments set in the app.
If you wich to start from the beginning you can also use `db:drop` to remove the table.

### Startup
```base
rackup
```

## Code validation
In order to check the linter, tests and generate the documentation, use the following task:
```bash
rake validate
```
### Documentation
The documentation was generated using Yard.
To generate it you can use the rake task:
```bash
rake doc:create
```
### Linter
The linter is Rubocop and is configured to use all Cops. The only exception is the `Metrics/BlockLength` for method `describe` and `context` as it is breaking the `Rspec` DSL.
The linter can also be called using a rake task:
```bash
rake linter:run
```
### Testing
This app is using Rspec. Since we are using the same database for development and test, I choose to Mock the persistance layer of the app when testing.
Rack shortcut:
```
rake specs:all
```
### Postman Collection
A collection of `POST /` and `GET /` Postman requests is included in the repo: `GpsCollector.postman_collection.json`

## Usage
### POST /
To create the points in your app you have two possible formatings for the parameters.
#### Parameter: Array with Points
```json
[
  {
    "type": "Point",
    "coordinates": [1.0, 1.0]
  },
  {
    "type": "Point",
    "coordinates": [2.0, 2.0]
  }
]
```
#### Parameter: Array with Collection
```json
[
  {
    "type": "GeometryCollection",
    "geometries": [
        {
          "type": "Point",
          "coordinates": [1.0, 1.0]
        },
        {
          "type": "Point",
          "coordinates": [2.0, 2.0]
        },
      ]
   }
]
```
#### Parameter: Array of Mixed Type
```json
[
  {
    "type": "Point",
    "coordinates": [1.0, 1.0]
  },
  {
    "type": "GeometryCollection",
    "geometries": [
        {
           "type": "Point",
           "coordinates": [1.0, 1.0]
        },
        {
           "type": "Point",
           "coordinates": [2.0, 2.0]
        }
      ]
   }
]
```
#### Return
The return will always be a JSON.
If there is no error in the formating of the request you should get a 201 request with a success message.
```json
{
  "success": "3 point(s) created"
}
```
If the request can't be processed you will receive an error key with a short explanation.
```json
{
  "error": "Unsuported coordinates"
}
```
### GET /
Since there is no defined semantic for `GET` parameters, we are using `POST` request_method to retreive data.
In order to simulate a `GET` request but continue using the `POST` parameters, please add the header `X-HTTP-Method-Override` with the value `GET` . This allow us to have the same semantic for both POST and GET requests.

#### Parameter: Point and Radius
```json
{
  "geometry":
  {
    "type": "Point",
    "coordinates": [2.0, 2.0]
  },
  "radius": {
    "length": 2000,
    "unit": "meter"
  }
}
```
All keys are required beside `unit` that will default to meter if not provided.
Its possible values are `meter` and `foot`.
#### Parameter: Polygon
```json
{
  "geometry":
  {
    "type": "Polygon",
    "coordinates": [
      [2.0, 2.0],
      [2.0, -2.0],
      [-2.0, -2.0],
      [-2.0, 2.0],
      [2.0, 2.0]
    ]
  }
}
```
The Polygon must be closed, meaning the first and last coordinates must be the same.
#### Return
```json
[
  {
    "type": "Point",
    "coordinates": [1.0, 1.0]
  },
  {
    "type": "Point",
    "coordinates": [2.0, 2.0]
  }
]
```
