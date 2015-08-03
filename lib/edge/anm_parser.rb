require 'offside_rule'

module Edge

  class AnmTransformer < Parslet::Transform
    rule(:identifier => simple(:identifier), :value => simple(:value)) do
      id = identifier.to_s.downcase.to_sym
      val = case id
      when :filename
        File.basename(value.to_s)
      when :win_title, :pattern_name
        value.to_s
      else
        value.to_i
      end
      { id => val }
    end
    rule(:content => {:anime_version => simple(:anime_version)}, :children => []) do
      { anime_version: anime_version.to_s }
    end
    rule(:content => {:comment => simple(:comment)}, :children => []) do
      { comment: comment.to_s }
    end
    rule(
      :content => { :pattern_name => simple(:pattern_name) },
      :children => subtree(:subtree)
    ) do
      {
        pattern_name.to_s.to_sym => [
          *subtree.map {|frame|
            Hash[*frame[:children].map {|param|
              param[:content].to_a
            }.flatten]
          }
        ]
      }
    end
  end

  class AnmParser

    def initialize
      @parser = OffsideRule::Parser.new(:indent_mode => :tab)
      @parser.set_content_handler do
        (
          (
            match[';'] >>
            match['^\s'].repeat(0).as(:comment)
          ) |
          (
            match['^='].repeat(1).as(:identifier) >>
            match['='] >>
            match['^\n'].repeat(1).as(:value)
          )
        ).as(:content)
      end
      @transformer = AnmTransformer.new
    end

    def parse(input)
      @transformer.apply(@parser.parse(input))
    end

  end

end
