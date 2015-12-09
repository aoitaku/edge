module Edge

  module Animator

    def self.load(anm)
      create_from_array(parse(File.read(anm)))
    end

    def self.create_from_array(animations)
      filename, cell_width, cell_height = animations.first.flat_map do |*, frames|
        frames.first.values_at(:filename, :width, :height)
      end
      image = DXRuby::Image.load(filename)
      cols, rows = image.width / cell_width, image.height / cell_height
      animation_image = image.slice_tiles(cols, rows)
      motions = animations.flat_map do |animation|
        key, frames = animation.to_a.first
        delay = (frames.first[:delay] / 16.6).floor
        pattern = frames.map {|frame|
          x, y = frame.values_at(:src_x, :src_y)
          x / cell_width + y / cell_height * cols
        }
        DXRuby::Animative::Motion.new(key, delay, pattern)
      end

      DXRuby::Animation.new(animation_image, motions)
    end

    def self.parse(anm)
      return [] unless @parser
      AnmParser.parse(anm).reject do |animation|
        animation.key?(:comment) || animation.key?(:anime_version)
      end
    end

  end

end
