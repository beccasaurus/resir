def capture(*args, &block)

  begin
    buffer = eval(Resir.erb_variable, block.binding)
  rescue
    buffer = nil
  end

  if buffer.nil?
    capture_block(*args, &block).to_s
  else
    capture_erb_with_buffer(buffer, *args, &block).to_s
  end
end

# def content_for(name, content = nil, &block)
#   existing_content_for = instance_variable_get("@content_for_#{name}").to_s
#   new_content_for      = existing_content_for + (block_given? ? capture(&block) : content)
#   instance_variable_set("@content_for_#{name}", new_content_for)
# end

# private

def capture_block(*args, &block)
  block.call(*args)
end

def capture_erb(*args, &block)
  buffer = eval(Resir.erb_variable, block.binding)
  capture_erb_with_buffer(buffer, *args, &block)
end

def capture_erb_with_buffer(buffer, *args, &block)
  pos = buffer.length
  block.call(*args)

  # extract the block 
  data = buffer[pos..-1]

  # replace it in the original with empty string
  buffer[pos..-1] = ''

  data
end

# def erb_content_for(name, &block)
#   eval "@content_for_#{name} = (@content_for_#{name} || '') + capture_erb(&block)"
# end
# 
# def block_content_for(name, &block)
#   eval "@content_for_#{name} = (@content_for_#{name} || '') + capture_block(&block)"
# end

def concat(string, binding)
  eval(Resir.erb_variable, binding) << string
end 

def filter *args, &block

  unless args.nil? or block.nil?
    args = args.map &:to_s
    
    if eval("defined?#{Resir.erb_variable}", block.binding)
    
      content = capture(&block)
      content = Resir::render_with_filters content, binding(), *args
      concat content, block.binding

    else # assume we're being passed a simple String in block

      content = block.call
      content = Resir::render_with_filters content, binding(), *args
      content

    end
  end
end
