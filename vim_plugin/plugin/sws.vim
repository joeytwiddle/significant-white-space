" sws.vim - Vim settings for significant-white-space files
" vim: foldmethod=marker ts=2 sw=2 expandtab

" Detect filetypes for decurled files
au BufRead,BufNewFile {*.hx.sws}             set ft=haxe
au BufRead,BufNewFile {*.java.sws}           set ft=java
au BufRead,BufNewFile {*.c.sws}              set ft=c
au BufRead,BufNewFile {*.cpp.sws}            set ft=cpp
au BufRead,BufNewFile {*.js.sws}             set ft=javascript

" Shortcut commands to transform a file and open the result
command SWSDecurl exec "!sws safe-decurl % %.sws" | :e %.sws
command SWSCurl exec ":!sws safe-curl % %<" | :e %<

" Automatically curl sws file on save {{{

" Simple but messy: writes errors over your screen!
"autocmd BufWritePost,FileWritePost *.sws silent !sws curl "%" "%:r" >/dev/null

" Better: output shown tidily, and also saved in quickfix list.
"set makeprg=sws
"autocmd BufWritePost,FileWritePost *.sws :make curl "%" "%:r"

" Alternative: create and use a constant build script:
"set makeprg=bash\ ./make.sh
"autocmd BufWritePost,FileWritePost *.sws :make

" Neat: Leaves makeprg untouched, must be enabled by setting g:SWSCurlOnWrite
" TODO: Only enable it per-window/buffer?
" TODO: Auto decurl also.
if !exists("g:SWSCurlOnWrite")
  let g:SWSCurlOnWrite = 0
endif
au BufWritePost,FileWritePost *.sws :call g:SWSCurlFile()
function! g:SWSCurlFile()
  if g:SWSCurlOnWrite
    let oldMakeprg = &makeprg
    let &makeprg = "sws"
    exec ':make safe-curl "%" "%:r"'
    let &makeprg = oldMakeprg
  endif
endfunction

" }}}

" Show warning if you open a sws or curled file but the *other* is newer! {{{

au BufReadPost {*.{hx,java,c,cpp,js,C}} if exists("*CheckNotNewerThan") | call CheckNotNewerThan(expand("%").".sws") | endif
au BufReadPost {*.sws} if exists("*CheckNotNewerThan") | call CheckNotNewerThan(expand("%<")) | endif

function! CheckNotNewerThan(fname)

  " Only do it the first time we open each file, not every time we read it
  " (which might be often if we set 'autoread' and have it visible in a
  " window).
  if exists("b:alreadyDoneSWSCheck")
    return
  endif
  let b:alreadyDoneSWSCheck = 1

  let otherFile = a:fname
  if filereadable(otherFile)
    let thisFile = expand("%")
    let thisModified = getftime(bufname("%"))
    let otherModified = getftime(otherFile)
    if otherModified > thisModified
      let res = confirm("Warning! File ".otherFile." is newer than this one!\nPerhaps you should be editing that instead!","&Press Enter")
    endif
  endif

endfunction

command! -nargs=1 CheckNotNewerThan call CheckNotNewerThan(<q-args>)

" }}}

