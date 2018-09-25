# Netomox DSL

Netomox DSL construct data that is based on [RFC 8345](https://datatracker.ietf.org/doc/rfc8345/) based network topology data model.

## Basic structure

```
networks
  + network
    + node
    |   + term_point
    + link
```
* Networks has several networks
* Network has several nodes and links
* Node has several term_points
* Link has source and destination
* Each object has "supports" that is a reference list to other corresponding object in (another) network
* Each object has "attribute" that is additional information of the objects 
  * L2/L3 attribute is defined other RFC/I-D based on RFC8345

## Common operation

### Basics
Each object has `#register` method that receive a block and eval it in instance (`#instance_eval`)
```ruby
nws = Netomox::DSL::Networks.new
nws.register do
  network 'network1' # Networks#network
end
```

Constructor can receive a block (the block is evaluated by `#receive`)
```ruby
Netomox::DSL::Networks.new do
  network 'network1'
end
```

### Registration

Each object has registration method.
```ruby
Netomox::DSL::Networks.new do
  network 'network1' do
    node 'node1' do
      term_point 'tp1' do
      end
    end

    link %w[node1 tp1 node2 tp2] do
    end
  end
end
```
* `Networks#network`
* `Network#node`
* `Network#link` : register uni-directional link
* `Network#bdlink` : register bi-directional link
* `Node#term_point`

These registration methods search object in current data.
If found same (same-name) object, then modify it `#register`.
If not found same object, create new object and register it.

**[NOTICE]** : 
registration methods always return a object. 
found or created one.
If you need only-find a object, use `#find_foo` methods in each class.

### Supports
`#support` method register supporting-object. Args of support is reference correspond each object.
```ruby
Netomox::DSL::Networks.new do
  network 'network1' do
    support 'networkX'
    support 'networkY'

    node1 = node `node1` do
      support %w[networkX nodeP]
      term_point 'tp1' do
        support %w[networkX nodeP tpN]
      end
    end
  end 
end
```
It create ONLY data. does not check object existence and data consistency.

### Attributes

### Link

**[NOTICE]** Topology data handled by this tool has implicit rule about link name. It assumes that a link has a name like "src-node,src-tp,dst-node,dst-tp". If you define link in topology data using netomox DSL (`Netomox::DSL::Network#bdlink`, bi-directional link), a link name will be settled automatically.

(1) `Network#[bd]link` methods.
```ruby
Netomox::DSL::Networks.new do
  network 'network1' do
    bdlink %w[node1 tp1 node2 tp2]
  end 
end
```
it create ONLY data. does not check object existence and data consistency.

(2) `Node#[bd]link_to` and `TermPoint#[bd]link_to`
```ruby
Netomox::DSL::Networks.new do
  network 'network1' do
    node1 = node `node1` do
      term_point 'tp1'
    end
    node2 = node 'node2' do
      term_point `tp2`
    end
    node1.term_point('tp1').bdlink_to(node2.term_point(tp2))
  end 
end
```

If not specified termination point, these methods are create new termination point automatically.
```ruby
Netomox::DSL::Networks.new do
  network 'network1' do
    node1 = node `node1`
    node2 = node 'node2'
    node1.bdlink_to(node2) # => bdlink "node1,p0,node2,p0"
  end 
end
```
default termination point prefix is `p`, it can change like below:
```ruby
    node1 = node `node1`
    node1.tp_prefix = `eth`
```

## Convert

`#topo_data` methods generate ruby hash/array data (it called recursively for registered data). 
It can convert any data format. For example, use json:
```ruby
require 'json'
require 'netomox'

nws = Netomox::DSL::Networks.new do
  # ...
end
puts JSON.pretty_generate(nws.topo_data)
```
