module Rfactor
  
  class Code
    
    def initialize(code)
      @code = code
      @ast = RubyParser.new.parse(code)
      @line_finder = LineFinder.new(@ast)
    end
    
    def extract_method(args)
      raise ":name is required" unless args.has_key?(:name)
      
      method_lines = @line_finder.method_lines(args[:start])
      selected_lines = Range.new(args[:start], args[:end])
      
      new_code = ""
      extracted_method = ""
      added = false
      identation = 0
      
      @code.each_with_index do |line, n|
        line_number = n + 1 # not 0-based
        if line_number == method_lines.first
          identation = extract_identation_level_from line
          extracted_method << "\n#{identation}"
          extracted_method << "def #{args[:name]}()\n"
        end
        if selected_lines.include? line_number
          new_code << "#{identation}  #{args[:name]}()\n" if line_number == selected_lines.first
          extracted_method << line
        elsif line_number > method_lines.last && !added
          added = true
          new_code << extracted_method << "#{identation}end\n"
          new_code << line
        else
          new_code << line
        end
      end
      new_code << "\n#{extracted_method}#{identation}end\n" unless added
      new_code
    end
    
    private
    def extract_identation_level_from(line)
      spaces = line.match /^(\s*)def/
      spaces.captures[0]
    end
    
  end
end