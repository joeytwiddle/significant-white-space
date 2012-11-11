
au BufRead,BufNewFile {*.hx.sws}             set ft=haxe
au BufRead,BufNewFile {*.java.sws}           set ft=java
au BufRead,BufNewFile {*.c.sws}              set ft=c
au BufRead,BufNewFile {*.cpp.sws}            set ft=cpp
au BufRead,BufNewFile {*.js.sws}             set ft=javascript

command SWSDecurl exec "!sws safe-decurl % %.sws" | :e %.sws
command SWSCurl exec ":!sws safe-curl % %<" | :e %<

au BufReadPost {*.{hx,java,c,cpp,js,C}} if exists("*CheckNotNewerThan") | call CheckNotNewerThan(expand("%").".sws") | endif
au BufReadPost {*.sws} if exists("*CheckNotNewerThan") | call CheckNotNewerThan(expand("%<")) | endif

" Simple but messy: writes errors over your screen!
"autocmd BufWritePost,FileWritePost *.sws silent !sws curl "%" "%:r" >/dev/null

" Better: output shown tidily, and also saved in quickfix list.
"set makeprg=sws
"autocmd BufWritePost,FileWritePost *.sws :make curl "%" "%:r"

" Alternative: create and use a constant build script:
"set makeprg=bash\ ./build.sh
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

