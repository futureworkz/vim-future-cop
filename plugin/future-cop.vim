" Vim plugin to run the gem future_cop on current file and display the results
" in quickfix window
"
" Author:    Steven Yap
" URL:       https://github.com/futureworkz/vim-future-cop
" Version:   0.1
" Copyright: Copyright (c) 2015 Futureworkz
" License:   MIT
"
" ---------------------------------------------------------------------------- 

" if &cp || exists("g:loaded_vimfuturecop")
"   finish
" endif
" let g:loaded_vimfuturecop = 1

function! s:FutureCop()
  let l:filename = @%
  let l:qf_results = []

  let l:output = system('reek ' . l:filename)
  for l:line in split(l:output, '\n')
    let l:err = matchlist(l:line, '\vs*\[(\d*)\]:(.*:.*) \[(.*)\]')
    if len(l:err) > 0
      call add(l:qf_results, l:filename.':'.err[1].':0:Reek - '.err[2])
    endif
  endfor

  let l:output = system('rubocop --format emacs ' . l:filename)
  for l:line in split(l:output, '\n')
    let l:err = matchlist(l:line, '\v(.*):(\d*):(\d*):(.*)')
    if len(l:err) > 0
      call add(l:qf_results, l:filename.':'.err[2].':'.err[3].':Rubocop - '.err[4])
    endif
  endfor

  let l:output = system('rails_best_practices --without-color ' . l:filename)
  for l:line in split(l:output, '\n')
    let l:err = matchlist(l:line, '\v(.*):(\d*) - (.*)')
    if len(l:err) > 0
      call add(l:qf_results, l:filename.':'.err[2].':0:RBP - '.err[3])
    endif
  endfor

  if (len(l:qf_results))
    call insert(l:qf_results, 'Total Violation(s): ' . len(l:qf_results))
  else
    call insert(l:qf_results, 'No violations detected! You are amazing!')
  endif

  cexpr l:qf_results
  copen
endfunction

command! FutureCop :call <SID>FutureCop()
