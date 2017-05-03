Ruby Memcached Server
==============

This is a Memcached server developed using the Ruby language.

## What is Memcached?
Memcached is an in-memory key-value store for small chunks of arbitrary data (strings, objects) from results of database calls, API calls, or page rendering.

## Starting the server
To start the server go to memcached folder:
```
cd memcached
```
Then execute the command:
```
ruby bin/memcached_server -p 2000
```
The default port is 2000 in case the parameter is not provided.

## Starting the sample client
To start the sample client go to memcached folder:
```
cd memcached
```
Then execute the command:
```
ruby bin/memcached_client.sample -p 2000
```
The default port is 2000 in case the parameter is not provided.

## Basic commands
### Storage commands

#### Set
##### Syntax
```
set key flags exptime
value
```
Sets a record.
```
set sample_key 1 100
sample_value
STORED
```

#### Add
##### Syntax
```
add key flags exptime
value
```
Adds a record. If the record already exist on the memcached, the new record doesn't get stored.
```
add new_key 1 100
new_value
STORED
add new_key 1 200
other_value
NOT_STORED
```

#### Replace
##### Syntax
```
replace key flags exptime
value
```
Replaces a record. If the record doesn't exist on the memcached, the replacing record doesn't get stored.
```
replace new_key 1 100
new_value
NOT_STORED
add new_key 1 100
new_value
STORED
replace new_key 1 200
other_value
STORED
```

#### Append
##### Syntax
```
append key flags exptime
value
```
Appends a value to the value of an existing record. If the record doesn't exist on the memcached, the operation doesn't get stored.
```
append key 1 100
other
NOT_STORED
add key 1 100
value
STORED
append key 1 200
other
STORED
```

#### Prepend
##### Syntax
```
prepend key flags exptime
value
```
Prepends a value to the value of an existing record. If the record doesn't exist on the memcached, the operation doesn't get stored.
```
prepend key 1 100
other
NOT_STORED
add key 1 100
value
STORED
prepend key 1 200
other
STORED
```

#### Cas (Check and Set)
##### Syntax
```
cas key flags exptime unique_cas_token
value
```
Sets a record but only if it wasn't modified since the requesting client last fetched it. If the unique cas token is missing the server respond an error mesage. If the key doesn't exist on the memcached the server respond with not found.
```
cas key 1 100
value
ERROR
cas key 1 100 12345
value
NOT_FOUND
add key 1 100
value
STORED
gets key
VALUE key 1 12345
memcached
END
cas key 0 200 12345
othervalue
STORED
```

### Retrieval commands

#### Get
##### Syntax
```
get key*
```
Gets the record stored associated to a key. If the key doesn't exist on the memcached the server respond with not found. It also can get multiple keys separated by spaces.
```
get key
NOT_FOUND
add key 1 100
value
STORED
get key
VALUE key 1
value
END
add other_key 2 100
other_value
STORE
get key other_key
VALUE key 1
value
VALUE other_key 2
other_value
END
```

#### Gets
##### Syntax
```
gets key*
```
Gets the record stored associated to a key, including it's unique cas token. If the key doesn't exist on the memcached the server respond with not found. It also can get multiple keys separated by spaces.
```
gets key
NOT_FOUND
add key 1 100
value
STORED
get key
VALUE key 1 12345
value
END
add other_key 2 100
other_value
STORE
gets key other_key
VALUE key 1 12345
value
VALUE other_key 2 54321
other_value
END
```

#  Further resources

* https://memcached.org/
* https://github.com/memcached/memcached/blob/master/doc/protocol.txt

Based on the Official Memcached object caching system.
