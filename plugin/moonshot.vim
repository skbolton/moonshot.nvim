augroup moonshot
  autocmd BufEnter,BufWritePost *.md call luaeval("require'moonshot'.build_fences()")
augroup END
