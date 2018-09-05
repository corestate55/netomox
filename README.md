# nwmodel-checker

Data checker for network topology model ([RFC 8345 \- A YANG Data Model for Network Topologies](https://datatracker.ietf.org/doc/rfc8345/)).

See also [the topology data visualizer](https://github.com/corestate55/nwmodel-exercise).

## YANG Files

You can find latest yang files defined in [RFC8345](https://www.rfc-editor.org/info/rfc8345
) and [RFC8346](https://www.rfc-editor.org/info/rfc8346) at [Yang models repository on github](https://github.com/YangModels/yang/tree/master/standard/ietf/RFC). Draft [L2 network topology](https://datatracker.ietf.org/doc/draft-ietf-i2rs-yang-l2-network-topology/) yang file is also at [experimental folder in the repository](https://github.com/YangModels/yang/tree/master/experimental/ietf-extracted-YANG-modules)

## Installation

### Setup environment

* Install tools for development tools (in Ubuntu, `apt install build-essentials`)
* Install `ruby`(>2.3), `ruby-dev`, `ruby-bundler`
* Install packages used in this application
  * `bundle install --path=vendor/bundle`

### Setup tools

* Install [pyang](https://github.com/mbj4668/pyang) (>1.7.4)
  * `sudo pip install pyang` installs `pyang`, `yang2dsdl` and `json2xml`.
* Install [json_schema pyang plugin](https://github.com/OpenNetworkingFoundation/EAGLE-Open-Model-Profile-and-Tools/tree/ToolChain/YangJsonTools)
  * `sudo cp json_schema.py PYANG_PLUGIN_DIR`
* install [jsonlint-cli](https://github.com/marionebl/jsonlint-cli) to validate json data.
  * `sudo npm install -g jsonlint-cli`
* or other JSON/XML utilities as you like.

## Check topology data
```
bundle exec ruby checker.rb check model/target.json
```
or exec
```
bundle exec rake
```
to check (and convert to xml) all json data in `model` directory.

### Handling Network Topology Data Instance

#### Write/Construct topology data

Use topology model DSL (Domain Specific Language) to make target data.
e.g.
```
$ bundle exec ruby model_defs/target.rb
```
It generate model data (json) and print to standard-output.

#### Check data consistency
```
$ bundle exec ruby checker.rb check target.json
```

#### Validate JSON

Install pyang JSON Schema plugin from [EAGLE\-Open\-Model\-Profile\-and\-Tools/YangJsonTools at ToolChain](https://github.com/OpenNetworkingFoundation/EAGLE-Open-Model-Profile-and-Tools/tree/ToolChain/YangJsonTools) instead of [cmoberg/pyang\-json\-schema\-plugin](https://github.com/cmoberg/pyang-json-schema-plugin). (because cmoberg's plugin [can work only on single yang module at a time](https://github.com/cmoberg/pyang-json-schema-plugin/issues/4))

Generate json schema
```
pyang -f json_schema -o topo.jsonschema ietf-network@2018-02-26.yang ietf-network-topology@2018-02-26.yang
```
and validate (using [jsonlint](https://www.npmjs.com/package/jsonlint-cli) or other json tool).
```
jsonlint-cli -s topo.jsonschema target.json
```

#### JSON to XML

Create jtox file at first.
Notice: only use base topology model (NOT augmented model such as L2/L3).
```
pyang -f jtox -o topo.jtox ietf-network-topology@2018-02-26.yang ietf-network@2018-02-26.yang
```

Convert json to xml
```
json2xml topo.jtox target.json | xmllint --format - > target.xml
```

#### Validate XML

Notice, topology YANG models are YANG/1.1, so you have to set `-x` option to `yang2dsdl`.
```
$ yang2dsdl -x -j -t config -v model/target.xml yang/ietf-network-topology@2018-02-26.yang yang/ietf-network@2018-02-26.yang
```

## Show diff between topology data

You can see diff of 2 topology data like that:
```
$ bundle exec ruby checker.rb diff [--all|--color] model/target.orig.json model/target.json
```
In default, checker diff output only changed object and its parent object.

* `-a`/`--all` option: checker diff output whole data include unchanged object.
* `-c`/`--color` option: use color for diff.
* `-o FILE`/`--output FILE` option: save diff data to FILE (json data includes diff info for diff viewer).
If specified `-o` and other options, ignored them.

## Store topology data with Neo4j

Ready `db_info.json` file to store information to connect your Neo4j database.

This application is using [neography](https://github.com/maxdemarzi/neography) to post the data into neo4j graph database.
Execute like below
```
bundle exec ruby checker.rb graphdb target.json
```
