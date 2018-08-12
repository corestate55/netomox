# nwmodel-checker

Data checker for network topology model ([RFC 8345 \- A YANG Data Model for Network Topologies](https://datatracker.ietf.org/doc/rfc8345/)).

See also [the topology data visualizer](https://github.com/corestate55/nwmodel-exercise).

## YANG Files

You can find latest yang files defined in [RFC8345](https://www.rfc-editor.org/info/rfc8345
) and [RFC8346](https://www.rfc-editor.org/info/rfc8346) at [Yang models repository on github](https://github.com/YangModels/yang/tree/master/standard/ietf/RFC). Draft [L2 network topology](https://datatracker.ietf.org/doc/draft-ietf-i2rs-yang-l2-network-topology/) yang file is also at [experimental folder in the repository](https://github.com/YangModels/yang/tree/master/experimental/ietf-extracted-YANG-modules)

## Installation

### Setup tools

* Install [pyang](https://github.com/mbj4668/pyang)
  * `sudo pip install pyang` installs `pyang`, `yang2dsdl` and `json2xml`.
* install [jsonlint-cli](https://github.com/marionebl/jsonlint-cli) to validate json data.
  * `sudo npm install -g jsonlint-cli`
* or other JSON/XML utilities as you like.

### Check topology data
```
bundle exec ruby model_checker.rb --check --file model/target.json
```
or exec
```
make
```
to check (and convert to xml) all json data in `model` directory.

### Store topology data with Neo4j

Install [neography](https://github.com/maxdemarzi/neography) to post the data into neo4j graph database.
```
bundle install --path=vendor/bundle
```

Exec
```
bundle exec ruby model_checker.rb --neo4j --file target.json
```

## Handling Network Topology Data Instance

### Write data by JSON and run check script

Generate bi-directional link data from unidirectional link-id string.
```
./link.sh VM1,eth0,HYP1-vSW1-BR-VL10,p3
```

Check data consistency
```
ruby nwmodel-checker.rb target.json
```

### Validate JSON

Install pyang JSON Schema plugin from [EAGLE\-Open\-Model\-Profile\-and\-Tools/YangJsonTools at ToolChain](https://github.com/OpenNetworkingFoundation/EAGLE-Open-Model-Profile-and-Tools/tree/ToolChain/YangJsonTools) instead of [cmoberg/pyang\-json\-schema\-plugin](https://github.com/cmoberg/pyang-json-schema-plugin). (because cmoberg's plugin [can work only on single yang module at a time](https://github.com/cmoberg/pyang-json-schema-plugin/issues/4))

Generate json schema
```
pyang -f json_schema -o topo.jsonschema ietf-network@2018-02-26.yang ietf-network-topology@2018-02-26.yang
```
and validate (using [jsonlint](https://www.npmjs.com/package/jsonlint-cli) or other json tool).
```
jsonlint-cli -s topo.jsonschema target.json
```

### JSON to XML

Create jtox file at first.
Notice: only use base topology model (NOT augmented model such as L2/L3).
```
pyang -f jtox -o topo.jtox ietf-network-topology@2018-02-26.yang ietf-network@2018-02-26.yang
```

Convert json to xml
```
json2xml topo.jtox target.json | xmllint --format - > target.xml
```

### Validate XML

OOPS...they are YANG/1.1
```
$ yang2dsdl -t config ietf-network-topology@2018-02-26.yang ietf-network@2018-02-26.yang
DSDL plugin supports only YANG version 1.
```
