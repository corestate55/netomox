# Netomox pseudo-model
Wrapper module for [Netomox DSL](https://github.com/corestate55/netomox/blob/develop/dsl.md).

Netomox DSL is designed to define data according to RFC8345 topology model.
The DSL has context about 'parent' object is.
It makes some complexity especially in  cases to fully automated model data building,
like that [bf-l2trial](../bf_l2trial/README.md) and [bf-l3trial](../bf_l3trial/README.md).

Issues:
* Too deep nested blocks.
* Redundant API call for DSL object operation.
* Methods/functions defined in external of DSL object scope are restricted.
  Because `#register` method of each DSL object is evaluated with DSL object scope.
  (using `#instance_eval` for evaluation DSL block.)

So, this 'pseudo-**model' resolve the issues.
It is wrapping Netomox-DSL and construct data model context-less.
Therefore, there is no validation and security checks but simple.
It can avoid complexity from using `#instance_eval`.

# Usage

## DataBuilderBase

Inherit `DataBuilderBase` at your own data builder.
It focuses to make single network-layer (with dummy parent (`networks`)).

Then it can use several variables and methods to build model data.

* Methods (public)
  * `#interpret` : Combining all pseudo-model data to construct Netomox-DSL instance.
    It calls Netomox-DSL corresponding each pseud-model object
    and returns `Netomox::DSL::networks` instance as translation of itself.
  * `#topo_data` : Generate RFC8345 data.
  * `#dump` : debug print.

## Pseudo Objects
* `PNetworks` (pseudo `Netomox::DSL::Networks`)
* `PNetwork` (pseudo `Netomox::DSL::Network`)
* `PNode` (pseudo `Netomox::DSL::Node`)
* `PTermPoint` (pseudo `Netomox::DSL::TermPoint`)
* `PLink` (pseudo `Netomox::DSL::Link`)
