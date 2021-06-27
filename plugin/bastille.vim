augroup bastille
  autocmd BufEnter,BufWritePost *.md call luaeval("require('bastille').build_fences()")
augroup END
