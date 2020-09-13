Introduction
============

Dainty is a simple object mapper for Delphi.

Heavily inspired by `Dapper <https://github.com/StackExchange/Dapper>`_, Dainty aims to provide a lightweight layer to map objects from a TDataSet descendant or to TParams. It is intentionally not a fully fledged ORM framework.

Dainty has been written and tested primarily in Delphi XE2 and 10.2.


Key features
------------

* Read rows from a DataSet into objects
* Fill TParams using an object
* Helper methods for single row results
* Object mapping cache to reduce runtime RTTI overhead