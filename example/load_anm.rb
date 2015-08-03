require 'pp'
require 'edge'

tree = Edge::AnmParser.new.parse(File.read('char.anm'))
pp tree
