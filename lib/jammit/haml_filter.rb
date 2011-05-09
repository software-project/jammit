#require "haml"
#require "yaml"

module Jammit
  module Filters

    # Allows to use :each that generates jst template for Underscore.js each loop
    # That:
    # :each
    # will produce:
    #   "<% collection.each(function(item) { %>"
    #
    # You can customize it by adding yml parameters to filer:
    # :each
    #   collection: tabs
    #   item: tab
    # to get:
    # "<% tabs.each(function(tab) { %>"
    #
    # Remember to close filter with :endeach filter.
    #
    # Full example:
    # :each
    #   collection: tabs
    #   item: tab
    # .test.div_class
    #   %p
    #     Paragraph text:
    #     :js
    #       = tab.get('body')
    # :endeach
    #
    # This will produce:
    # "<% tabs.each(function(tab) { %>"
    # <div><p>Paragraph text:<%= tab.get('body') %></p></div>
    # "<% } %>""
    #
    module Each
      include Haml::Filters::Base

      def render(text)
        options = text.to_yaml
        "<% #{options["collection"] || "collection"}.each(function(#{options["item"] || "item"}) { %>"
      end
    end

    # Generates closing end tag for each
    module Endeach
      include Haml::Filters::Base

      def render(text)
        "<% }); %>"
      end
    end

    # Generates if jst tag.
    # Using:
    # :if
    #   condition
    # .class
    #   %p
    #     Other haml content goes here.
    # :end
    # Produces:
    # <% if(condition) { %>
    # <div class='class'><p>Other haml content goes here.</p></div>
    # <% } %>
    # You can also add :else or :elseif
    module If
      include Haml::Filters::Base

      def render(condition)
        "<% if(#{condition.chop}) { %>"
      end
    end

    # Generates closing end tag for :if, :else and :elseif
    # Work also for :each if provided each as text for filter
    # Example:
    # :end
    #   each
    # Produces:
    # <% }); %>
    module End
      include Haml::Filters::Base

      def render(text)
        case text
          when "each"
            "<% }); %>"
          else
            "<% } %>"
        end
      end
    end

    # Same as :if but with else
    module Elseif
      include Haml::Filters::Base

      def render(condition)
        "<% } else if(#{condition.chop}) { %>"
      end
    end

    # Else tag for :if and :elseif tags
    # Using:
    # :if
    #   condition
    # Other haml tags goes here
    # :else
    # Other haml tags goes here
    # :end
    module Else
      include Haml::Filters::Base

      def render(text)
        "<% } else { %>"
      end
    end

    # Tag for inserting javascripts.
    # Available tags: =, if, else, elseif, end, each, endeach
    # Example:
    # :js
    #   = model.get("value")
    #   = model.get("name")
    #
    # Produces:
    # <%= model.get("value") %>
    # <%= model.get("name") %>
    #
    # You can also use this tag to add other javascript constent, like:
    # :js
    #   if(condition){
    #
    # Produces:
    # <% if(condition){ %>
    #
    # Other examples:
    # :js
    #   if condition
    # equals
    # :if
    #   condition
    #
    # :js
    #   else
    # equals
    # :else
    #
    # :js
    #   each collection item
    # equals
    # :each
    #   collection: collection
    #   item: itemx
    module Js
      include Haml::Filters::Base

      def render(text)
        js = ""
        text.split("\n").each{|line|
          js += "<%#{get_tag(line)} %>"
        }
        js
      end

      private
      def get_tag(line)
        case line
          when /^=/
            line
          when /^if/
            " if(#{line.gsub("if ","")}) {"
          when /^elseif/
            "<% } else if(#{line.gsub("elseif ","").chop}) {"
          when /^else/
            " } else {"
          when /^endeach/
            " });"
          when /^end/
            " }"
          when /^each/
            options = line.split(' ')
            "#{options[1] || "collection"}.each(function(#{options[2] || "item"}) {"
          else
            line
        end
      end

    end

## Generetes tags provided in filter text
## Available tags: if, else, else
#    module JsTag
#      include Haml::Filters::Base
#
#      def render(text)
#        js = ""
#        text.split("\n").each{|line|
#          js += "<%#{line} %>"
#        }
#        js
#      end
#
#    end
  end
end

