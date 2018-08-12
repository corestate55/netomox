YANGDIR := ./yang
SRCDIR := ./model_checker
MODELDIR := ./model

YANGFILES := $(YANGDIR)/ietf-l2-topology@2018-06-29.yang $(YANGDIR)/ietf-l3-unicast-topology@2018-02-26.yang $(YANGDIR)/ietf-network-topology@2018-02-26.yang $(YANGDIR)/ietf-network@2018-02-26.yang
YANGFILES_R := $(YANGDIR)/ietf-network@2018-02-26.yang $(YANGDIR)/ietf-network@2018-02-26.yang $(YANGDIR)/ietf-l3-unicast-topology@2018-02-26.yang $(YANGDIR)/ietf-l2-topology@2018-06-29.yang
TARGETJSON := $(MODELDIR)/target.json $(MODELDIR)/target2.json $(MODELDIR)/target3.json
TARGETXML := $(TARGETJSON:%.json=%.xml)
JTOX := $(MODELDIR)/topol23.jtox
JSONSCHEMA := $(MODELDIR)/topol23.jsonschema
CHECKER := model_checker.rb
CHECKERSRC := $(CHECKER) $(wildcard $(SRCDIR)/*.rb)

all: $(TARGETXML)

$(TARGETXML): $(TARGETJSON) $(JTOX) $(JSONSCHEMA) $(CHECKERSRC)

%.xml: %.json
	echo "# convert json 2 xml" $<
	jsonlint-cli -s $(JSONSCHEMA) $<
	bundle exec ruby $(CHECKER) --check --file $<
	json2xml $(JTOX) $< | xmllint --output $@ --format -

$(JTOX): $(YANGFILES)
	pyang -f jtox -o $(JTOX) $(YANGFILES)

$(JSONSCHEMA): $(YANGFILES)
	pyang -f json_schema -o $(JSONSCHEMA) $(YANGFILES_R)
