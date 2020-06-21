For vim syntax highlighting to work, it's based on YOUR .vimrc

```vimrc
syntax on
autocmd BufNewFile,BufFilePre,BufRead *.me set filetype=markdown.pandoc
```