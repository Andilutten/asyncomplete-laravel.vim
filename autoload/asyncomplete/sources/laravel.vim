" vim:ft=vim:ts=4:noexpandtab
let s:routes = {}

function! asyncomplete#sources#laravel#completor(opt, ctx) abort
	let l:col = a:ctx['col']
	let l:typed = a:ctx['typed']

	let l:re = "\\vroute\\(['\"](\\S+)"

	" Make sure that the typed words matches regexp
	if l:typed->match(l:re) == -1
		return
	endif

	let l:route = l:typed->matchlist(l:re)
	let l:routelen = l:route->get(1)->len()

	let l:startcol = l:col - l:routelen

	let l:matches = map(
				\ asyncomplete#sources#laravel#get_routes(),
				\ s:get_match_opts("route"))

	call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! s:get_match_opts(name)
	return printf('{"word": v:val, "dup": 1, "icase": 1, "menu": "[%s]"}', a:name)
endfunction

function! s:on_event(opt, ctx, event) abort
	if a:event == 'BufWinEnter'
		if empty(s:routes)
			call s:refresh_routes()
		endif
	elseif a:event == 'BufWritePost'
		if bufname()->match("routes/") != -1
			call s:refresh_routes()
		endif
	endif
endfunction

function! asyncomplete#sources#laravel#get_routes() abort
	return keys(s:routes)
endfunction

function! asyncomplete#sources#laravel#get_source_options(opts)
	return extend({
				\ 'events': ['BufWinEnter', 'BufWritePost'],
				\ 'on_event': function('s:on_event'),
				\ 'completor': function('asyncomplete#sources#laravel#completor'),
				\ }, a:opts)
endfunction

function! s:on_routes(channel, msg) abort
	let l:data = json_decode(a:msg)
	for item in l:data
		if item.name != v:null
			let s:routes[item.name] = 1
		endif
	endfor
endfunction

function! s:on_routes_err(channel, msg) abort
	call asyncomplete#log('asyncomplete#laravel', 'on_routes_err', a:msg)
endfunction

function! s:refresh_routes() abort
	call job_start("php artisan route:list --columns=name --json", 
				\ {'out_cb': function('s:on_routes'), 
				\ 'err_cb': function('s:on_routes_err')})
endfunction
