def vim_stylesheet 
  "Statement { color: #ffff00; }
  .Type { color: #00ff00; }
  .Identifier { color: #00ffff; }
  .PreProc { color: #ff40ff; }
  .Comment { color: #8080ff; }
  .Special { color: #ff40ff; }
  .Constant { color: #ff6060; }
  pre { font-family: monospace; color: #000000; background-color: #ffffff; }
  body { font-family: monospace; color: #000000; background-color: #ffffff; }
  .lnr { color: #bd9901; }
  pre.code.vim { margin-left: 1pt; padding: 5pt; }
  pre.code.vim { color: #e1e1e1; background-color: #030507; }
  pre.code.vim .Constant { color: #ca0101; } 
  pre.code.vim .Identifier { color: #06989a; } 
  pre.code.vim .PreProc { color: #75507b; } 
  pre.code.vim .Underlined { color: #75507b; } 
  pre.code.vim .Title { color: #75507b; } 
  pre.code.vim .Special { color: #75507b; } 
  pre.code.vim .Statement { color: #bd9901; } 
  pre.code.vim .Type { color: #4e9a06; } 
  pre.code.vim .Comment { color: #3465a4; }
  pre.code.vim a[href] { color: #D52222; }".gsub("\t",'')
end

site.filters { 

  vim { |text,binding| 
    eval('@vim_filter_called = true',binding) # can use to include stylesheet as necessry
    split    = text.split("\n")
    filename = split.shift.sub /vim: (.*)/, '\1'
    content  = split.join "\n"
    tmp_dir  = File.join site.root_directory, 'vim_snippets'
    tmp_dir  = site.vim_snippets_dir if site.variables.keys.include?'vim_snippets_dir'
    Dir.mkdir tmp_dir unless File.directory?tmp_dir
    path = eval('request.env.REQUEST_URI',binding).sub(/^\//,'').gsub('/','_')
    full_save_path = File.join tmp_dir, "#{path}_#{filename}"
    full_html_path = full_save_path + '.html'
    if File.file?full_html_path and not eval('@vim_no_cache',binding)
      File.read(full_html_path)
    else
      content = content.gsub('<\%','<%') # un-escape ERB tags so they get highlighted
      File.open(full_save_path,'w'){ |f| f << content }
      # could get complicated and do this in another thread and 
      # load a div with some ajax to request the path and load, when ready ...
      # but i don't care about performance cause it'll only ever hit it ONCE 
      # with vim ...
      `vim +'exe "normal zR"' +":runtime\! syntax/2html.vim" +'wq!' +'q!' '#{full_save_path}' 2>/dev/null`
      if File.file?full_html_path
        html = File.read(full_html_path)
        html = html[/<pre>(.*)<\/pre>/m].sub('<pre>','<pre class="code vim">')
        File.open(full_html_path,'w'){ |f| f << html }
        html
      else
        "Problem highlighting code!"
      end
    end
  }

}
