require "cgi"

module Jekyll

  class HightLight < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      source = "<pre class=\"prettyprint\"><code>"
      code = CGI.escapeHTML super.lstrip.rstrip
      code.lines.each do |line|
        source += "#{ line }"
      end
      source += "</code></pre>"
    end

  end

end

Liquid::Template.register_tag("hl", Jekyll::HightLight)
