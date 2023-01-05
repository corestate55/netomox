# Netomox pseudo-DSL

Wrapper module for `Netomox::DSL`

Netomox DSL is designed to define data according to RFC8345 topology model.
The DSL has context about 'parent' object is.
It makes some complexity especially in cases to fully automated model data building.

Issues:
* Enforcing top-down data definition (need "parent" object at first)
* Too deep nested blocks.
* Redundant API call for DSL object operation.
* Methods/functions are defined in external of DSL object scope are restricted.
  Because `#register` method of each DSL object is evaluated with DSL object scope.
  (using `#instance_eval` for evaluation DSL block.)

So, this pseudo-DSL resolve the issues.
It wraps Netomox-DSL and construct data model context-less.
Therefore, there is no validation and security checks but simple.
It can avoid complexity from using `#instance_eval`.

# Usage

## Pseudo Objects
* `PNetworks` (pseudo `Netomox::DSL::Networks`)
* `PNetwork` (pseudo `Netomox::DSL::Network`)
* `PNode` (pseudo `Netomox::DSL::Node`)
* `PTermPoint` (pseudo `Netomox::DSL::TermPoint`)
* `PLink` (pseudo `Netomox::DSL::Link`)
* `PLinkEdge` (pseudo `Netomox::DSL::TermPointRef`)

## Attribute

Each object has read/write attributes:
* `name`: object name
* `attribute`: RFC8345-based object attribute data (simple hash)
  * Hash keys follows definition of each DSL attribute class.
* `supports`: RFC83345-based support data (simple array)

## Method

* `PNetworks#interpret`: Translate to `Netomox::DSL` object recursively.

```text
PseudoDSL::       DSL::              Topology
Networks -------> Networks --------> Data (Hash)
        #interpret         #topo_data
```
