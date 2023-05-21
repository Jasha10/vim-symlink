if exists('g:symlink_loaded')
  finish
endif
let g:symlink_loaded = 1

" Dict to track which filepaths have already been resolved
let s:resolved = {}

if get(g:, symlink_resolver_debug, 0)
  echom 'Symlink resolver plugin loaded'
  function! s:debug(msg)
    echom a:msg
  endfunction
else
  function! s:debug(msg)
  endfunction
endif

function! s:resolve_and_read_file(filepath)
  " Test if filepath is a symlink. If so, call `:file` to rename the buffer to the resolved
  " filepath. Then do some gymnastics to ensure that the file is read into the buffer properly.
  let l:filepath = expand(a:filepath)

  " Prevent infinite recursion
  if has_key(s:resolved, l:filepath)
    call s:debug('Already resolved: ' . l:filepath)
    return
  endif
  call s:debug('Got filepath: ' . l:filepath)
  let s:resolved[l:filepath] = 1

  if s:is_symlink(l:filepath)
    " Resolve symlinks and change the buffer's filepath
    let l:filepath = s:recursive_resolve(l:filepath)
    call s:change_file_to_resolved(l:filepath)
    call s:debug('Changed buffer ' .. expand('<abuf>') .. ' to ' .. l:filepath)
    call s:resolve_and_read_file(l:filepath)
  else
    call s:debug('Not a symlink: ' . l:filepath)
    " Note order of the following lines is important and affects the result of file loading
    doautocmd BufReadCmd  " It's necessary to call BufReadCmd here so that special filetypes like *.zip will be handled properly
    doautocmd BufReadPre  " For some reason, the presence of our BufReadCmd autocmd prevents BufReadPre from being called
    doautocmd BufRead     " For some reason, the presence of our BufReadCmd autocmd prevents BufRead from being called
    edit                  " For some reason, the presence of our BufReadCmd necessitates calling :edit here to load the file
  endif

endfunction

function! s:is_symlink(filepath)
  return a:filepath !=# resolve(a:filepath)
endfunction

function! s:change_file_to_resolved(resolved)
  execute 'file ' .. a:resolved
endfunction

function! s:recursive_resolve(filepath)
  " Recursively call resolve() until the filepath is no longer a symlink
  let l:resolved = resolve(a:filepath)
  if l:resolved ==# a:filepath
    return l:resolved
  endif
  return s:recursive_resolve(l:resolved)
endfunction

augroup symlink_resolver_plugin
  autocmd!
  " We use `BufReadCmd` autocmd to pre-empt loading of the file into the buffer. This, in the case
  " where <afile> is a symlink, we don't have to muck around with deleting the old buffer after
  " computing the resolved filepath. Note if you instead use e.g. a BufReadPre or BufRead autocmd,
  " you need to do something like call `Bwipeout` to delete the old buffer so as to work around an
  " issue where vim opens the symlink even when given the target path directly. This is what was
  " done in the original version of this plugin, but it's not necessary with BufReadCmd. The
  " `Bwipeout` approach can cause bugs, as some plugins may try to access the buffer after it's been
  " deleted, leading to errors like `Invalid buffer id: 1`.
  " https://superuser.com/questions/960773/vim-opens-symlink-even-when-given-target-path-directly
  " Tested against nvim v0.9.0
  autocmd BufReadCmd * call s:resolve_and_read_file('<afile>')
augroup END
