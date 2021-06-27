# Moonshot.nvim
**WARNING: VERY BETA SOFTWARE**

[Literate programming](https://en.wikipedia.org/wiki/Literate_programming) with Neovim and markdown.

There is no denying the power and awesomeness of [Org Mode](https://orgmode.org/) and its ecosystem. But it's not coming to Neovim anytime soon. Doesn't mean we can't steal some ideas and enjoy what our ecosystem is capable of. This is our moonshot.

## Getting Started

[Neovim Nigthly 0.5](https://github.com/neovim/neovim/releases/tag/nightly) is required to run moonshot

### Installation

Install with your favorite package manager.

Using `vim-plug`
```vim
Plug 'skbolton/moonshot.nvim`
```

Using `packer`
```vim
use 'skbolton/moonshot.nvim'
```

### Usage

Add fenced code blocks to your markdown documents.

<code>
<pre>
```sh
echo "Hello Literate Programming"
```
</pre>
</code>

With your cursor in the block you can run:

`:lua require'moonshot'.run_cursor()`

And you should see the following.
<code>
<pre>
```sh
echo "Hello, Literate Programming"
```
</pre>
:RESULTS:
"Hello, Literate Programming
</code>

Add as many of these code blocks as you'd like. If you decide you want to run them all at the same time you can run this:

```
:lua require'moonshot'.run_all()`
```

## Available Commands

The following are all the available commands. Bind them to the keys of your choice, no default key bindings are put in place.

```
" run/refresh all the blocks
nnoremap <leader>> <cmd>lua require'moonshot'.run_all()<CR>
" run/refresh block under cursor
nnoremap <leader>= <cmd>lua require'moonshot'.run_cursor()<CR>
" Remove all result blocks
nnoremap <leader>< <cmd>lua require'moonshot'.clean_all()<CR>
" Remove block under cursor
nnoremap <leader>< <cmd>lua require'moonshot'.clean_cursor()<CR>
```

