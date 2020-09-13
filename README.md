
# Dainty
*Simple object mapper for Delphi*

Heavily inspired by [Dapper](https://github.com/StackExchange/Dapper), Dainty aims to provide a lightweight layer to map objects from a TDataSet descendant or to TParams. It is intentionally not a fully fledged ORM framework.

Documentation is available on [ReadTheDocs](https://dainty.readthedocs.io/).

## Quick examples
Iterating through a dataset:
```pascal
for customer in query.Rows<TCustomerRow> do
  SendEmail(customer.FullName, customer.Email);
```
Getting a list of objects:
```pascal
customers := query.List<TCustomerRow>;
try
  { ... }
finally
  FreeAndNil(customers);
end;
```
Getting a single row from a dataset:
```pascal
customer := query.GetFirst<TCustomerRow>;
try
  { Alternatively: GetFirstOrDefault, GetSingle, GetSingleOrDefault }
finally
  FreeAndNil(customer);
end;
```
Assigning parameter values:
```pascal
type
  TCustomerParams = class
  public
    FullName: string;
    Active: Boolean;
  end;

...

query.SQL.Text := 'select CustomerID, FullName, Active from Customer ' +
                  'where FullName = :FullName and Active = :Active';

customerParams := TCustomerParams.Create;
try
  customerParams.FullName := 'John Doe';
  customerParams.Active := True;

  query.Params.Apply(customerParams);
  query.Open;

  { ... }
finally
  FreeAndNil(customerParams);
end;
```