# Netomox

Netomox (**Ne**twork **To**pology **Mo**deling Toolbo**x**) is a tool to make/validate network topology data that based on RFC8345.

See also:
* [RFC 8345 - A YANG Data Model for Network Topologies](https://datatracker.ietf.org/doc/rfc8345/)
* [Netomox Examples](https://github.com/corestate55/netomox-examples)
  * Repository of example topology data instance (defined by netomox DSL)
* [Network topology visualizer](https://github.com/corestate55/netoviz)

## Installation

* Install tools for development tools (in Ubuntu, `apt install build-essentials`)
* Install `ruby`(>2.3), `ruby-dev`, `ruby-bundler`
* Install packages used in this application
  * `git clone` and `bundle install --path=vendor/bundle`

<!--

Add this line to your application's Gemfile:

```ruby
gem 'netomox'
```

And then execute:

```text
$ bundle
```

Or install it yourself as:

```text
$ gem install netomox
```

-->

## How to handle topology data instance

In `vendor` dir, there are some data instances defined/handled with Netomox.

* `vendor/model`: topology data instance (json) of fictional network.
* `vendor/model_defs`: topology data definition using `Netomox::DSL` to generate json data instance. 
  * See. [DSL Document](dsl.md)

### YANG Files

You can find latest yang files defined in [RFC8345](https://www.rfc-editor.org/info/rfc8345
) and [RFC8346](https://www.rfc-editor.org/info/rfc8346) at [Yang models repository on github](https://github.com/YangModels/yang/tree/master/standard/ietf/RFC). Draft [L2 network topology](https://datatracker.ietf.org/doc/draft-ietf-i2rs-yang-l2-network-topology/) yang file is also at [experimental folder in the repository](https://github.com/YangModels/yang/tree/master/experimental/ietf-extracted-YANG-modules)

### Setup tools

* Install [pyang](https://github.com/mbj4668/pyang) (>1.7.4)
  * `sudo pip install pyang` installs `pyang`, `yang2dsdl` and `json2xml`.
* Install [json_schema pyang plugin](https://github.com/OpenNetworkingFoundation/EAGLE-Open-Model-Profile-and-Tools/tree/ToolChain/YangJsonTools)
  * `sudo cp json_schema.py PYANG_PLUGIN_DIR`
* install [jsonlint-cli](https://github.com/marionebl/jsonlint-cli) to validate json data.
  * `sudo npm install -g jsonlint-cli`
* or other JSON/XML utilities as you like.


### Write/Construct topology data

Use topology model DSL (Domain Specific Language) to make target data.
e.g.
```shell
bundle exec ruby model_defs/target.rb
```
It generate topology data and print it to standard-output as JSON.

### Check data consistency
```shell
bundle exec netomox check target.json
```

### Validate JSON

Install pyang JSON Schema plugin from [EAGLE\-Open\-Model\-Profile\-and\-Tools/YangJsonTools at ToolChain](https://github.com/OpenNetworkingFoundation/EAGLE-Open-Model-Profile-and-Tools/tree/ToolChain/YangJsonTools) instead of [cmoberg/pyang\-json\-schema\-plugin](https://github.com/cmoberg/pyang-json-schema-plugin). (because cmoberg's plugin [can work only on single yang module at a time](https://github.com/cmoberg/pyang-json-schema-plugin/issues/4))

Generate json schema
```shell
pyang -f json_schema -o topo.jsonschema ietf-network@2018-02-26.yang ietf-network-topology@2018-02-26.yang
```
and validate (using [jsonlint](https://www.npmjs.com/package/jsonlint-cli) or other json tool).
```shell
jsonlint-cli -s topo.jsonschema target.json
```

### Convert JSON to XML

Create jtox file at first.

**[Notice]** use base topology model (NOT augmented model such as L2/L3).
```shell
pyang -f jtox -o topo.jtox ietf-network-topology@2018-02-26.yang ietf-network@2018-02-26.yang
```

Convert json to xml
```shell
json2xml topo.jtox target.json | xmllint --format - > target.xml
```

### Validate XML

Notice, topology YANG models are YANG/1.1, so you have to set `-x` option to `yang2dsdl`.
```shell
yang2dsdl -x -j -t config -v model/target.xml yang/ietf-network-topology@2018-02-26.yang yang/ietf-network@2018-02-26.yang
```

### Show diff between topology data

You can see diff of 2 topology data like that:
```shell
bundle exec netomox diff model/target.orig.json model/target.json
```
In default, checker diff output only changed object and its parent object.

* `-a`/`--all` : checker diff output whole data include unchanged object.
* `-c`/`--color` : use color for diff.
* `-o FILE`/`--output FILE` : save diff data to FILE (json data includes diff info for diff viewer).
If specified `-o` and other options, ignored them.

### Store topology data with Graph DB (Neo4j)

Ready `db_info.json` file to store information to connect your Neo4j database.

This application is using [neography](https://github.com/maxdemarzi/neography) to post the data into neo4j graph database.
Execute like below
```shell
bundle exec netomox graphdb target.json
```
* `-i FILE`/`--info FILE` option: graph db connection info file (if not specified, use `db_info.json`)
* `-c`/`--clear` option: only deleting all data in graph (clear database and do not import graph data)

### Visualize Neo4j graph data using Popoto.js

(Experimental)

[Popoto.js](http://www.popotojs.com/) is a graphical Neo4j query builder.
If you use Neo4j with `netomox graphdb` command, you can also use popoto.js to query/visualize its data.

Install popoto and required packages at first.
```bash
cd popoto/
npm install
```
Next, Edit neo4j API entry point and its account in `src/index.js`. (See [Popoto.js Wiki](https://github.com/Nhogs/popoto/wiki/Getting-started) in detail.)

* `popoto.rest.CYPHER_URL`
* `popoto.rest.AUTHORIZATION`

Run webpack dev-server and access `localhost:8081` (See `webpack.config.js` to config dev-server).
```bash
npm run start
```

## Development

### API Documents

Generate document using YARD.
```shell
bundle exec rake yard
```
Then, documents are generated at `doc/` directory. 
Read documents from `doc/index.html` directly or yard http server. (default localhost:8808)
```shell
bundle exec yard server
```


### Netomox UML Class diagrams

[rb2puml](./bin/rb2puml) generates UML class diagram for PlantUML.
* `-s`/`--simple` : Simple format (not include class method information)
* `-d`/`--dir` : Directory path to analyze source code (*.rb)

```shell
bundle exec rb2puml -d lib/netomox/dsl > netomox_dsl.puml
```

Or, install PlantUML and exec `rake fig`.
```shell
bundle exec rake fig
```
Then, class diagrams will be created in `figs/` directory.
