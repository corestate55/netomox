YANG_DIR := ./yang
CHECKER_DIR := ./model_checker
DSL_DIR := ./model_dsl
DEF_DIR := ./model_defs
MODEL_DIR := ./model

YANG := $(YANG_DIR)/ietf-l2-topology@2018-06-29.yang $(YANG_DIR)/ietf-l3-unicast-topology@2018-02-26.yang $(YANG_DIR)/ietf-network-topology@2018-02-26.yang $(YANG_DIR)/ietf-network@2018-02-26.yang
YANG_R := $(YANG_DIR)/ietf-network@2018-02-26.yang $(YANG_DIR)/ietf-network@2018-02-26.yang $(YANG_DIR)/ietf-l3-unicast-topology@2018-02-26.yang $(YANG_DIR)/ietf-l2-topology@2018-06-29.yang
DSL_RB := $(wildcard $(DSL_DIR)/*.rb)
TARGET_RB := $(wildcard $(DEF_DIR)/target*.rb) $(wildcard $(DEF_DIR)/target*/*.rb)
TARGET_JSON := $(MODEL_DIR)/target.json $(MODEL_DIR)/target2.json $(MODEL_DIR)/target3.json
TARGET_XML := $(TARGET_JSON:%.json=%.xml)
JTOX := $(MODEL_DIR)/topol23.jtox
JSON_SCHEMA := $(MODEL_DIR)/topol23.jsonschema
CHECKER := checker.rb
CHECKER_RB := $(CHECKER) $(wildcard $(CHECKER_DIR)/*.rb)
RUBY := bundle exec ruby
YANG2DSDL := yang2dsdl -x -j -t config -d $(MODEL_DIR)

all: json testgen $(TARGET_XML)

$(TARGET_XML): $(DSL_RB) $(TARGET_RB) $(TARGET_JSON) $(JTOX) $(JSON_SCHEMA) $(CHECKER_RB)

%.xml: %.json
	echo "# convert json 2 xml" $<
	jsonlint-cli -s $(JSON_SCHEMA) $<
	$(RUBY) $(CHECKER) check $<
	json2xml $(JTOX) $< | xmllint --output $@ --format -
#	$(YANG2DSDL) -v $@ $(YANG)

$(JTOX): $(YANG)
	pyang -f jtox -o $(JTOX) $(YANG)

$(JSON_SCHEMA): $(YANG)
	pyang -f json_schema -o $(JSON_SCHEMA) $(YANG_R)

json:
	$(RUBY) $(DEF_DIR)/target.rb > $(MODEL_DIR)/target.json
	$(RUBY) $(DEF_DIR)/target2.rb > $(MODEL_DIR)/target2.json
	$(RUBY) $(DEF_DIR)/target3.rb > $(MODEL_DIR)/target3.json

testgen:
	for file in $(DEF_DIR)/test_*.rb; do ${RUBY} $$file; done

FIG_DIR := ./fig
figs:
	$(RUBY) rb2puml.rb -d $(CHECKER_DIR) > $(FIG_DIR)/model_checker.puml
	$(RUBY) rb2puml.rb -d $(DSL_DIR) > $(FIG_DIR)/model_dsl.puml
	for file in $(FIG_DIR)/*.puml; do plantuml $$file; done

DSDL := $(MODEL_DIR)/*.dsrl $(MODEL_DIR)/*.rng $(MODEL_DIR)/*.sch
clean:
	rm -f *~ $(TARGET_JSON) $(MODEL_DIR)/test_*.json $(DSDL)
