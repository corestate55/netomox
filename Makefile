YANGDIR := ./yang
SRCDIR := ./model_checker
MODELDIR := ./model
DSLSRCDIR := ./model_dsl
DEFDIR := ./model_defs

YANGFILES := $(YANGDIR)/ietf-l2-topology@2018-06-29.yang $(YANGDIR)/ietf-l3-unicast-topology@2018-02-26.yang $(YANGDIR)/ietf-network-topology@2018-02-26.yang $(YANGDIR)/ietf-network@2018-02-26.yang
YANGFILES_R := $(YANGDIR)/ietf-network@2018-02-26.yang $(YANGDIR)/ietf-network@2018-02-26.yang $(YANGDIR)/ietf-l3-unicast-topology@2018-02-26.yang $(YANGDIR)/ietf-l2-topology@2018-06-29.yang
TARGETRB := $(wildcard $(DEFDIR)/target*.rb) $(wildcard $(DEFDIR)/target*/*.rb)
DSLRB := $(wildcard $(DSLSRCDIR)/*.rb)
TARGETJSON := $(MODELDIR)/target.json $(MODELDIR)/target2.json $(MODELDIR)/target3.json
TARGETXML := $(TARGETJSON:%.json=%.xml)
JTOX := $(MODELDIR)/topol23.jtox
JSONSCHEMA := $(MODELDIR)/topol23.jsonschema
CHECKER := model_checker.rb
RUBY := bundle exec ruby
CHECKERSRC := $(CHECKER) $(wildcard $(SRCDIR)/*.rb)

all: $(TARGETXML)

$(TARGETXML): $(DSLRB) $(TARGETRB) $(TARGETJSON) $(JTOX) $(JSONSCHEMA) $(CHECKERSRC)

%.json: $(DEFDIR)/%.rb
	echo "# generate json from ruby" $<
	$(RUBY) $< > $(MODELDIR)/$@

%.xml: %.json
	echo "# convert json 2 xml" $<
	jsonlint-cli -s $(JSONSCHEMA) $<
	$(RUBY) $(CHECKER) --check $<
	json2xml $(JTOX) $< | xmllint --output $@ --format -

$(JTOX): $(YANGFILES)
	pyang -f jtox -o $(JTOX) $(YANGFILES)

$(JSONSCHEMA): $(YANGFILES)
	pyang -f json_schema -o $(JSONSCHEMA) $(YANGFILES_R)

force:
	$(RUBY) $(DEFDIR)/target.rb > $(MODELDIR)/target.json
	$(RUBY) $(DEFDIR)/target2.rb > $(MODELDIR)/target2.json
	$(RUBY) $(DEFDIR)/target3.rb > $(MODELDIR)/target3.json

testgen:
	$(RUBY) $(DEFDIR)/test_network.rb
	$(RUBY) $(DEFDIR)/test_node.rb
	$(RUBY) $(DEFDIR)/test_link.rb
	$(RUBY) $(DEFDIR)/test_tp.rb
