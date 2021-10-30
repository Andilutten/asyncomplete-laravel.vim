# Asyncomplete-laravel.vim

Provides extra completion for [Laravel]() based php projects using
[asyncomplete]() for vim.

## Features

*This plugin is still in very early alpha*.

- Completion of route names.

## Planned

- Completion of view names.
- Blade directive completion.

## Installation

Using [vim-plug]()

```vim
Plug 'Andilutten/asyncomplete-laravel.vim'
```

## Usage

Just register the source using `asyncomplete#register_source`.

```vim
call asyncomplete#register_source(asyncomplete#sources#laravel#get_source_options({
			\ 'name': 'laravel',
			\ 'allowlist': ['php', 'blade'],
			\ }))
```
