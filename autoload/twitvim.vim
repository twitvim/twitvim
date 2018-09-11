" Load this module only once.
if exists('g:loaded_twitvim_autoload')
    finish
endif
let g:loaded_twitvim_autoload = '0.9.2 2017-03-28'

" Avoid side-effects from cpoptions setting.
let s:save_cpo = &cpo
set cpo&vim

" User agent header string.
let s:user_agent = 'TwitVim '.g:loaded_twitvim_autoload

" Twitter character limit. Twitter used to accept tweets up to 246 characters
" in length and display those in truncated form, but that is no longer the
" case. So 280 is now the hard limit.
let s:char_limit = 280

" Twitter character limit for DMs. Longer limits were rolled out in mid-August, 2015.
let s:dm_char_limit = 10000

" Info on OAuth-based service providers.
let s:service_info = {
            \ 'twitter' : {
            \ 'dispname'        : 'Twitter',
            \ 'consumer_key'    : 'HyshEU8SbcsklPQ6ouF0g',
            \ 'consumer_secret' : 'U1uvxLjZxlQAasy9Kr5L2YAFnsvYTOqx1bk7uJuezQ',
            \ 'req_url'         : 'https://api.twitter.com/oauth/request_token',
            \ 'access_url'      : 'https://api.twitter.com/oauth/access_token',
            \ 'authorize_url'   : 'https://api.twitter.com/oauth/authorize',
            \ 'api_root'        : 'https://api.twitter.com/1.1',
            \ 'search_api'      : 'https://api.twitter.com/1.1/search/tweets.json',
            \ },
            \ }

let s:default_service = 'twitter'
let s:default_api_root = s:service_info[s:default_service]['api_root']
let s:cur_service = ''

" Attempt to get the current service even on startup and even if user has not
" logged in yet. Returns '' if cannot determine.
function! s:get_cur_service()
    " Get current service from token file or do OAuth login.
    if s:cur_service == ''
        call s:read_tokens()
        if s:cur_service == ''
            let [ status, error ] = s:do_login()
            if status < 0
                return ''
            endif
        endif
    endif
    return s:cur_service
endfunction

" Allow the user to override the API root for services other than Twitter and identi.ca.
function! s:get_api_root()
    let svc = s:get_cur_service()
    return svc == '' ? s:default_api_root : s:service_info[svc]['api_root']
endfunction

" Service display name.
function! s:get_svc_disp_name()
    return s:service_info[s:cur_service]['dispname']
endfunction

function! s:get_disp_name(service)
    return get(s:service_info, a:service, { 'dispname' : a:service })['dispname']
endfunction

function! s:get_use_job()
    if has('win32') && !has('gui_running')
        return 0
    endif
    return get(g:, 'twitvim_use_job', 0) && exists('*job_start')
endfunction

" Allow user to set the format for retweets.
function! s:get_retweet_fmt()
    return get(g:, 'twitvim_retweet_format', 'RT %s: %t')
endfunction

" Allow user to enable Python networking code by setting twitvim_enable_python.
function! s:get_enable_python()
    return get(g:, 'twitvim_enable_python', 0)
endfunction

" Allow user to enable Python 3 networking code by setting twitvim_enable_python3.
function! s:get_enable_python3()
    return get(g:, 'twitvim_enable_python3', 0)
endfunction

" Allow user to enable Perl networking code by setting twitvim_enable_perl.
function! s:get_enable_perl()
    return get(g:, 'twitvim_enable_perl', 0)
endfunction

" Allow user to enable Ruby code by setting twitvim_enable_ruby.
function! s:get_enable_ruby()
    return get(g:, 'twitvim_enable_ruby', 0)
endfunction

" Allow user to enable Tcl code by setting twitvim_enable_tcl.
function! s:get_enable_tcl()
    return get(g:, 'twitvim_enable_tcl', 0)
endfunction

" Get proxy setting from twitvim_proxy in .vimrc or _vimrc.
" Format is proxysite:proxyport
function! s:get_proxy()
    return get(g:, 'twitvim_proxy', '')
endfunction

" If twitvim_proxy_login exists, use that as the proxy login.
" Format is proxyuser:proxypassword
" If twitvim_proxy_login_b64 exists, use that instead. This is the proxy
" user:password in base64 encoding.
function! s:get_proxy_login()
    return exists('g:twitvim_proxy_login_b64') && g:twitvim_proxy_login_b64 != '' ? g:twitvim_proxy_login_b64 : get(g:, 'twitvim_proxy_login', '')
endfunction

" Get twitvim_count, if it exists. This will be the number of tweets returned
" by :FriendsTwitter, :UserTwitter, and :SearchTwitter.
function! s:get_count()
    return exists('g:twitvim_count') ? min([200, max([1, g:twitvim_count])]) : 0
endfunction

" User setting to show/hide header in the buffer. Default: show header.
function! s:get_show_header()
    return get(g:, 'twitvim_show_header', 1)
endfunction

" User config for name of OAuth access token file.
function! s:get_token_file()
    return get(g:, 'twitvim_token_file', $HOME.'/.twitvim.token')
endfunction

" User config to disable the OAuth access token file.
function! s:get_disable_token_file()
    return get(g:, 'twitvim_disable_token_file', 0)
endfunction

" User config to enable the filter.
function! s:get_filter_enable()
    return get(g:, 'twitvim_filter_enable', 0)
endfunction

" User config for filter.
function! s:get_filter_regex()
    return get(g:, 'twitvim_filter_regex', '')
endfunction

" User config for Trends WOEID.
" Default to 1 for worldwide.
function! s:get_twitvim_woeid()
    return get(g:, 'twitvim_woeid', 1)
endfunction

" Allow user to override consumer key.
function! s:get_consumer_key()
    return get(g:, 'twitvim_consumer_key', s:service_info[s:cur_service]['consumer_key'])
endfunction

" Allow user to override consumer secret.
function! s:get_consumer_secret()
    return get(g:, 'twitvim_consumer_secret', s:service_info[s:cur_service]['consumer_secret'])
endfunction

" Allow user to customize timestamp format in timeline display.
" Default is HH:MM AM/PM Mon DD, YYYY
function! s:get_timestamp_format()
    return get(g:, 'twitvim_timestamp_format', '%I:%M %p %b %d, %Y')
endfunction

" Allow user to customize network timeout in seconds.
" Default is 0 for no timeout, which defers to the system socket timeout.
function! s:get_net_timeout()
    return get(g:, 'twitvim_net_timeout', 10)
endfunction

" Don't strip newlines from tweets being posted
" Default is 0 so newlines will get replaced by single spaces
function! s:get_allow_multiline()
    return get(g:, 'twitvim_allow_multiline', 0)
endfunction

function! s:system(...) abort
    if !s:get_use_job()
        return call('system', a:000)
    endif
    let [out, err] = ['', '']
    redraw
    let arg = has("win32") || has("win64") ?
    \    printf('%s %s %s', &shell, &shellcmdflag, a:1) :
    \    [&shell, &shellcmdflag, a:1]
    let job = job_start(arg, {
    \    'out_cb': {id,x->[execute('let out .= x'), out]},
    \    'err_cb': {id,x->[execute('let err .= x'), err]},
    \})
    let s:job_shell_error = 0
    if a:0 > 1
        let ch = job_getchannel(job)
        call ch_sendraw(ch, a:2)
        call ch_close_in(ch)
        try
            while ch_status(ch) != 'closed'
                sleep 10m
            endwhile
            redraw
        catch
            let s:job_shell_error = -1
            call job_stop(job)
            call getchar()
            redraw
            call s:errormsg(v:exception)
            return 'canceled'
        endtry
    else
        try
            while job_status(job) == 'run'
                sleep 10m
            endwhile
            redraw
        catch
            let s:job_shell_error = -1
            call job_stop(job)
            call getchar()
            redraw
            call s:errormsg(v:exception)
            return 'canceled'
        endtry
    endif
    sleep 10m
    call job_stop(job)
    let s:job_shell_error = job_info(job).exitval
    if s:job_shell_error
        return iconv(err, 'char', &encoding)
    endif
    return out
endfunction

function! s:shell_error()
    if s:get_use_job()
        return s:job_shell_error
    else
        return v:shell_error
    endif
endfunction

function! s:has_error(result)
    if type(a:result) == type({})
        return has_key(a:result, 'error') || has_key(a:result, 'errors')
    endif
    if type(a:result) == type([])
        for m in a:result
            if type(m) == type({}) && has_key(m, 'errors')
                return 1
            endif
        endfor
    endif
    return 0
endfunction

function! s:get_error_message(result)
    if type(a:result) == type({})
        if has_key(a:result, 'error')
            return a:result['error']
        endif
        if has_key(a:result, 'errors')
            return join(map(a:result['errors'], 'get(v:val, "message", "")'), ",")
        endif
    endif
    if type(a:result) == type([])
        for m in a:result
            if type(m) == type({}) && has_key(m, 'errors')
                return join(map(m['errors'], 'get(v:val, "message", "")'), ",")
            endif
        endfor
    endif
    if type(a:result) == type('')
        return a:result
    endif
    return string(a:result)
endfunction

" Display an error message in the message area.
function! s:errormsg(msg)
    redraw
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction

" Display a warning message in the message area.
function! s:warnmsg(msg)
    redraw
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunction

" Throw away saved login tokens and reset login info.
function! twitvim#reset_twitvim_login()
    call inputsave()
    let answer = input('Delete all login info? (y/n) ')
    call inputrestore()
    if answer != 'y' && answer != 'Y'
        redraw
        echo 'Login info not deleted.'
        return
    endif

    let s:access_token = ""
    let s:access_token_secret = ""
    let s:tokens = {}
    call delete(s:get_token_file())

    let s:cached_username = ""
endfunction

" Log in to a Twitter account.
function! twitvim#prompt_twitvim_login()
    call s:do_login()
endfunction

" Display a menu of user logins.
function! s:logins_menu(userlist, what)
    let menu = []
    call add(menu, 'Choose a login to '.a:what)
    let namecount = 0
    for userrec in a:userlist
        let namecount += 1
        call add(menu, namecount.'. '. userrec.name . ' on ' . s:get_disp_name(userrec.service))
    endfor

    call inputsave()
    let input = inputlist(menu)
    call inputrestore()
    if input < 1 || input > len(a:userlist)
        " Invalid input cancels the command.
        return {}
    endif

    return a:userlist[input - 1]
endfunction

" Delete a Twitter login.
function! twitvim#delete_twitvim_login(user)
    if s:tokens == {}
        call s:read_tokens()
    endif
    let user = a:user
    if user == ''
        let userlist = s:list_tokens_for_del()
        if userlist == []
            call s:errormsg('No logins to delete.')
            return
        endif

        let userrec = s:logins_menu(userlist, 'delete')
        if userrec == {}
            " User canceled.
            return
        endif
    else
        let [ name, service ] = split(a:user, ',')
        let userrec = { 'name' : name, 'service' : service }
    endif
    call s:delete_token(userrec.name, userrec.service)
    call s:write_tokens(s:cached_username)
endfunction

" Switch to a different Twitter user.
function! twitvim#switch_twitvim_login(user)
    if s:tokens == {}
        call s:read_tokens()
    endif
    let user = a:user
    if user == ''
        let userlist = s:list_tokens()
        if userlist == []
            call s:errormsg('No logins to switch to. Use :SetLoginTwitter to log in.')
            return
        endif

        let userrec = s:logins_menu(userlist, 'switch to')
        if userrec == {}
            " User canceled.
            return
        endif
    else
        let [ name, service ] = split(a:user, ',')
        let userrec = { 'name' : name, 'service' : service }
    endif
    call s:switch_token(userrec.name, userrec.service)
    call s:write_tokens(s:cached_username)
endfunction

let s:cached_username = ''

" See if we can save time by using the cached username.
function! s:get_twitvim_cached_username()
    return s:cached_username
endfunction

" Get Twitter user name by verifying login credentials
function! s:get_twitvim_username()
    " If we already have the info, no need to get it again.
    let username = s:get_twitvim_cached_username()
    if username != ''
        return username
    endif

    redraw
    echo 'Verifying login credentials...'

    let url = s:get_api_root().'/account/verify_credentials.json'
    let [error, output] = s:run_curl_oauth_get(url, {})
    if !empty(error)
        call s:errormsg('Error verifying login credentials: '.error)
        return ''
    endif
    let result = s:parse_json(output)
    if empty(result)
        return ''
    endif
    if s:has_error(result)
        call s:errormsg('Error verifying login credentials: '.s:get_error_message(result))
        return ''
    endif

    redraw
    echo 'Login credentials verified.'

    let username = get(result, 'screen_name', '')

    " Save it so we don't have to do it again unless the user switches to
    " a different login.
    let s:cached_username = username
    return username
endfunction

" If set, twitvim_cert_insecure turns off certificate verification if using
" https Twitter API over cURL or Ruby.
function! s:get_twitvim_cert_insecure()
    return get(g:, 'twitvim_cert_insecure', 0)
endfunction

" === JSON parser ===

" Surrogate Pair code (@mattn_jp)
function! s:surrogate_pair(n1, n2)
    return nr2char(or((a:n1 - 0xd800) * 1024, and((a:n2 - 0xdc00), 0x3ff)) + 0x10000)
endfunction

function! s:parse_json(str)
    try
        if has('patch-8.0.176')
            return js_decode(a:str)
        endif
        let true = 1
        let false = 0
        let null = ''
        let str = a:str
        " handle surrogate pair
        if exists('*or') && exists('*and')
            let str = substitute(str, '\\u\(d[8-f]\x\x\)\\u\(d[c-f]\x\x\)', '\=s:surrogate_pair("0x".submatch(1), "0x".submatch(2))', 'g')
        endif
        let str = substitute(str, '\\u\(\x\{4}\)', '\=s:nr2enc_char("0x".submatch(1))', 'g')
        sandbox let result = eval(str)
        return result
    catch
        call s:errormsg('JSON parse error: '.v:exception)
        return {}
    endtry
endfunction

" === XML helper functions ===

" Get the content of the n'th element in a series of elements.
function! s:xml_get_nth(xmlstr, elem, n)
    let matchres = matchlist(a:xmlstr, '<'.a:elem.'\%( [^>]*\)\?>\(.\{-}\)</'.a:elem.'>', -1, a:n)
    return matchres == [] ? '' : matchres[1]
endfunction

" Get all elements in a series of elements.
function! s:xml_get_all(xmlstr, elem)
    let pat = '<'.a:elem.'\%( [^>]*\)\?>\(.\{-}\)</'.a:elem.'>'
    let matches = []
    let pos = 0

    while 1
        let matchres = matchlist(a:xmlstr, pat, pos)
        if matchres == []
            return matches
        endif
        call add(matches, matchres[1])
        let pos = matchend(a:xmlstr, pat, pos)
    endwhile
endfunction

" Get the content of the specified element.
function! s:xml_get_element(xmlstr, elem)
    return s:xml_get_nth(a:xmlstr, a:elem, 1)
endfunction

" Remove any number of the specified element from the string. Used for removing
" sub-elements so that you can parse the remaining elements safely.
function! s:xml_remove_elements(xmlstr, elem)
    return substitute(a:xmlstr, '<'.a:elem.'>.\{-}</'.a:elem.'>', '', "g")
endfunction

" Get the attributes of the n'th element in a series of elements.
function! s:xml_get_attr_nth(xmlstr, elem, n)
    let matchres = matchlist(a:xmlstr, '<'.a:elem.'\s\+\([^>]*\)>', -1, a:n)
    if matchres == []
        return {}
    endif

    let matchcount = 1
    let attrstr = matchres[1]
    let attrs = {}

    while 1
        let matchres = matchlist(attrstr, '\(\w\+\)="\([^"]*\)"', -1, matchcount)
        if matchres == []
            break
        endif

        let attrs[matchres[1]] = matchres[2]
        let matchcount += 1
    endwhile

    return attrs
endfunction

" Get attributes of the specified element.
function! s:xml_get_attr(xmlstr, elem)
    return s:xml_get_attr_nth(a:xmlstr, a:elem, 1)
endfunction

" === End of XML helper functions ===

" === Time parser ===

" Convert date to Julian date.
function! s:julian(year, mon, mday)
    let month = (a:mon - 1 + 10) % 12
    let year = a:year - month / 10
    return a:mday + 365 * year + year / 4 - year / 100 + year / 400 + ((month * 306) + 5) / 10
endfunction

" Calculate number of days since UNIX Epoch.
function! s:daygm(year, mon, mday)
    return s:julian(a:year, a:mon, a:mday) - s:julian(1970, 1, 1)
endfunction

" Convert date/time to UNIX time. (seconds since Epoch)
function! s:timegm(year, mon, mday, hour, min, sec)
    return a:sec + a:min * 60 + a:hour * 60 * 60 + s:daygm(a:year, a:mon, a:mday) * 60 * 60 * 24
endfunction

let s:monthnames = { 'jan' : 1, 'feb' : 2, 'mar' : 3, 'apr' : 4, 'may' : 5, 'jun' : 6, 'jul' : 7, 'aug' : 8, 'sep' : 9, 'oct' : 10, 'nov' : 11, 'dec' : 12 }

" Convert abbreviated month name to month number.
function! s:conv_month(s)
    return get(s:monthnames, tolower(a:s))
endfunction

function! s:timegm2(matchres, indxlist)
    let args = []
    for i in a:indxlist
        if i < 0
            let mon = s:conv_month(a:matchres[-i])
            if mon == 0
                return -1
            endif
            let args = add(args, mon)
        else
            let args = add(args, a:matchres[i] + 0)
        endif
    endfor
    return call('s:timegm', args)
endfunction

" Parse a Twitter time string.
" TODO: Not all of these may be needed any more.
function! s:parse_time(str)
    " This timestamp format is used by Twitter in timelines.
    let matchres = matchlist(a:str, '^\w\+,\s\+\(\d\+\)\s\+\(\w\+\)\s\+\(\d\+\)\s\+\(\d\+\):\(\d\+\):\(\d\+\)\s\++0000$')
    if matchres != []
        return s:timegm2(matchres, [3, -2, 1, 4, 5, 6])
    endif

    " This timestamp format is used by Twitter in response to an update.
    let matchres = matchlist(a:str, '^\w\+\s\+\(\w\+\)\s\+\(\d\+\)\s\+\(\d\+\):\(\d\+\):\(\d\+\)\s\++0000\s\+\(\d\+\)$')
    if matchres != []
        return s:timegm2(matchres, [6, -1, 2, 3, 4, 5])
    endif

    " This timestamp format is used by Twitter Search.
    let matchres = matchlist(a:str, '^\(\d\+\)-\(\d\+\)-\(\d\+\)T\(\d\+\):\(\d\+\):\(\d\+\)Z$')
    if matchres != []
        return s:timegm2(matchres, range(1, 6))
    endif

    " This timestamp format is used by Twitter Rate Limit.
    let matchres = matchlist(a:str, '^\(\d\+\)-\(\d\+\)-\(\d\+\)T\(\d\+\):\(\d\+\):\(\d\+\)+00:00$')
    if matchres != []
        return s:timegm2(matchres, range(1, 6))
    endif

    return -1
endfunction

" Convert time_t value to time string.
function! s:time_fmt(tm)
    if !exists("*strftime")
        return ''.a:tm
    endif
    return strftime(s:get_timestamp_format(), a:tm)
endfunction

" Convert the Twitter timestamp to local time and simplify it.
function! s:time_filter(str)
    if !exists("*strftime")
        return a:str
    endif
    let t = s:parse_time(a:str)
    return t < 0 ? a:str : strftime(s:get_timestamp_format(), t)
endfunction

" === End of time parser ===

" === Token Management code ===

" Each token record holds the following fields:
"
" token: access token
" secret: access token secret
" name: screen name
" A lowercased copy of the screen name,service name is the hash key.

let s:tokens = {}
let s:token_header = 'TwitVim 0.8'

function! s:find_token(name, service)
    return get(s:tokens, tolower(a:name . ',' . a:service), {})
endfunction

function! s:save_token(tokenrec)
    let tokenrec = a:tokenrec
    let s:tokens[tolower(tokenrec.name . ',' . tokenrec.service)] = tokenrec
endfunction

" Delete an access token.
function! s:delete_token(name, service)
    let tokenrec = s:find_token(a:name, a:service)
    if tokenrec == {}
        call s:errormsg("No saved login for user ".a:name." on ".s:get_disp_name(a:service).".")
    elseif a:name ==? s:cached_username && a:service ==? s:cur_service
        call s:errormsg("Can't delete currently logged-in user.")
    else
        unlet! s:tokens[tolower(a:name . ',' . a:service)]
        redraw
        echo 'Login token deleted.'
    endif
endfunction

" Switch to another access token. Note that the token file should be written
" out again after this to reflect the new current user.
function! s:switch_token(name, service)
    let tokenrec = s:find_token(a:name, a:service)
    if tokenrec == {}
        call s:errormsg("Can't switch to user ".a:name." on ".s:get_disp_name(a:service).".")
    else
        let s:cur_service = tokenrec.service
        let s:access_token = tokenrec.token
        let s:access_token_secret = tokenrec.secret
        let s:cached_username = tokenrec.name
        redraw
        echo "Logged in as ".s:cached_username." on ".s:get_svc_disp_name()."."
    endif
endfunction

" Returns a list of screen names. This is for prompting the user to pick a login
" to which to switch.
function! s:list_tokens()
    return map(values(s:tokens), '{ "name" : v:val.name, "service" : v:val.service }')
endfunction

" Returns a newline-delimited list of screen names. This is for command
" completion when switching logins.
function! twitvim#name_list_tokens(ArgLead, CmdLine, CursorPos)
    return join(map(s:list_tokens(), 'v:val.name . "," . v:val.service'), "\n")
endfunction

" Returns a list of screen names except for the current user. This is for
" prompting the user to pick a login to delete.
function! s:list_tokens_for_del()
    return map(filter(values(s:tokens), 'v:val.name !=? s:cached_username || v:val.service !=? s:cur_service'), '{ "name" : v:val.name, "service" : v:val.service }')
endfunction

" Returns a newline-delimited list of screen names except for the current user.
" This is for command completion when deleting a login.
function! twitvim#name_list_tokens_for_del(ArgLead, CmdLine, CursorPos)
    return join(map(s:list_tokens_for_del(), 'v:val.name . "," . v:val.service'), "\n")
endfunction

" Write the token file.
function! s:write_tokens(current_user)
    if !s:get_disable_token_file()
        let tokenfile = s:get_token_file()

        let json_tokens = map(values(s:tokens), '{ "name" : v:val.name, "token" : v:val.token, "secret" : v:val.secret, "service" : v:val.service }')
        let json_obj = { 'current_service' : s:cur_service, 'current_user' : a:current_user, 'tokens' : json_tokens }

        let lines = []
        call add(lines, s:token_header)
        call add(lines, '')
        call add(lines, string(json_obj))

        if writefile(lines, tokenfile) < 0
            call s:errormsg('Error writing token file: '.v:errmsg)
        endif

        " Check and change file permissions for security.
        if has('unix')
            let perms = getfperm(tokenfile)
            if perms != '' && perms[-6:] != '------'
                silent! execute "!chmod go-rwx '".tokenfile."'"
            endif
        endif
    endif
endfunction

" Read the token file.
function! s:read_tokens()
    let tokenfile = s:get_token_file()
    if !s:get_disable_token_file() && filereadable(tokenfile)
        let [hdr, current_user; tokens] = readfile(tokenfile, 't', 500)
        if tokens == [] || hdr == 'TwitVim 0.6'
            call s:errormsg('Old token file format is not supported. Please remove "'.tokenfile.'" and try again.')
            return
        else
            let json_obj = s:parse_json(tokens[0])
            let current_user = json_obj['current_user']
            let service = get(json_obj, 'current_service', s:default_service)
            let json_tokens = json_obj['tokens']
            for json_token in json_tokens
                let tokenrec = {}
                let tokenrec.name = json_token.name
                let tokenrec.token = json_token.token
                let tokenrec.secret = json_token.secret
                let tokenrec.service = get(json_token, 'service', s:default_service)
                call s:save_token(tokenrec)
            endfor
            call s:switch_token(current_user, service)
        endif
    endif
endfunction
" === End of Token Management code ===

" === OAuth code ===

" Check if we can use Perl for HMAC-SHA1 digests.
function! s:check_perl_hmac()
    let can_perl = 1
    perl <<EOF
eval {
    require Digest::HMAC_SHA1;
    Digest::HMAC_SHA1->import;
};
if ($@) {
    VIM::DoCommand('let can_perl = 0');
}
EOF
    return can_perl
endfunction

" Compute HMAC-SHA1 digest. (Perl version)
function! s:perl_hmac_sha1_digest(key, str)
    perl <<EOF
require Digest::HMAC_SHA1;
Digest::HMAC_SHA1->import;

my $key = VIM::Eval('a:key');
my $str = VIM::Eval('a:str');

my $hmac = Digest::HMAC_SHA1->new($key);

$hmac->add($str);
my $signature = $hmac->b64digest; # Length of 27

VIM::DoCommand("let signature = '$signature'");
EOF

    return signature
endfunction

" Check if we can use Python for HMAC-SHA1 digests.
function! s:check_python_hmac()
    let can_python = 1
    python <<EOF
import vim
try:
    import base64
    import hashlib
    import hmac
except:
    vim.command('let can_python = 0')
EOF
    return can_python
endfunction

" Compute HMAC-SHA1 digest. (Python version)
function! s:python_hmac_sha1_digest(key, str)
    python <<EOF
import base64
import hashlib
import hmac
import vim

key = vim.eval("a:key")
mstr = vim.eval("a:str")

digest = hmac.new(key, mstr, hashlib.sha1).digest()
signature = base64.encodestring(digest)[0:-1]

vim.command("let signature='%s'" % signature)
EOF
    return signature
endfunction

" Check if we can use Python 3 for HMAC-SHA1 digests.
function! s:check_python3_hmac()
    let can_python3 = 1
    python3 <<EOF
import vim
try:
    import base64
    import hashlib
    import hmac
except:
    vim.command('let can_python3 = 0')
EOF
    return can_python3
endfunction

" Compute HMAC-SHA1 digest. (Python 3 version)
function! s:python3_hmac_sha1_digest(key, str)
    python3 <<EOF
import base64
import hashlib
import hmac
import vim

key = vim.eval("a:key")
mstr = vim.eval("a:str")

digest = hmac.new(str.encode(key), str.encode(mstr), hashlib.sha1).digest()
signature = base64.encodestring(digest)[0:-1]

vim.command("let signature='%s'" % bytes.decode(signature))
EOF
    return signature
endfunction

" Check if we can use Ruby for HMAC-SHA1 digests.
function! s:check_ruby_hmac()
    let can_ruby = 1
    ruby <<EOF
begin
    require 'openssl'
    require 'base64'
rescue LoadError
    VIM.command('let can_ruby = 0')
end
EOF
    return can_ruby
endfunction

" Compute HMAC-SHA1 digest. (Ruby version)
function! s:ruby_hmac_sha1_digest(key, str)
    ruby <<EOF
require 'openssl'
require 'base64'

key = VIM.evaluate('a:key')
str = VIM.evaluate('a:str')

digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), key, str)
signature = Base64.encode64(digest).chomp

VIM.command("let signature='#{signature}'")
EOF
    return signature
endfunction

" Check if we can use Tcl for HMAC-SHA1 digests.
function! s:check_tcl_hmac()
    let can_tcl = 1
    tcl <<EOF
if [catch {
    package require sha1
    package require base64
} result] {
    ::vim::command "let can_tcl = 0"
}
EOF
    return can_tcl
endfunction

" Compute HMAC-SHA1 digest. (Tcl version)
function! s:tcl_hmac_sha1_digest(key, str)
    tcl <<EOF
package require sha1
package require base64

set key [::vim::expr a:key]
set str [::vim::expr a:str]

set signature [base64::encode [sha1::hmac -bin $key $str]]

::vim::command "let signature = '$signature'"
EOF
    return signature
endfunction

" Compute HMAC-SHA1 digest by running openssl command line utility.
function! s:openssl_hmac_sha1_digest(key, str)
    if has('win32unix')
        let output = system('openssl dgst -binary -sha1 -hmac "'.a:key.'" | openssl base64', a:str)
        if v:shell_error != 0
            call s:errormsg("Error running openssl command: ".output)
            return ""
        endif
    else
        let output = s:system('openssl dgst -binary -sha1 -hmac "'.a:key.'" | openssl base64', a:str)
        if s:shell_error() != 0
            call s:errormsg("Error running openssl command: ".output)
            return ""
        endif
    endif

    " Remove trailing newlines.
    let output = substitute(output, '\n\+$', '', '')

    return output
endfunction

" Find out which method we can use to compute a HMAC-SHA1 digest.
function! s:get_hmac_method()
    if !exists('s:hmac_method')
        let s:hmac_method = 'openssl'
        if s:get_enable_perl() && has('perl') && s:check_perl_hmac()
            let s:hmac_method = 'perl'
        elseif s:get_enable_python() && has('python') && s:check_python_hmac()
            let s:hmac_method = 'python'
        elseif s:get_enable_python3() && has('python3') && s:check_python3_hmac()
            let s:hmac_method = 'python3'
        elseif s:get_enable_ruby() && has('ruby') && s:check_ruby_hmac()
            let s:hmac_method = 'ruby'
        elseif s:get_enable_tcl() && has('tcl') && s:check_tcl_hmac()
            let s:hmac_method = 'tcl'
        endif
    endif
    return s:hmac_method
endfunction

function! s:hmac_sha1_digest(key, str)
    return s:{s:get_hmac_method()}_hmac_sha1_digest(a:key, a:str)
endfunction

function! twitvim#reset_hmac_method()
    unlet! s:hmac_method
endfunction

function! twitvim#show_hmac_method()
    echo 'Hmac Method:' s:get_hmac_method()
endfunction

" Simple nonce value generator. This needs to be randomized better.
function! s:nonce()
    if !exists("s:nonce_val") || s:nonce_val < 1
        let s:nonce_val = localtime() + 109
    endif

    let retval = s:nonce_val
    let s:nonce_val += 109

    return retval
endfunction

" Produce signed content using the parameters provided via parms using the
" chosen method, url and provided token secret. Note that in the case of
" getting a new Request token, the secret will be ""
function! s:getOauthResponse(url, method, parms, token_secret)
    let parms = copy(a:parms)

    " Add some constants to hash
    let parms["oauth_consumer_key"] = s:get_consumer_key()
    let parms["oauth_signature_method"] = "HMAC-SHA1"
    let parms["oauth_version"] = "1.0"

    " Get the timestamp and add to hash
    let parms["oauth_timestamp"] = localtime()

    let parms["oauth_nonce"] = s:nonce()

    " Alphabetically sort by key and form a string that has
    " the format key1=value1&key2=value2&...
    " Must UTF8 encode and then URL encode the values.
    let content = ""

    for key in sort(keys(parms))
        let value = s:url_encode(parms[key])
        let content .= key . "=" . value . "&"
    endfor
    let content = content[0:-2]

    " Form the signature base string which is comprised of 3
    " pieces, with each piece URL encoded.
    " [METHOD_UPPER_CASE]&[url]&content
    let signature_base_str = a:method . "&" . s:url_encode(a:url) . "&" . s:url_encode(content)
    let hmac_sha1_key = s:url_encode(s:get_consumer_secret()) . "&" . s:url_encode(a:token_secret)
    let signature = s:hmac_sha1_digest(hmac_sha1_key, signature_base_str)
    if signature == ""
        return ""
    endif

    " Add padding character to make a multiple of 4 per the
    " requirement of OAuth.
    if strlen(signature) % 4
        let signature .= "="
    endif

    let content = "OAuth "

    for key in keys(parms)
        if key =~ "oauth"
            let value = s:url_encode(parms[key])
            let content .= key . '="' . value . '", '
        endif
    endfor
    let content .= 'oauth_signature="' . s:url_encode(signature) . '"'
    return content
endfunction

" Perform the OAuth dance to authorize this client with Twitter.
function! s:do_oauth()
    " Call oauth/request_token to get request token from Twitter.

    let parms = { "oauth_callback": "oob", "dummy" : "1" }
    let req_url = s:service_info[s:cur_service]['req_url']
    let oauth_hdr = s:getOauthResponse(req_url, "POST", parms, "")
    if oauth_hdr == ""
        return ["error", ""]
    endif

    let [error, output] = s:run_curl(req_url, oauth_hdr, s:get_proxy(), s:get_proxy_login(), { "dummy" : "1" })
    if !empty(error)
        call s:errormsg("Error from oauth/request_token: ".error)
        return [-1, '', '', '']
    endif

    let request_token = ''
    let matchres = matchlist(output, 'oauth_token=\([^&]\+\)&')
    if matchres != []
        let request_token = matchres[1]
    endif

    let token_secret = ''
    let matchres = matchlist(output, 'oauth_token_secret=\([^&]\+\)&')
    if matchres != []
        let token_secret = matchres[1]
    endif

    if request_token == '' || token_secret == ''
        call s:errormsg("Unable to parse result from oauth/request_token: ".output)
        return [-1, '', '', '']
    endif

    " Launch web browser to let user allow or deny the authentication request.
    let auth_url = s:service_info[s:cur_service]['authorize_url'] . "?oauth_token=" . request_token

    " If user has not set up twitvim_browser_cmd, just display the
    " authentication URL and ask the user to visit that URL.
    if !exists('g:twitvim_browser_cmd') || g:twitvim_browser_cmd == ''

        " Attempt to shorten the auth URL.
        let newurl = s:call_isgd(auth_url)
        if newurl != ""
            let auth_url = newurl
        else
            let newurl = s:call_bitly(auth_url)
            if newurl != ""
                let auth_url = newurl
            endif
        endif

        echo "Visit the following URL in your browser to authenticate TwitVim:"
        echo auth_url
    else
        if s:launch_browser(auth_url) < 0
            return [-2, '', '', '']
        endif
    endif

    call inputsave()
    let pin = input("Enter OAuth PIN: ")
    call inputrestore()

    if pin == ""
        call s:warnmsg("No OAuth PIN entered")
        return [-3, '', '', '']
    endif

    " Call oauth/access_token to swap request token for access token.

    let parms = { "dummy" : 1, "oauth_token" : request_token, "oauth_verifier" : pin }
    let access_url = s:service_info[s:cur_service]['access_url']
    let oauth_hdr = s:getOauthResponse(access_url, "POST", parms, token_secret)
    if oauth_hdr == ""
        return ["error", ""]
    endif

    let [error, output] = s:run_curl(access_url, oauth_hdr, s:get_proxy(), s:get_proxy_login(), { "dummy" : 1 })
    if !empty(error)
        call s:errormsg("Error from oauth/access_token: ".error)
        return [-4, '', '', '']
    endif

    let matchres = matchlist(output, 'oauth_token=\([^&]\+\)')
    if matchres != []
        let request_token = matchres[1]
    endif

    let matchres = matchlist(output, 'oauth_token_secret=\([^&]\+\)')
    if matchres != []
        let token_secret = matchres[1]
    endif

    let screen_name = ''
    let matchres = matchlist(output, 'screen_name=\([^&]\+\)')
    if matchres != []
        let screen_name = matchres[1]
    endif

    return [ 0, request_token, token_secret, screen_name ]
endfunction

" Perform an OAuth login.
function! s:do_login()
    " let keys = [ '' ]
    " let menu = [ 'Pick a service to login to:' ]
    " let i = 0
    " for [key, svc] in items(s:service_info)
    "     let i += 1
    "     call add(keys, key)
    "     call add(menu, printf('%2d. %s', i, svc['dispname']))
    " endfor

    " call inputsave()
    " let input = inputlist(menu)
    " call inputrestore()

    " if input < 1 || input >= len(menu)
    "     return [ -1, 'Login canceled.' ]
    " endif

    " let s:cur_service = keys[input]

    " Only support Twitter for now. Reenable the menu if we ever have more Twitter-like services.
    let s:cur_service = 'twitter'

    let [ retval, s:access_token, s:access_token_secret, s:cached_username ] = s:do_oauth()
    if retval < 0
        return [ -1, "Error from do_oauth(): ".retval ]
    endif

    if s:cached_username == ''
        let s:cached_username = s:get_twitvim_username()
        if s:cached_username == ''
            return [ -1, "Error getting user name when logging in." ]
        endif
    endif

    let tokenrec = {}
    let tokenrec.token = s:access_token
    let tokenrec.secret = s:access_token_secret
    let tokenrec.name = s:cached_username
    let tokenrec.service = s:cur_service
    call s:save_token(tokenrec)
    call s:write_tokens(s:cached_username)

    redraw
    echo "Logged in as ".s:cached_username." on ".s:get_svc_disp_name()."."

    return [ 0, '' ]
endfunction

function! s:run_curl_oauth_get(url, parms)
    return s:run_curl_oauth('GET', a:url, a:parms)
endfunction

function! s:run_curl_oauth_post(url, parms)
    return s:run_curl_oauth('POST', a:url, a:parms)
endfunction


" Sign a request with OAuth and send it.
" In this version of run_curl_oauth, always specify the method: GET or POST.
" Add all parameters to parms, not the url, even in GET calls.
function! s:run_curl_oauth(method, url, parms)

    " The lower-level run_curl() still needs a dummy parameter to use POST.
    if a:method != 'GET' && a:parms == {}
        let a:parms.dummy = 'dummy1'
    endif

    let runurl = a:url
    let runparms = a:parms
    if a:method == 'GET'
        let runparms = {}
        for [key, value] in items(a:parms)
            let runurl = s:add_to_url(runurl, key.'='.s:url_encode(value))
        endfor
    endif

    " Get access tokens from token file or do OAuth login.
    if !exists('s:access_token') || s:access_token == ''
        call s:read_tokens()
        if !exists('s:access_token') || s:access_token == ''
            let [ status, error ] = s:do_login()
            if status < 0
                return [ error, '' ]
            endif
        endif
    endif

    let url = a:url

    let parms = copy(a:parms)
    let parms.oauth_token = s:access_token
    let oauth_hdr = s:getOauthResponse(url, a:method, parms, s:access_token_secret)
    if oauth_hdr == ""
        return ["error", ""]
    endif

    return s:run_curl(runurl, oauth_hdr, s:get_proxy(), s:get_proxy_login(), runparms)
endfunction

" === End of OAuth code ===

" === Networking code ===

function! s:url_encode_char(c)
    let utf = iconv(a:c, &encoding, "utf-8")
    if utf == ""
        let utf = a:c
    endif
    let s = ""
    for i in range(strlen(utf))
        let s .= printf("%%%02X", char2nr(utf[i]))
    endfor
    return s
endfunction

" URL-encode a string.
function! s:url_encode(str)
    return substitute(a:str, '[^a-zA-Z0-9_.~-]', '\=s:url_encode_char(submatch(0))', 'g')
endfunction

" URL-decode a string.
function! s:url_decode(str)
    let s = substitute(a:str, '+', ' ', 'g')
    " let s = substitute(s, '%\([a-zA-Z0-9]\{1,2}\)', '\=nr2char("0x".submatch(1))', 'g')
    let s = substitute(s, '%\(\x\x\)', '\=printf("%c", str2nr(submatch(1), 16))', 'g')
    let encoded = iconv(s, 'utf-8', &encoding)
    if encoded != ''
        let s = encoded
    endif
    return s
endfunction

function! s:quote(v)
    let v = a:v
    return escape(v, '"\\^@<>()')
endfunction

" Use curl to fetch a web page.
function! s:curl_curl(url, login, proxy, proxylogin, parms)
    let error = ""
    let output = ""

    let curlcmd = "curl -s -S --http1.1 "

    if s:get_twitvim_cert_insecure()
        let curlcmd .= "-k "
    endif

    let curlcmd .= '-m '.s:get_net_timeout().' '

    if a:proxy != ""
        " The cURL man page implies that -p only applies to non-HTTP but that
        " seems to be untrue because a bit of experimentation shows that it
        " attempts to tunnel HTTP too. Proxy servers forbid tunneling HTTP so
        " we have to omit -p if the protocol is HTTP.
        if a:url !~? '^http:'
            let curlcmd .= '-p '
        endif
        let curlcmd .= '-x "'.a:proxy.'" '
    endif

    if a:proxylogin != ""
        if stridx(a:proxylogin, ':') != -1
            let curlcmd .= '-U "'.a:proxylogin.'" '
        else
            let curlcmd .= '-H "Proxy-Authorization: Basic '.a:proxylogin.'" '
        endif
    endif

    if a:login != ""
        if a:login =~ "^OAuth "
            let curlcmd .= '-H "'.s:quote('Authorization: '.a:login).'" '
        elseif stridx(a:login, ':') != -1
            let curlcmd .= '-u "'.s:quote(a:login).'" '
        else
            let curlcmd .= '-H "'.s:quote('Authorization: Basic '.a:login).'" '
        endif
    endif

    let got_json = 0
    for [k, v] in items(a:parms)
        if k == '__json'
            let got_json = 1
            let curlcmd .= '-d "'.s:quote(v).'" '
        else
            let curlcmd .= '-d "'.s:url_encode(k).'='.s:url_encode(v).'" '
        endif
    endfor

    if got_json
        let curlcmd .= '-H "Content-Type: application/json" '
    endif

    let curlcmd .= '-H "User-Agent: '.s:quote(s:user_agent).'" '

    let curlcmd .= '"'.s:quote(a:url).'"'

    let output = s:system(curlcmd)
    let errormsg = s:xml_get_element(output, 'error')
    if s:shell_error() != 0
        let error = output
    elseif errormsg != ''
        let error = errormsg
    endif

    return [ error, output ]
endfunction

" Check if we can use Python.
function! s:check_python()
    let can_python = 1
    python <<EOF
import vim
try:
    import urllib
    import urllib2
    import socket
    import base64
    import sys
except:
    vim.command('let can_python = 0')
EOF
    return can_python
endfunction

" Use Python to fetch a web page.
function! s:python_curl(url, login, proxy, proxylogin, parms)
    let error = ""
    let output = ""
    python <<EOF
import urllib
import urllib2
import socket
import base64
import sys
import vim

def make_base64(s):
    if s.find(':') != -1:
        s = base64.b64encode(s)
    return s

net_timeout = None
try:
    t = float(vim.eval("s:get_net_timeout()"))
    if t > 0:
        net_timeout = t
except:
    pass

try:
    socket.setdefaulttimeout(net_timeout)

    url = vim.eval("a:url")
    parms = vim.eval("a:parms")

    if parms.get('__json') is not None:
        req = urllib2.Request(url, parms['__json'])
        req.add_header('Content-Type', 'application/json')
    else:
        req = parms == {} and urllib2.Request(url) or urllib2.Request(url, urllib.urlencode(parms))

    login = vim.eval("a:login")
    if login != "":
        if login[0:6] == "OAuth ":
            req.add_header('Authorization', login)
        else:
            req.add_header('Authorization', 'Basic %s' % make_base64(login))

    proxy = vim.eval("a:proxy")
    if proxy != "":
        urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler({'http': proxy, 'https': proxy})))

    proxylogin = vim.eval("a:proxylogin")
    if proxylogin != "":
        req.add_header('Proxy-Authorization', 'Basic %s' % make_base64(proxylogin))

    req.add_header('User-Agent', vim.eval("s:user_agent"))

    f = urllib2.urlopen(req)
    out = ''.join(f.readlines())
except urllib2.HTTPError, (httperr):
    vim.command("let error='%s'" % str(httperr).replace("'", "''"))
    vim.command("let output='%s'" % httperr.read().replace("'", "''"))
except:
    exctype, value = sys.exc_info()[:2]
    errmsg = (exctype.__name__ + ': ' + str(value)).replace("'", "''")
    vim.command("let error='%s'" % errmsg)
    vim.command("let output='%s'" % errmsg)
else:
    vim.command("let output='%s'" % out.replace("'", "''"))
EOF

    return [ error, output ]
endfunction

" Check if we can use Python 3.
function! s:check_python3()
    let can_python3 = 1
    python3 <<EOF
import vim
try:
    import urllib
    import urllib.request
    import urllib.error
    import urllib.parse
    import socket
    import base64
    import sys
except:
    vim.command('let can_python3 = 0')
EOF
    return can_python3
endfunction

" Use Python 3 to fetch a web page.
function! s:python3_curl(url, login, proxy, proxylogin, parms)
    let error = ""
    let output = ""
    python3 <<EOF
import urllib
import urllib.request
import urllib.error
import urllib.parse
import socket
import base64
import sys
import vim

def make_base64(s):
    if s.find(':') != -1:
        s = bytes.decode(base64.b64encode(str.encode(s)))
    return s

net_timeout = None
try:
    t = float(vim.eval("s:get_net_timeout()"))
    if t > 0:
        net_timeout = t
except:
    pass

try:
    socket.setdefaulttimeout(net_timeout)

    # hello = make_base64("test:hello")

    url = vim.eval("a:url")
    parms = vim.eval("a:parms")

    if parms.get('__json') is not None:
        req = urllib.request.Request(url, str.encode(parms['__json']))
        req.add_header('Content-Type', 'application/json')
    else:
        req = parms == {} and urllib.request.Request(url) or urllib.request.Request(url, str.encode(urllib.parse.urlencode(parms)))

    login = vim.eval("a:login")
    if login != "":
        if login[0:6] == "OAuth ":
            req.add_header('Authorization', login)
        else:
            req.add_header('Authorization', 'Basic %s' % make_base64(login))

    proxy = vim.eval("a:proxy")
    if proxy != "":
        req.set_proxy(proxy, 'http')
        req.set_proxy(proxy, 'https')

    proxylogin = vim.eval("a:proxylogin")
    if proxylogin != "":
        req.add_header('Proxy-Authorization', 'Basic %s' % make_base64(proxylogin))

    req.add_header('User-Agent', vim.eval("s:user_agent"))

    f = urllib.request.urlopen(req)
    out = ''.join([bytes.decode(s) for s in f.readlines()])
except urllib.error.HTTPError as httperr:
    vim.command("let error='%s'" % str(httperr).replace("'", "''"))
    vim.command("let output='%s'" % bytes.decode(httperr.read()).replace("'", "''"))
except:
    exctype, value = sys.exc_info()[:2]
    errmsg = (exctype.__name__ + ': ' + str(value)).replace("'", "''")
    vim.command("let error='%s'" % errmsg)
    vim.command("let output='%s'" % errmsg)
else:
    vim.command("let output='%s'" % out.replace("'", "''"))
EOF

    return [ error, output ]
endfunction

" Check if we can use Perl.
function! s:check_perl()
    let can_perl = 1
    perl <<EOF
eval {
    require MIME::Base64;
    MIME::Base64->import;

    require LWP::UserAgent;
    LWP::UserAgent->import;
};

if ($@) {
    VIM::DoCommand('let can_perl = 0');
}
EOF
    return can_perl
endfunction

" Use Perl to fetch a web page.
function! s:perl_curl(url, login, proxy, proxylogin, parms)
    let error = ""
    let output = ""

    perl <<EOF
require MIME::Base64;
MIME::Base64->import;

require LWP::UserAgent;
LWP::UserAgent->import;

sub make_base64 {
    my $s = shift;
    $s =~ /:/ ? encode_base64($s) : $s;
}

my $ua = LWP::UserAgent->new;

my $timeout = VIM::Eval('s:get_net_timeout()');
$ua->timeout($timeout);

my $url = VIM::Eval('a:url');

my $proxy = VIM::Eval('a:proxy');
$proxy ne '' and $ua->proxy(['http', 'https'], "http://$proxy");

my $proxylogin = VIM::Eval('a:proxylogin');
$proxylogin ne '' and $ua->default_header('Proxy-Authorization' => 'Basic '.make_base64($proxylogin));

my %parms = ();
my $keys = VIM::Eval('keys(a:parms)');
for $k (split(/\n/, $keys)) {
    $parms{$k} = VIM::Eval("a:parms['$k']");
}

my $login = VIM::Eval('a:login');
if ($login ne '') {
    if ($login =~ /^OAuth /) {
        $ua->default_header('Authorization' => $login);
    }
    else {
        $ua->default_header('Authorization' => 'Basic '.make_base64($login));
    }
}

$ua->default_header('User-Agent' => VIM::Eval("s:user_agent"));

if (VIM::Eval('s:get_twitvim_cert_insecure()')) {
    $ua->ssl_opts(verify_hostname => 0);
}

my $response;

if (defined $parms{'__json'}) {
    $response = $ua->post($url,
        'Content-Type' => 'application/json',
        Content => $parms{'__json'});
}
else {
    $response = %parms ? $ua->post($url, \%parms) : $ua->get($url);
}
if ($response->is_success) {
    my $output = $response->content;
    $output =~ s/'/''/g;
    VIM::DoCommand("let output ='$output'");
}
else {
    my $output = $response->content;
    $output =~ s/'/''/g;
    VIM::DoCommand("let output ='$output'");

    my $error = $response->status_line;
    $error =~ s/'/''/g;
    VIM::DoCommand("let error ='$error'");
}
EOF

    return [ error, output ]
endfunction

" Check if we can use Ruby.
"
" Note: Before the networking code will function in Ruby under Windows, you
" need the patch from here:
" http://www.mail-archive.com/vim_dev@googlegroups.com/msg03693.html
"
" and Bram's correction to the patch from here:
" http://www.mail-archive.com/vim_dev@googlegroups.com/msg03713.html
"
function! s:check_ruby()
    let can_ruby = 1
    ruby <<EOF
begin
    require 'net/http'
    require 'net/https'
    require 'uri'
    require 'Base64'
rescue LoadError
    VIM.command('let can_ruby = 0')
end
EOF
    return can_ruby
endfunction

" Use Ruby to fetch a web page.
function! s:ruby_curl(url, login, proxy, proxylogin, parms)
    let error = ""
    let output = ""

    ruby <<EOF
require 'net/http'
require 'net/https'
require 'uri'
require 'Base64'

def make_base64(s)
    s =~ /:/ ? Base64.encode64(s) : s
end

def parse_user_password(s)
    (s =~ /:/ ? s : Base64.decode64(s)).split(':', 2)
end

url = URI.parse(VIM.evaluate('a:url'))
httpargs = [ url.host, url.port ]

proxy = VIM.evaluate('a:proxy')
if proxy != ''
    prox = URI.parse("http://#{proxy}")
    httpargs += [ prox.host, prox.port ]
end

proxylogin = VIM.evaluate('a:proxylogin')
if proxylogin != ''
    httpargs += parse_user_password(proxylogin)
end

net = Net::HTTP.new(*httpargs)

net_timeout = VIM.evaluate('s:get_net_timeout()').to_f
net.open_timeout = net_timeout
net.read_timeout = net_timeout

net.use_ssl = (url.scheme == 'https')

# Disable certificate verification if user sets this variable.
cert_insecure = VIM.evaluate('s:get_twitvim_cert_insecure()')
if cert_insecure != '0'
    net.verify_mode = OpenSSL::SSL::VERIFY_NONE
end

parms = {}
keys = VIM.evaluate('keys(a:parms)')

# Vim patch 7.2.374 adds support to if_ruby for Vim types. So keys() will
# actually return a Ruby array instead of a newline-delimited string.
# So we only need to split the string if VIM.evaluate returns a string.
# If it's already an array, leave it alone.

keys = keys.split(/\n/) if keys.is_a? String

keys.each { |k|
    parms[k] = VIM.evaluate("a:parms['#{k}']")
}

begin
    res = net.start { |http|
        path = "#{url.path}?#{url.query}"
        if parms == {}
            req = Net::HTTP::Get.new(path)
        elsif parms.has_key?('__json')
            req = Net::HTTP::Post.new(path)
            req.body = parms['__json']
            req.set_content_type('application/json')
        else
            req = Net::HTTP::Post.new(path)
            req.set_form_data(parms)
        end

        login = VIM.evaluate('a:login')
        if login != ''
            if login =~ /^OAuth /
                req.add_field 'Authorization', login
            else
                req.add_field 'Authorization', "Basic #{make_base64(login)}"
            end
        end

        req['User-Agent'] = VIM.evaluate("s:user_agent")

        http.request(req)
    }
    case res
    when Net::HTTPSuccess
        output = res.body.gsub("'", "''")
        VIM.command("let output='#{output}'")
    else
        error = "#{res.code} #{res.message}".gsub("'", "''")
        VIM.command("let error='#{error}'")

        output = res.body.gsub("'", "''")
        VIM.command("let output='#{output}'")
    end
rescue Exception => exc
    VIM.command("let error='#{exc.message}'")
end
EOF

    return [error, output]
endfunction

" Check if we can use Tcl.
"
" Note: ActiveTcl 8.5 doesn't include Tcllib in the download. You need to run the following after installing ActiveTcl:
"
"    teacup install tcllib
"
function! s:check_tcl()
    let can_tcl = 1
    tcl <<EOF
if [catch {
    package require http
    package require uri
    package require base64
} result] {
    ::vim::command "let can_tcl = 0"
}
EOF
    return can_tcl
endfunction

" Use Tcl to fetch a web page.
function! s:tcl_curl(url, login, proxy, proxylogin, parms)
    let error = ""
    let output = ""

    tcl << EOF
package require http
package require uri
package require base64

proc make_base64 {s} {
    if { [string first : $s] >= 0 } {
        return [base64::encode $s]
    }
    return $s
}

set url [::vim::expr a:url]

if {[string tolower [string range $url 0 7]] == "https://"} {
    # Load and register support for https URLs.
    package require tls
    ::http::register https 443 ::tls::socket
}

set headers [list]

::http::config -proxyhost ""
set proxy [::vim::expr a:proxy]
if { $proxy != "" } {
    array set prox [uri::split "http://$proxy"]
    ::http::config -proxyhost $prox(host)
    ::http::config -proxyport $prox(port)
}

set proxylogin [::vim::expr a:proxylogin]
if { $proxylogin != "" } {
    lappend headers "Proxy-Authorization" "Basic [make_base64 $proxylogin]"
}

set login [::vim::expr a:login]
if { $login != "" } {
    if {[string range $login 0 5] == "OAuth "} {
        lappend headers "Authorization" $login
    } else {
        lappend headers "Authorization" "Basic [make_base64 $login]"
    }
}

lappend headers "User-Agent" [::vim::expr "s:user_agent"]

set nettimeout [::vim::expr "s:get_net_timeout()"]
set nettimeout [expr {round($nettimeout * 1000.0)}]

set parms [list]
set keys [split [::vim::expr "keys(a:parms)"] "\n"]
if { [llength $keys] > 0 } {
    if { [lsearch -exact $keys "__json"] != -1 } {
        set query [::vim::expr "a:parms\['__json']"]
        lappend headers "Content-Type" "application/json"
    } else {
        foreach key $keys {
            lappend parms $key [::vim::expr "a:parms\['$key']"]
        }
        set query [eval [concat ::http::formatQuery $parms]]
    }
    set res [::http::geturl $url -headers $headers -query $query -timeout $nettimeout]
} else {
    set res [::http::geturl $url -headers $headers -timeout $nettimeout]
}

upvar #0 $res state

if { $state(status) == "ok" } {
    if { [ ::http::ncode $res ] >= 400 } {
        set error $state(http)
        ::vim::command "let error = '$error'"
        set output [string map {' ''} $state(body)]
        ::vim::command "let output = '$output'"
    } else {
        set output [string map {' ''} $state(body)]
        ::vim::command "let output = '$output'"
    }
} else {
    if { [ info exists state(error) ] } {
        set error [string map {' ''} $state(error)]
    } else {
        set error "$state(status) error"
    }
    ::vim::command "let error = '$error'"
}

::http::cleanup $res
EOF

    return [error, output]
endfunction

" Find out which method we can use to fetch a web page.
function! s:get_curl_method()
    if !exists('s:curl_method')
        let s:curl_method = 'curl'
        if s:get_enable_perl() && has('perl') && s:check_perl()
            let s:curl_method = 'perl'
        elseif s:get_enable_python() && has('python') && s:check_python()
            let s:curl_method = 'python'
        elseif s:get_enable_python3() && has('python3') && s:check_python3()
            let s:curl_method = 'python3'
        elseif s:get_enable_ruby() && has('ruby') && s:check_ruby()
            let s:curl_method = 'ruby'
        elseif s:get_enable_tcl() && has('tcl') && s:check_tcl()
            let s:curl_method = 'tcl'
        endif
    endif
    return s:curl_method
endfunction

" We need to convert our parameters to UTF-8. In curl_curl() this is already
" handled as part of our url_encode() function, so we only need to do this for
" other net methods. Also, of course, we don't have to do anything if the
" encoding is already UTF-8.
function! s:iconv_parms(parms)
    if s:get_curl_method() == 'curl' || &encoding == 'utf-8'
        return a:parms
    endif
    let parms2 = {}
    for k in keys(a:parms)
        let v = iconv(a:parms[k], &encoding, 'utf-8')
        if v == ''
            let v = a:parms[k]
        endif
        let parms2[k] = v
    endfor
    return parms2
endfunction

function! s:run_curl(url, login, proxy, proxylogin, parms)
    return s:{s:get_curl_method()}_curl(a:url, a:login, a:proxy, a:proxylogin, s:iconv_parms(a:parms))
endfunction

function! twitvim#reset_curl_method()
    unlet! s:curl_method
endfunction

function! twitvim#show_curl_method()
    echo 'Net Method:' s:get_curl_method()
endfunction

" === End of networking code ===

" === Buffer stack code ===

" Each buffer record holds the following fields:
"
" buftype: Buffer type = dmrecv, dmsent, search, friends, user,
"   replies, list, retweeted_by_me, retweeted_to_me, favorites, trends
" user: For user buffers if other than current user
" list: List slug if displaying a Twitter list.
" page: Keep track of pagination.
" statuses: Tweet IDs. For use by in_reply_to_status_id
" inreplyto: IDs of predecessor messages for @-replies.
" dmids: Direct Message IDs. (for buftype dmrecv or dmsent)
" buffer: The buffer text.
" view: viewport saved with winsaveview()
" showheader: 1 if header is shown in this buffer, 0 if header is hidden.

let s:curbuffer = {}

" The info buffer record holds the following fields:
"
" buftype: profile, friends, followers, listmembers, listsubs, userlists,
"   userlistmem, userlistsubs, listinfo
" next_cursor: Used for paging.
" prev_cursor: Used for paging.
" cursor: Used for refresh.
" user: User name
" list: List name
" buffer: The buffer text.
" view: viewport saved with winsaveview()
" showheader: 1 if header is shown in this buffer, 0 if header is hidden.
"
" flist: List of friends/followers IDs.
" findex: Starting index within flist of the friends/followers info displayed
" in this buffer.

let s:infobuffer = {}

" ptr = Buffer stack pointer. -1 if no items yet. May not point to the end of
" the list if user has gone back one or more buffers.
let s:bufstack = { 'ptr': -1, 'stack': [] }

let s:infobufstack = { 'ptr': -1, 'stack': [] }

" Maximum items in the buffer stack. Adding a new item after this limit will
" get rid of the first item.
let s:bufstackmax = 10


" Add current buffer to the buffer stack at the next position after current.
" Remove all buffers after that.
function! s:add_buffer(infobuf)

    let stack = a:infobuf ? s:infobufstack : s:bufstack
    let cur = a:infobuf ? s:infobuffer : s:curbuffer

    " If stack is already full, remove the buffer at the bottom of the stack to
    " make room.
    if stack.ptr >= s:bufstackmax
        call remove(stack.stack, 0)
        let stack.ptr -= 1
    endif

    let stack.ptr += 1

    " Suppress errors because there may not be anything to remove after current
    " position.
    silent! call remove(stack.stack, stack.ptr, -1)

    call add(stack.stack, cur)
endfunction

" Check if two buffers show the same info based on attributes.
function! s:is_same(infobuf, a, b)
    let a = a:a
    let b = a:b
    if a:infobuf
        if a.buftype == b.buftype && a.cursor == b.cursor && a.user == b.user && a.list == b.list
            return 1
        endif
    else
        if a.buftype == b.buftype && a.list == b.list && a.user == b.user && a.page == b.page
            return 1
        endif
    endif
    return 0
endfunction

" If current buffer is same type as the buffer at the buffer stack pointer then
" just copy it into the buffer stack. Otherwise, add it to buffer stack.
function! s:save_buffer(infobuf)
    let stack = a:infobuf ? s:infobufstack : s:bufstack
    let cur = a:infobuf ? s:infobuffer : s:curbuffer
    let winname = a:infobuf ? s:user_winname : s:twit_winname

    if cur == {}
        return
    endif

    " Save buffer contents and cursor position.
    let twit_bufnr = bufwinnr('^'.winname.'$')
    if twit_bufnr > 0
        let curwin = winnr()
        execute twit_bufnr . "wincmd w"
        let cur.buffer = getline(1, '$')
        let cur.view = winsaveview()
        execute curwin .  "wincmd w"

        " If current buffer is the same type as buffer at the top of the stack,
        " then just copy it.
        if stack.ptr >= 0 && s:is_same(a:infobuf, cur, stack.stack[stack.ptr])
            let stack.stack[stack.ptr] = deepcopy(cur)
        else
            " Otherwise, push the current buffer onto the stack.
            call s:add_buffer(a:infobuf)
        endif
    endif

    " If twit_bufnr returned -1, the user closed the window manually. So we
    " have nothing to save. Do not alter the buffer stack.
endfunction

" Go back one buffer in the buffer stack.
function! s:back_buffer(infobuf)
    let stack = a:infobuf ? s:infobufstack : s:bufstack

    call s:save_buffer(a:infobuf)

    if stack.ptr < 1
        call s:warnmsg("Already at oldest buffer. Can't go back further.")
        return -1
    endif

    let stack.ptr -= 1
    if a:infobuf
        let s:infobuffer = deepcopy(stack.stack[stack.ptr])
    else
        let s:curbuffer = deepcopy(stack.stack[stack.ptr])
    endif
    let cur = a:infobuf ? s:infobuffer : s:curbuffer
    let wintype = a:infobuf ? 'userinfo' : 'timeline'

    call s:twitter_wintext_view(cur.buffer, wintype, cur.view)
    return 0
endfunction

function twitvim#back_buffer(infobuf)
    return s:back_buffer(a:infobuf)
endfunction

" Go forward one buffer in the buffer stack.
function! s:fwd_buffer(infobuf)
    let stack = a:infobuf ? s:infobufstack : s:bufstack

    call s:save_buffer(a:infobuf)

    if stack.ptr + 1 >= len(stack.stack)
        call s:warnmsg("Already at newest buffer. Can't go forward.")
        return -1
    endif

    let stack.ptr += 1
    if a:infobuf
        let s:infobuffer = deepcopy(stack.stack[stack.ptr])
    else
        let s:curbuffer = deepcopy(stack.stack[stack.ptr])
    endif
    let cur = a:infobuf ? s:infobuffer : s:curbuffer
    let wintype = a:infobuf ? 'userinfo' : 'timeline'

    call s:twitter_wintext_view(cur.buffer, wintype, cur.view)
    return 0
endfunction

function twitvim#fwd_buffer(infobuf)
    return s:fwd_buffer(a:infobuf)
endfunction

" For debugging. Show the buffer stack.
function! twitvim#show_bufstack(infobuf)
    let stack = a:infobuf ? s:infobufstack : s:bufstack

    for i in range(len(stack.stack) - 1, 0, -1)
        let s = i.':'
        let s .= ' type='.stack.stack[i].buftype
        let s .= ' user='.stack.stack[i].user
        let s .= ' list='.stack.stack[i].list
        if a:infobuf
            let s .= ' cursor='.stack.stack[i].cursor
        else
            let s .= ' page='.stack.stack[i].page
        endif
        echo s
    endfor
endfunction

" For debugging. Show curbuffer/infobuffer variable.
function! twitvim#show_bufvar(infobuf)
    echo a:infobuf ? s:infobuffer : s:curbuffer
endfunction

" === End of buffer stack code ===

" Add update to Twitter buffer if friends, replies, or user timeline.
function! s:add_update(result)
    if has_key(s:curbuffer, 'buftype') && (s:curbuffer.buftype == "friends" || s:curbuffer.buftype == "user" || s:curbuffer.buftype == "replies" || s:curbuffer.buftype == "list" || s:curbuffer.buftype == "retweeted_by_me" || s:curbuffer.buftype == "retweeted_to_me")

        " Parse the output from the Twitter update call.
        let line = s:format_status_json(a:result)

        " Line number where new tweet will be inserted. It should be 3 if
        " header is shown and 1 if header is hidden.
        let insline = s:curbuffer.showheader ? 3 : 1

        " Add the status ID to the current buffer's statuses list.
        call insert(s:curbuffer.statuses, get(a:result, 'id_str', get(a:result, 'id', '')), insline)

        " Add in-reply-to ID to current buffer's in-reply-to list.
        call insert(s:curbuffer.inreplyto, get(a:result, 'in_reply_to_status_id_str', get(a:result, 'in_reply_to_status_id', '')), insline)

        let twit_bufnr = bufwinnr('^'.s:twit_winname.'$')
        if twit_bufnr > 0
            let curwin = winnr()
            execute twit_bufnr . "wincmd w"
            setlocal modifiable
            call append(insline - 1, line)
            execute "normal! ".insline."G"
            setlocal nomodifiable
            let s:curbuffer.buffer = getline(1, '$')
            execute curwin .  "wincmd w"
        endif
    endif
endfunction

" Count number of characters in a multibyte string. Use technique from
" :help strlen().
function! s:mbstrlen(s)
    return strlen(substitute(a:s, '.', 'x', 'g'))
endfunction

function! s:mbdisplen(s)
    return strdisplaywidth(a:s)
endfunction

let s:short_url_length = 0
let s:short_url_length_https = 0
let s:last_config_query_time = 0

" Get Twitter short URL lengths.
function! s:get_short_url_lengths() abort
    let now = localtime()
    " Do the config query the first time it is needed and once a day thereafter.
    if s:short_url_length == 0 || s:short_url_length_https == 0 || now - s:last_config_query_time > 24 * 60 * 60
        let url = s:get_api_root().'/help/configuration.json'
        let [error, output] = s:run_curl_oauth_get(url, {})
        let result = s:parse_json(output)
        if empty(result)
            return
        endif
        if error == ''
            let s:short_url_length = get(result, 'short_url_length', 0)
            let s:short_url_length_https = get(result, 'short_url_length_https', 0)
            let s:last_config_query_time = now
        endif
    endif
    return [ s:short_url_length, s:short_url_length_https ]
endfunction

" Simulate Twitter's URL shortener by replacing any matching URLs with dummy strings.
function! s:sim_shorten_urls(mesg) abort
    let [url_len, secure_url_len] = s:get_short_url_lengths()
    let mesg = a:mesg
    if url_len > 0 && secure_url_len > 0
        let mesg = substitute(mesg, s:URLMATCH_HTTPS, repeat('*', secure_url_len), 'g')
        let mesg = substitute(mesg, s:URLMATCH_NON_HTTPS, repeat('*', url_len), 'g')
    endif
    return mesg
endfunction

" Common code to post a message to Twitter.
function! s:post_twitter(mesg, inreplyto)
    let parms = {}

    " Add in_reply_to_status_id if status ID is available.
    if a:inreplyto != 0
        let parms["in_reply_to_status_id"] = a:inreplyto
    endif

    let mesg = a:mesg

    " Remove trailing newline. You see that when you visual-select an entire
    " line. Don't let it count towards the tweet length.
    let mesg = substitute(mesg, '\n$', '', "")

    if !s:get_allow_multiline()
      " Convert internal newlines to spaces.
      let mesg = substitute(mesg, '\n', ' ', "g")
    endif

    let mesglen = s:mbstrlen(mesg)
    " Check for zero-length tweets or user cancel at prompt.
    if mesglen < 1
        call s:warnmsg("Your tweet was empty. It was not sent.")
        return
    end

    " Only Twitter has a built-in URL wrapper thus far.
    if s:get_cur_service() == 'twitter'
        " Pretend to shorten URLs.
        let sim_mesg = s:sim_shorten_urls(mesg)
    else
        " Assume that non-Twitter services don't do this URL-shortening
        " madness.
        let sim_mesg = mesg
    endif

    let mesglen = s:mbstrlen(sim_mesg)

    " Check tweet length. Note that the tweet length should be checked before
    " URL-encoding the special characters because URL-encoding increases the
    " string length.
    if mesglen > s:char_limit
        call s:warnmsg("Your tweet has ".(mesglen - s:char_limit)." too many characters. It was not sent.")
    else
        redraw
        echo "Posting update..."

        let url = s:get_api_root()."/statuses/update.json"
        let parms["status"] = mesg
        let parms["source"] = "twitvim"
        let parms["include_entities"] = "true"

        let [error, output] = s:run_curl_oauth_post(url, parms)
        if !empty(error)
            call s:errormsg("Error posting your tweet: ".error)
            return
        endif
        let result = s:parse_json(output)
        if empty(result)
            return
        endif
        if s:has_error(result)
            call s:errormsg("Error posting your tweet: ".s:get_error_message(result))
            return
        endif

        call s:add_update(result)
        redraw
        echo "Your tweet was sent. You used ".mesglen." characters."
    endif
endfunction

function! twitvim#post_twitter(mesg, inreplyto)
    call s:post_twitter(a:mesg, a:inreplyto)
endfunction

" Prompt user for tweet and then post it.
" If initstr is given, use that as the initial input.
function! s:CmdLine_Twitter(initstr, inreplyto)
    call inputsave()
    redraw
    let mesg = input("Tweet: ", a:initstr)
    call inputrestore()
    call s:post_twitter(mesg, a:inreplyto)
endfunction

function! twitvim#CmdLine_Twitter(initstr, inreplyto)
    call s:CmdLine_Twitter(a:initstr, a:inreplyto)
endfunction

" Extract the user name from a line in the timeline.
function! s:get_user_name(line)
    let line = substitute(a:line, '^+ ', '', '')
    let matchres = matchlist(line, '^\(\w\+\):')
    return matchres != [] ? matchres[1] : ""
endfunction

" This is for a local mapping in the timeline. Start an @-reply on the command
" line to the author of the tweet on the current line.
function! s:Quick_Reply()
    let username = s:get_user_name(getline('.'))
    if username != ""
        " If the status ID is not available, get() will return 0 and
        " post_twitter() won't add in_reply_to_status_id to the update.
        call s:CmdLine_Twitter('@'.username.' ', get(s:curbuffer.statuses, line('.')))
    endif
endfunction

" Extract all user names from a line in the timeline. Return the poster's name as well as names from all the @replies.
function! s:get_all_names(line)
    let names = []
    let dictnames = {}

    let username = s:get_user_name(getline('.'))
    if username != ""
        " Add this to the beginning of the list because we want the tweet
        " author to be the main addressee in the reply to all.
        let names = [ username ]
        let dictnames[tolower(username)] = 1
    endif

    let matchcount = 1
    while 1
        let matchres = matchlist(a:line, '@\(\w\+\)', -1, matchcount)
        if matchres == []
            break
        endif
        let name = matchres[1]
        " Don't add duplicate names.
        if !has_key(dictnames, tolower(name))
            call add(names, name)
            let dictnames[tolower(name)] = 1
        endif
        let matchcount += 1
    endwhile

    return names
endfunction

" Reply to everyone mentioned on a line in the timeline.
function! s:Reply_All()
    let names = s:get_all_names(getline('.'))

    " Remove the author from the reply list so that he doesn't end up replying
    " to himself.
    let user = s:get_twitvim_username()
    let replystr = '@'.join(filter(names, 'v:val !=? user'), ' @').' '

    if names != []
        " If the status ID is not available, get() will return 0 and
        " post_twitter() won't add in_reply_to_status_id to the update.
        call s:CmdLine_Twitter(replystr, get(s:curbuffer.statuses, line('.')))
    endif
endfunction

" This is for a local mapping in the timeline. Start a direct message on the
" command line to the author of the tweet on the current line.
function! s:Quick_DM()
    let username = s:get_user_name(getline('.'))
    if username != ""
        " call s:CmdLine_Twitter('d '.username.' ', 0)
        call s:send_dm(username, '')
    endif
endfunction

" Allow user to switch to old-style retweets by setting twitvim_old_retweet.
function! s:get_old_retweet()
    return get(g:, 'twitvim_old_retweet', 0)
endfunction

" Extract the tweet text from a timeline buffer line.
function! s:get_tweet(line)
    let line = substitute(a:line, '^\w\+:\s\+', '', '')
    let line = substitute(line, '\s\+|[^|]\+|$', '', '')

    " Remove newlines.
    let line = substitute(line, "\n", '', 'g')

    return line
endfunction

" Retweet is for replicating a tweet from another user.
function! s:Retweet()
    let line = getline('.')
    let username = s:get_user_name(line)
    if username != ""
        let retweet = substitute(s:get_retweet_fmt(), '%s', '@'.username, '')
        let retweet = substitute(retweet, '%t', '\=s:get_tweet(line)', '')
        " From @mattn_jp: Add in-reply-to status ID to old-style retweet.
        call s:CmdLine_Twitter(retweet, get(s:curbuffer.statuses, line('.')))
    endif
endfunction

" Use new-style retweet API to retweet a tweet from another user.
function! s:Retweet_2()

    " Do an old-style retweet if user has set twitvim_old_retweet.
    if s:get_old_retweet()
        call s:Retweet()
        return
    endif

    let status = get(s:curbuffer.statuses, line('.'))
    if status == 0
        " Fall back to old-style retweeting if we can't get this tweet's status
        " ID.
        call s:Retweet()
        return
    endif

    " Confirm with user before retweeting. Only for new-style retweets because
    " old-style retweets have their own prompt.
    call inputsave()
    let answer = input('Retweet "'.s:strtrunc(getline('.'), 40).'"? (y/n) ')
    call inputrestore()
    if answer != 'y' && answer != 'Y'
        redraw
        echo "Not retweeted."
        return
    endif

    let url = s:get_api_root()."/statuses/retweet/".status.".json"

    redraw
    echo "Retweeting..."

    let [error, output] = s:run_curl_oauth_post(url, {})
    if !empty(error)
        call s:errormsg("Error retweeting: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error retweeting: ".s:get_error_message(result))
        return
    endif

    call s:add_update(result)
    redraw
    echo "Retweeted."
endfunction

" Make quote tweet.
function! s:Quote_Tweet()
    let status = get(s:curbuffer.statuses, line('.'))
    if status == 0
        return
    endif

    let user = substitute(s:curbuffer.buffer[line('.')-1], ':.*', '', '')
    let url = 'http://twitter.com/'.user.'/statuses/'.status

    if has('patch-8.0.1427')
        call timer_start(0, {x-> feedkeys(' ' . url . "\<home>", 'nt') })
        call feedkeys("\<plug>(twitvim-PosttoTwitter)")
    else
        call s:CmdLine_Twitter(url, 0)
    endif
endfunction

" Show which tweet this one is replying to below the current line.
function! s:show_inreplyto()
    let lineno = line('.')

    let inreplyto = get(s:curbuffer.inreplyto, lineno)
    if inreplyto == 0
        call s:warnmsg("No in-reply-to information for current line.")
        return
    endif

    redraw
    echo "Querying for in-reply-to tweet..."

    let url = s:get_api_root()."/statuses/show/".inreplyto.".json"

    let [error, output] = s:run_curl_oauth_get(url, { 'include_entities' : 'true' })
    if !empty(error)
        call s:errormsg("Error getting in-reply-to tweet: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting in-reply-to tweet: ".s:get_error_message(result))
        return
    endif

    let line = s:format_status_json(result)

    " Add the status ID to the current buffer's statuses list.
    call insert(s:curbuffer.statuses, get(result, 'id_str', get(result, 'id', '')), lineno + 1)

    " Add in-reply-to ID to current buffer's in-reply-to list.
    call insert(s:curbuffer.inreplyto, get(result, 'in_reply_to_status_id_str', get(result, 'in_reply_to_status_id', '')), lineno + 1)

    " Already in the correct buffer so no need to search or switch buffers.
    setlocal modifiable
    call append(lineno, '+ '.line)
    setlocal nomodifiable
    let s:curbuffer.buffer = getline(1, '$')

    redraw
    echo "In-reply-to tweet found."
endfunction

" Truncate a string. Add '...' to the end of string was longer than
" the specified number of characters.
function! s:strtrunc(s, len)
    let slen = s:mbstrlen(a:s)
    let s = substitute(a:s, '^\(.\{,'.a:len.'}\).*$', '\1', '')
    if slen > a:len
        let s .= '...'
    endif
    return s
endfunction

" Delete tweet or DM on current line.
function! s:do_delete_tweet()
    let lineno = line('.')

    let isdm = (s:curbuffer.buftype == "dmrecv" || s:curbuffer.buftype == "dmsent")
    let obj = isdm ? "message" : "tweet"
    let uobj = isdm ? "Message" : "Tweet"

    let id = get(isdm ? s:curbuffer.dmids : s:curbuffer.statuses, lineno)

    let url = s:get_api_root().'/'.(isdm ? "direct_messages" : "statuses")."/destroy/".id.".json"

    let [error, output] = s:run_curl_oauth_post(url, {})
    if !empty(error)
        call s:errormsg("Error deleting ".obj.": ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error deleting ".obj.": ".s:get_error_message(result))
        return
    endif

    if isdm
        call remove(s:curbuffer.dmids, lineno)
    else
        call remove(s:curbuffer.statuses, lineno)
        call remove(s:curbuffer.inreplyto, lineno)
    endif

    " Already in the correct buffer so no need to search or switch buffers.
    setlocal modifiable
    normal! dd
    setlocal nomodifiable
    let s:curbuffer.buffer = getline(1, '$')

    redraw
    echo uobj "deleted."
endfunction

" Delete tweet or DM on current line.
function! s:delete_tweet()
    let lineno = line('.')

    let isdm = (s:curbuffer.buftype == "dmrecv" || s:curbuffer.buftype == "dmsent")
    let obj = isdm ? "message" : "tweet"
    let uobj = isdm ? "Message" : "Tweet"

    let id = get(isdm ? s:curbuffer.dmids : s:curbuffer.statuses, lineno)
    if id == 0
        call s:warnmsg("No erasable ".obj." on current line.")
        return
    endif

    call inputsave()
    let answer = input('Delete "'.s:strtrunc(getline('.'), 40).'"? (y/n) ')
    call inputrestore()
    if answer == 'y' || answer == 'Y'
        call s:do_delete_tweet()
    else
        redraw
        echo uobj "not deleted."
    endif
endfunction

" Fave or Unfave tweet on current line.
function! s:fave_tweet(unfave)
    let id = get(s:curbuffer.statuses, line('.'))
    if id == 0
        call s:warnmsg('Nothing to '.(a:unfave ? 'unfavorite' : 'favorite').' on current line.')
        return
    endif

    redraw
    echo (a:unfave ? 'Unfavoriting' : 'Favoriting') 'the tweet...'

    if s:get_cur_service() == 'twitter'
        let url = s:get_api_root().'/favorites/'.(a:unfave ? 'destroy' : 'create').'.json'
    else
        let url = s:get_api_root().'/favorites/'.(a:unfave ? 'destroy' : 'create').'/'.id.'.json'
    endif

    let [error, output] = s:run_curl_oauth_post(url, { 'id' : id })
    if !empty(error)
        call s:errormsg("Error ".(a:unfave ? 'unfavoriting' : 'favoriting')." the tweet: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error ".(a:unfave ? 'unfavoriting' : 'favoriting')." the tweet: ".s:get_error_message(result))
        return
    endif

    redraw
    echo 'Tweet' (a:unfave ? 'unfavorited.' : 'favorited.')
endfunction

" Launch web browser with the given URL.
function! s:launch_browser(url)
    if !exists('g:twitvim_browser_cmd') || g:twitvim_browser_cmd == ''
        " Beep and error-highlight
        execute "normal! \<Esc>"
        call s:errormsg('Browser cmd not set. Please add to .vimrc: let twitvim_browser_cmd="browsercmd"')
        return -1
    endif

    let startcmd = has("win32") || has("win64") ? "!start " : "! "

    " Discard unnecessary output from UNIX browsers. So far, this is known to
    " happen only in the Linux version of Google Chrome when it opens a tab in
    " an existing browser window.
    " Firefox appears to output to stderr as well, so the '2>&1' redirect is
    " needed.
    let endcmd = has('unix') ? '> /dev/null 2>&1 &' : ''

    " Escape characters that have special meaning in the :! command.
    let url = substitute(a:url, '!\|#\|%', '\\&', 'g')

    " shellescape() surrounds the URL with single quotes. We need this so that
    " certain characters won't be treated by the shell as meta-characters.
    " In URLs, the following characters are common:
    " - '&': This character separates fields in a URL query string. However, it
    "   causes the shell to background the process and cut off the URL at that
    "   point.
    " - '?': This character separates the query string from the path in a URL.
    "   However, it is also a shell glob character. sh, bash, ksh will pass on
    "   this character if there is no match in the filesystem. However, zsh
    "   will complain that it found no matches and it won't run the command.
    if has('unix')
        let url = shellescape(url)
    endif

    redraw
    echo "Launching web browser..."
    let v:errmsg = ""
    silent! execute startcmd g:twitvim_browser_cmd url endcmd
    if v:errmsg == ""
        redraw!
        echo "Web browser launched."
    else
        call s:errormsg('Error launching browser: '.v:errmsg)
        return -2
    endif

    return 0
endfunction


let s:URL_PROTOCOL = '\%([Hh][Tt][Tt][Pp]\|[Hh][Tt][Tt][Pp][Ss]\|[Ff][Tt][Pp]\)://'
let s:URL_PROTOCOL_HTTPS = '\%([Hh][Tt][Tt][Pp][Ss]\)://'
let s:URL_PROTOCOL_NON_HTTPS = '\%([Hh][Tt][Tt][Pp]\|[Ff][Tt][Pp]\)://'

" s:URL_DOMAIN_CHARS is s:URL_PATH_CHARS without /
let s:URL_DOMAIN_CHARS = '[a-zA-Z0-9!$&''()*+,.:;=?@_~%#-]'
" s:URL_DOMAIN_END_CHARS is s:URL_PATH_END_CHARS without /
let s:URL_DOMAIN_END_CHARS = '[a-zA-Z0-9!$&''*+=?@_~%#-]'
let s:URL_DOMAIN_PARENS = '('.s:URL_DOMAIN_CHARS.'*)'
let s:URL_DOMAIN = '\%('.'\%('.s:URL_DOMAIN_CHARS.'*'.s:URL_DOMAIN_PARENS.'\)'.'\|'.'\%('.s:URL_DOMAIN_CHARS.'*'.s:URL_DOMAIN_END_CHARS.'\)'.'\)'

let s:URL_PATH_CHARS = '[a-zA-Z0-9!$&''()*+,./:;=?@_~%#-]'
let s:URL_PARENS = '('.s:URL_PATH_CHARS.'*)'

" Avoid swallowing up certain punctuation characters after a URL but allow a
" URL to end with a balanced parenthesis.
" So s:URL_PATH_END_CHARS is s:URL_PATH_CHARS without .,:;()
let s:URL_PATH_END_CHARS = '[a-zA-Z0-9!$&''*+/=?@_~%#-]'

let s:URL_PATH = '\%('.'\%('.s:URL_PATH_CHARS.'*'.s:URL_PARENS.'\)'.'\|'.'\%('.s:URL_PATH_CHARS.'*'.s:URL_PATH_END_CHARS.'\)'.'\)'

" Bring it all together. Use this regex to match a URL.
let s:URLMATCH = s:URL_PROTOCOL.s:URL_DOMAIN.'\%(/'.s:URL_PATH.'\=\)\='
let s:URLMATCH_HTTPS = s:URL_PROTOCOL_HTTPS.s:URL_DOMAIN.'\%(/'.s:URL_PATH.'\=\)\='
let s:URLMATCH_NON_HTTPS = s:URL_PROTOCOL_NON_HTTPS.s:URL_DOMAIN.'\%(/'.s:URL_PATH.'\=\)\='


" Launch web browser with the URL at the cursor position. If possible, this
" function will try to recognize a URL within the current word. Otherwise,
" it'll just use the whole word.
" If the cWORD happens to be @user or user:, show that user's timeline.
function! s:launch_url_cword(infobuf)
    let s = expand("<cWORD>")

    " Handle @-replies by showing that user's timeline.
    " An @-reply must be preceded by a non-word character and ends at a
    " non-word character.
    let matchres = matchlist(s, '\w\@<!@\(\w\+\)')
    if matchres != []
        call s:get_timeline("user", matchres[1], 1, 0)
        return
    endif

    if a:infobuf
        " Don't match ^word: if in profile buffer. It leads to all kinds of
        " false matches. Instead, parse a Name: line specially.
        let name = s:info_getname()
        if name != ''
            call s:get_timeline("user", name, 1, 0)
            return
        endif

        " Parse a Website: line specially.
        let matchres = matchlist(getline('.'), '^Website: \('.s:URLMATCH.'\)')
        if matchres != []
            call s:launch_browser(matchres[1])
            return
        endif

        " Don't do anything on field labels in profile buffer.
        " Otherwise, the code below will needlessly launch a web browser.
        let matchres = matchlist(s, '^\(\w\+\):$')
        if matchres != []
            return
        endif
    else
        " In a trending topics list, the whole line is a search term.
        if s:curbuffer.buftype == 'trends'
            if !s:curbuffer.showheader || line('.') > 2
                call s:get_summize(getline('.'), 1, 0)
            endif
            return
        endif

        if col('.') == 1 && s == '+'
            " If the cursor is on the '+' in a reply expansion, use the second
            " word instead.
            let matchres = matchlist(getline('.'), '^+ \(\w\+\):')
            if matchres != []
                call s:get_timeline("user", matchres[1], 1, 0)
                return
            endif
        endif

        " Handle username: at the beginning of the line by showing that user's
        " timeline.
        let matchres = matchlist(s, '^\(\w\+\):$')
        if matchres != []
            call s:get_timeline("user", matchres[1], 1, 0)
            return
        endif
    endif

    " Handle #-hashtags by showing the Twitter Search for that hashtag.
    " A #-hashtag must be preceded by a non-word character and ends at a
    " non-word character or punctuation, blank.
    let matchres = matchlist(s, '\w\@<!\(#[^[:blank:][\x21-\x2f\x3a-\x40\x5b-\x5e\x60\x7b\x7d\u3000\u3001]\+\)')
    if matchres != []
        call s:get_summize(matchres[1], 1, 0)
        return
    endif

    " $-stocksymbols are like $-hashtags but only alphabetic.
    let matchres = matchlist(s, '\w\@<!\(\$\a\+\)')
    if matchres != []
        call s:get_summize(matchres[1], 1, 0)
        return
    endif

    let s = substitute(s, '^.\{-}\('.s:URLMATCH.'\).\{-}$', '\1', "")
    call s:launch_browser(s)
endfunction

" Extract name from current line in info buffer, if possible.
function! s:info_getname()
    let matchres = matchlist(getline('.'), '^Name: \(\w\+\)')
    if matchres != []
        return matchres[1]
    else
        return ''
    endif
endfunction

" Call LongURL API on a shorturl to expand it.
function! s:call_longurl(url)
    redraw
    echo "Sending request to LongURL..."

    let url = 'http://api.longurl.org/v1/expand?url='.s:url_encode(a:url)
    let [error, output] = s:run_curl(url, '', s:get_proxy(), s:get_proxy_login(), {})
    if !empty(error)
        call s:errormsg("Error calling LongURL API: ".error)
        return ""
    endif
    redraw
    echo "Received response from LongURL."

    let longurl = s:xml_get_element(output, 'long_url')
    if longurl != ""
        let longurl = substitute(longurl, '<!\[CDATA\[\(.*\)]]>', '\1', '')
        return longurl
    endif

    let errormsg = s:xml_get_element(output, 'error')
    if errormsg != ""
        call s:errormsg("LongURL error: ".errormsg)
        return ""
    endif

    call s:errormsg("Unknown response from LongURL: ".output)
    return ""
endfunction

" Call LongURL API on the given string. If no string is provided, use the
" current word. In the latter case, this function will try to recognize a URL
" within the word. Otherwise, it'll just use the whole word.
function! s:do_longurl(s)
    let s = a:s
    if s == ""
        let s = substitute(expand("<cWORD>"), '.*\<\('.s:URLMATCH.'\)', '\1', "")
    endif
    let result = s:call_longurl(s)
    if result != ""
        redraw
        echo s.' expands to '.result
    endif
endfunction


" Just like do_user_info() but handle Name: lines in info buffer specially.
function! s:do_user_info_infobuf()
    let name = s:info_getname()
    if name != ''
        call s:get_user_info(name)
        return
    endif

    " Fall back to original user info function.
    call s:do_user_info('')
endfunction

" Get info on the given user. If no user is provided, use the current word and
" strip off the @ or : if the current word is @user or user:.
function! s:do_user_info(s)
    let s = a:s
    if s == ''
        let s = expand("<cword>")

        " Handle @-replies.
        let matchres = matchlist(s, '^@\(\w\+\)')
        if matchres != []
            let s = matchres[1]
        else
            " Handle username: at the beginning of the line.
            let matchres = matchlist(s, '^\(\w\+\):$')
            if matchres != []
                let s = matchres[1]
            endif
        endif
    endif

    call s:get_user_info(s)
endfunction

" nr2byte() and nr2enc_char() converter functions for non-UTF8 encoding
" provided by @mattn_jp

" Get bytes from character code.
function! s:nr2byte(nr)
    if a:nr < 0x80
        return nr2char(a:nr)
    elseif a:nr < 0x800
        return nr2char(a:nr/64+192).nr2char(a:nr%64+128)
    else
        return nr2char(a:nr/4096%16+224).nr2char(a:nr/64%64+128).nr2char(a:nr%64+128)
    endif
endfunction

" Convert character code from utf-8 to encoding.
function! s:nr2enc_char(charcode)
    if &encoding == 'utf-8'
        return nr2char(a:charcode)
    endif
    let char = s:nr2byte(a:charcode)
    if strlen(char) > 1
        let iconv_str = iconv(char, 'utf-8', &encoding)
        if iconv_str != ""
            let char = strtrans(iconv_str)
        endif
    endif
    return char
endfunction


" Decode HTML entities. Twitter gives those to us a little weird. For example,
" a '<' character comes to us as &amp;lt;
function! s:convert_entity(str)
    let s = a:str
    let s = substitute(s, '&amp;', '\&', 'g')
    let s = substitute(s, '&lt;', '<', 'g')
    let s = substitute(s, '&gt;', '>', 'g')
    let s = substitute(s, '&quot;', '"', 'g')
    let s = substitute(s, '&apos;', "'", 'g')
    let s = substitute(s, '&#\(\d\+\);','\=s:nr2enc_char(submatch(1))', 'g')
    let s = substitute(s, '&#x\(\x\+\);','\=s:nr2enc_char("0x".submatch(1))', 'g')
    let s = substitute(s, '&amp;', '\&', 'g')
    return s
endfunction

let s:twit_winname = "Twitter_".localtime()

" Set syntax highlighting in timeline window.
function! s:twitter_win_syntax(wintype)
    " Beautify the Twitter window with syntax highlighting.
    if has("syntax") && exists("g:syntax_on")
        " Reset syntax items in case there are any predefined in the new buffer.
        syntax clear

        " Twitter user name: from start of line to first colon.
        syntax match twitterUser /^.\{-1,}:/

        " Use the bars to recognize the time but hide the bars.
        syntax match twitterTime /|[^|]\+|$/ contains=twitterTimeBar
        syntax match twitterTimeBar /|/ contained

        " Highlight links in tweets.
        execute 'syntax match twitterLink "\<'.s:URLMATCH.'"'

        " An @-reply must be preceded by a non-word character and ends at a
        " non-word character.
        syntax match twitterReply "\w\@<!@\w\+"

        " A #-hashtag must be preceded by a non-word character and ends at a
        " non-word character or punctuation, blank.
        syntax match twitterLink "\w\@<!#[^[:blank:][\x21-\x2f\x3a-\x40\x5b-\x5e\x60\x7b\x7d\u3000\u3001]\+"

        " $-stocksymbols are like $-hashtags but only alphabetic.
        syntax match twitterLink "\w\@<!$\a\+"

        " Use the extra star at the end to recognize the title but hide the
        " star.
        syntax match twitterTitle /^\%(\w\+:\)\@!.\+\*$/ contains=twitterTitleStar
        syntax match twitterTitleStar /\*$/ contained

        highlight default link twitterUser Identifier
        highlight default link twitterTime String
        highlight default link twitterTimeBar Ignore
        highlight default link twitterTitle Title
        highlight default link twitterTitleStar Ignore
        highlight default link twitterLink Underlined
        highlight default link twitterReply Label
    endif
endfunction

" Switch to the Twitter window if there is already one or open a new window for
" Twitter.
" Returns 1 if new window created, 0 otherwise.
function! s:twitter_win(wintype)
    let winname = a:wintype == "userinfo" ? s:user_winname : s:twit_winname
    let newwin = 0

    let twit_bufnr = bufwinnr('^'.winname.'$')
    if twit_bufnr > 0
        execute twit_bufnr . "wincmd w"
    else
        let newwin = 1
        silent execute "new " . winname
        setlocal noswapfile
        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal foldcolumn=0
        setlocal nobuflisted
        setlocal nospell
        setlocal nowrap

        " Launch browser with URL in visual selection or at cursor position.
        nnoremap <buffer> <silent> <A-g> :call <SID>launch_url_cword(0)<cr>
        nnoremap <buffer> <silent> <Leader>g :call <SID>launch_url_cword(0)<cr>
        vnoremap <buffer> <silent> <A-g> y:call <SID>launch_browser(@")<cr>
        vnoremap <buffer> <silent> <Leader>g y:call <SID>launch_browser(@")<cr>

        " Get user info for current word or selection.
        nnoremap <buffer> <silent> <Leader>p :call <SID>do_user_info("")<cr>
        vnoremap <buffer> <silent> <Leader>p y:call <SID>do_user_info(@")<cr>

        " Call LongURL API on current word or selection.
        nnoremap <buffer> <silent> <Leader>e :call <SID>do_longurl("")<cr>
        vnoremap <buffer> <silent> <Leader>e y:call <SID>do_longurl(@")<cr>

        if a:wintype == "userinfo"
            " Next page in info buffer.
            nnoremap <buffer> <silent> <C-PageDown> :call <SID>NextPageInfo()<cr>

            " Previous page in info buffer.
            nnoremap <buffer> <silent> <C-PageUp> :call <SID>PrevPageInfo()<cr>

            " Refresh info buffer.
            nnoremap <buffer> <silent> <Leader><Leader> :call <SID>RefreshInfo()<cr>

            " We need this to be handled specially in the info buffer.
            nnoremap <buffer> <silent> <A-g> :call <SID>launch_url_cword(1)<cr>
            nnoremap <buffer> <silent> <Leader>g :call <SID>launch_url_cword(1)<cr>

            " This also needs to be handled specially for Name: lines.
            nnoremap <buffer> <silent> <Leader>p :call <SID>do_user_info_infobuf()<cr>

            " Go back and forth through buffer stack.
            nnoremap <buffer> <silent> <C-o> :call <SID>back_buffer(1)<cr>
            nnoremap <buffer> <silent> <C-i> :call <SID>fwd_buffer(1)<cr>
        else
            " Quick reply feature for replying from the timeline.
            nnoremap <buffer> <silent> <A-r> :call <SID>Quick_Reply()<cr>
            nnoremap <buffer> <silent> <Leader>r :call <SID>Quick_Reply()<cr>

            " Quick DM feature for direct messaging from the timeline.
            nnoremap <buffer> <silent> <A-d> :call <SID>Quick_DM()<cr>
            nnoremap <buffer> <silent> <Leader>d :call <SID>Quick_DM()<cr>

            " Retweet feature for replicating another user's tweet.
            nnoremap <buffer> <silent> <Leader>R :call <SID>Retweet_2()<cr>

            " Retweet feature for replicating another user's tweet.
            nnoremap <buffer> <silent> <Leader>q :call <SID>Quote_Tweet()<cr>

            " Reply to all feature.
            nnoremap <buffer> <silent> <Leader><C-r> :call <SID>Reply_All()<cr>

            " Show in-reply-to for current tweet.
            nnoremap <buffer> <silent> <Leader>@ :call <SID>show_inreplyto()<cr>

            " Delete tweet or message on current line.
            nnoremap <buffer> <silent> <Leader>X :call <SID>delete_tweet()<cr>

            " Refresh timeline.
            nnoremap <buffer> <silent> <Leader><Leader> :call <SID>RefreshTimeline()<cr>

            " Next page in timeline.
            nnoremap <buffer> <silent> <C-PageDown> :call <SID>NextPageTimeline()<cr>

            " Previous page in timeline.
            nnoremap <buffer> <silent> <C-PageUp> :call <SID>PrevPageTimeline()<cr>

            " Favorite a tweet.
            nnoremap <buffer> <silent> <Leader>f :call <SID>fave_tweet(0)<cr>
            " Unfavorite a tweet.
            nnoremap <buffer> <silent> <Leader><C-f> :call <SID>fave_tweet(1)<cr>

            " Go back and forth through buffer stack.
            nnoremap <buffer> <silent> <C-o> :call <SID>back_buffer(0)<cr>
            nnoremap <buffer> <silent> <C-i> :call <SID>fwd_buffer(0)<cr>
        endif
    endif

    setlocal filetype=twitvim
    call s:twitter_win_syntax(a:wintype)
    return newwin
endfunction

" Get a Twitter window and stuff text into it. If view is not an empty
" dictionary then restore the cursor position to the saved view.
function! s:twitter_wintext_view(text, wintype, view)
    let curwin = winnr()
    let newwin = s:twitter_win(a:wintype)

    setlocal modifiable

    " Overwrite the entire buffer.
    " Need to use 'silent' or a 'No lines in buffer' message will appear.
    " Delete to the blackhole register "_ so that we don't affect registers.
    silent %delete _
    call setline('.', a:text)
    normal! 1G

    setlocal nomodifiable

    " Restore the saved view if provided.
    if a:view != {}
        call winrestview(a:view)
    endif

    " Go back to original window after updating buffer. If a new window is
    " created then our saved curwin number is wrong so the best we can do is to
    " take the user back to the last-accessed window using 'wincmd p'.
    if newwin
        wincmd p
    else
        execute curwin .  "wincmd w"
    endif
endfunction

" Get a Twitter window and stuff text into it.
function! s:twitter_wintext(text, wintype)
    call s:twitter_wintext_view(a:text, a:wintype, {})
endfunction

" Format a retweeted status, if available.
function! s:format_retweeted_status_json(item)
    let rt = get(a:item, 'retweeted_status', {})
    if rt == {}
        return ''
    endif
    let user = get(get(rt, 'user', {}), 'screen_name', '')
    let text = s:convert_entity(s:get_status_text_json(rt))
    return 'RT @'.user.': '.text
endfunction

" Replace all matching strings in a string. This is a non-regex version of substitute().
function! s:str_replace_all(str, findstr, replstr)
    let findlen = strlen(a:findstr)
    let repllen = strlen(a:replstr)
    let s = a:str

    let idx = 0
    while 1
        let idx = stridx(s, a:findstr, idx)
        if idx < 0
            break
        endif
        let s = strpart(s, 0, idx) . a:replstr . strpart(s, idx + findlen)
        let idx += repllen
    endwhile

    return s
endfunction

" Format JSON status as a display line.
function! s:format_status_json(item)
    let item = a:item

    let user = get(get(item, 'user', {}), 'screen_name', '')
    let text = s:format_retweeted_status_json(item)
    if text == ''
        let text = s:convert_entity(s:get_status_text_json(item))
    endif
    let pubdate = s:time_filter(get(item, 'created_at', ''))

    return user.': '.text.' |'.pubdate.'|'
endfunction

" Get in-reply-to from a status element. If this is a retweet, use the id of
" the retweeted status as the in-reply-to.
function! s:get_in_reply_to_json(status)
    let rt = get(a:status, 'retweeted_status', {})
    return get(rt, 'id_str', get(rt, 'id', get(a:status, 'in_reply_to_status_id_str', get(a:status, 'in_reply_to_status_id', ''))))
endfunction

" If the filter is enabled, test the current item against the filter. Returns
" true if there is a match and the item should be excluded from the timeline.
function! s:check_filter_json(item)
    if s:get_filter_enable()
        let filter = s:get_filter_regex()
        if filter != ''
            let text = s:convert_entity(s:get_status_text_json(a:item))
            if match(text, filter) >= 0
                return 1
            endif
        endif
    endif
    return 0
endfunction

" Show a timeline from JSON stream data.
function! s:show_timeline_json(timeline, tline_name, username, page)
    let text = []

    let s:curbuffer.dmids = []

    " Construct page title.

    let title = substitute(a:tline_name, '^.', '\u&', '')." timeline"
    if a:username != ''
        let title .= " for ".a:username
    endif

    " Special case titles for Retweets and Mentions.
    if a:tline_name == "retweeted_to_me"
        let title = "Retweets by others"
    elseif a:tline_name == "retweeted_by_me"
        let title = "Retweets by you"
    elseif a:tline_name == "replies"
        let title = "Mentions timeline"
    endif

    if a:page > 1
        let title .= ' (page '.a:page.')'
    endif

    let s:curbuffer.showheader = s:get_show_header()
    if s:curbuffer.showheader
        " Index of first status will be 3 to match line numbers in timeline
        " display.
        let s:curbuffer.statuses = [0, 0, 0]
        let s:curbuffer.inreplyto = [0, 0, 0]

        " The extra stars at the end are for the syntax highlighter to
        " recognize the title. Then the syntax highlighter hides the stars by
        " coloring them the same as the background. It is a bad hack.
        call add(text, title.'*')
        call add(text, repeat('=', s:mbdisplen(title)).'*')
    else
        " Index of first status will be 1 to match line numbers in timeline
        " display.
        let s:curbuffer.statuses = [0]
        let s:curbuffer.inreplyto = [0]
    endif

    for item in a:timeline
        if !s:check_filter_json(item)
            call add(s:curbuffer.statuses, get(item, 'id_str', get(item, 'id', '')))
            call add(s:curbuffer.inreplyto, s:get_in_reply_to_json(item))

            let line = s:format_status_json(item)
            call add(text, line)
        endif
    endfor

    call s:twitter_wintext(text, "timeline")
    let s:curbuffer.buffer = text
endfunction

" Add a parameter to a URL.
function! s:add_to_url(url, parm)
    return a:url . (a:url =~ '?' ? '&' : '?') . a:parm
endfunction

" Generic timeline retrieval function.
function! s:get_timeline(tline_name, username, page, max_id)

    let url_fname = (a:tline_name == "retweeted_to_me" || a:tline_name == "retweeted_by_me") ? a:tline_name.".json" : a:tline_name == "friends" ? "home_timeline.json" : a:tline_name == "replies" ? "mentions_timeline.json" : a:tline_name == "favorites" ? "favorites/list.json" : a:tline_name."_timeline.json"

    let parms = {}

    " Support max_id parameter.
    if a:max_id != 0
        let parms.max_id = a:max_id
    endif

    " Include retweets.
    let parms.include_rts = 'true'

    " Include entities to get URL expansions for t.co.
    let parms.include_entities = 'true'

    " Twitter API allows you to specify a username for user_timeline to
    " retrieve another user's timeline.
    if a:username != ''
        let parms.screen_name = a:username
    endif

    " Support count parameter in favorites, friends, user, mentions, and retweet timelines.
    if a:tline_name == 'favorites' || a:tline_name == 'friends' || a:tline_name == 'user' || a:tline_name == 'replies' || a:tline_name == 'retweeted_to_me' || a:tline_name == 'retweeted_by_me'
        let tcount = s:get_count()
        if tcount > 0
            let parms.count = tcount
        endif
    endif

    let tl_name = a:tline_name == "replies" ? "mentions" : a:tline_name

    redraw
    echo "Sending" tl_name "timeline request..."

    let url = s:get_api_root().(a:tline_name == 'favorites' ? '/' : "/statuses/").url_fname

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg("Error getting ".tl_name." timeline: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting ".tl_name." timeline: ".s:get_error_message(result))
        return
    endif

    call s:save_buffer(0)
    let s:curbuffer = {}
    call s:show_timeline_json(result, a:tline_name, a:username, a:page)
    let s:curbuffer.buftype = a:tline_name
    let s:curbuffer.user = a:username
    let s:curbuffer.list = ''
    let s:curbuffer.page = a:page
    redraw
    call s:save_buffer(0)

    let foruser = a:username == '' ? '' : ' for user '.a:username

    " Uppercase the first letter in the timeline name.
    echo substitute(tl_name, '^.', '\u&', '') "timeline updated".foruser."."
endfunction

function! twitvim#get_timeline(tline_name, username, page, max_id)
    call s:get_timeline(a:tline_name, a:username, a:page, a:max_id)
endfunction

" Retrieve a Twitter list timeline.
function! s:get_list_timeline(username, listname, page, max_id)

    let user = a:username
    if user == ''
        let user = s:get_twitvim_username()
        if user == ''
            call s:errormsg('Login not set. Please specify a username.')
            return -1
        endif
    endif

    let url = s:get_api_root().'/lists/statuses.json'

    let parms = {}
    let parms.slug = a:listname
    let parms.owner_screen_name = user

    " Support max_id parameter.
    if a:max_id != 0
        let parms.max_id = a:max_id
    endif

    " Support count parameter.
    let tcount = s:get_count()
    if tcount > 0
        let parms.per_page = tcount
        let parms.count = tcount
    endif

    " Include entities to get URL expansions for t.co.
    let parms.include_entities = 'true'

    " Include retweets.
    let parms.include_rts = 'true'

    redraw
    echo "Sending list timeline request..."

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg("Error getting list timeline: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting list timeline: ".s:get_error_message(result))
        return
    endif

    call s:save_buffer(0)
    let s:curbuffer = {}
    call s:show_timeline_json(result, "list", user."/".a:listname, a:page)
    let s:curbuffer.buftype = "list"
    let s:curbuffer.user = user
    let s:curbuffer.list = a:listname
    let s:curbuffer.page = a:page
    redraw
    call s:save_buffer(0)

    echo "List timeline updated for ".user."/".a:listname
endfunction

" Show direct message sent or received by user. First argument should be 'sent'
" or 'received' depending on which timeline we are displaying.
function! s:show_dm_json(sent_or_recv, timeline, page)
    let text = []

    "No status IDs in direct messages.
    let s:curbuffer.statuses = []
    let s:curbuffer.inreplyto = []

    let title = 'Direct messages '.a:sent_or_recv

    if a:page > 1
        let title .= ' (page '.a:page.')'
    endif

    let s:curbuffer.showheader = s:get_show_header()
    if s:curbuffer.showheader
        " Index of first dmid will be 3 to match line numbers in timeline
        " display.
        let s:curbuffer.dmids = [0, 0, 0]

        " The extra stars at the end are for the syntax highlighter to
        " recognize the title. Then the syntax highlighter hides the stars by
        " coloring them the same as the background. It is a bad hack.
        call add(text, title.'*')
        call add(text, repeat('=', s:mbdisplen(title)).'*')
    else
        " Index of first dmid will be 1 to match line numbers in timeline
        " display.
        let s:curbuffer.dmids = [0]
    endif

    for item in a:timeline
        call add(s:curbuffer.dmids, get(item, 'id_str', get(item, 'id', '')))

        let user = get(item, a:sent_or_recv == 'sent' ? 'recipient_screen_name' : 'sender_screen_name', '')
        let mesg = s:get_status_text_json(item)
        let date = s:time_filter(get(item, 'created_at', ''))

        call add(text, user.": ".s:convert_entity(mesg).' |'.date.'|')
    endfor

    call s:twitter_wintext(text, "timeline")
    let s:curbuffer.buffer = text
endfunction

" Get direct messages sent to or received by user.
function! s:Direct_Messages(mode, page, max_id)
    let sent = (a:mode == "dmsent")
    let s_or_r = (sent ? "sent" : "received")

    redraw
    echo "Sending direct messages ".s_or_r." timeline request..."

    let url = s:get_api_root()."/direct_messages".(sent ? "/sent" : "").".json"

    let parms = {}

    " Support max_id parameter.
    if a:max_id != 0
        let parms.max_id = a:max_id
    endif

    " Include entities to get URL expansions for t.co.
    let parms.include_entities = 'true'

    " Get long DMs.
    let parms.full_text = 'true'

    " Support count parameter.
    let tcount = s:get_count()
    if tcount > 0
        let parms.count = tcount
    endif

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg("Error getting direct messages ".s_or_r." timeline: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting direct messages ".s_or_r." timeline: ".s:get_error_message(result))
        return
    endif

    call s:save_buffer(0)
    let s:curbuffer = {}
    call s:show_dm_json(s_or_r, result, a:page)
    let s:curbuffer.buftype = a:mode
    let s:curbuffer.user = ''
    let s:curbuffer.list = ''
    let s:curbuffer.page = a:page
    redraw
    call s:save_buffer(0)
    echo "Direct messages ".s_or_r." timeline updated."
endfunction

function! twitvim#Direct_Messages(mode, page, max_id)
    call s:Direct_Messages(a:mode, a:page, a:max_id)
endfunction

" === Trends Code ===

let s:woeid_list = {}

" Get master list of WOEIDs from Twitter API.
function! s:get_woeids()
    if s:woeid_list != {}
        return s:woeid_list
    endif

    redraw
    echo "Retrieving list of WOEIDs..."

    let url = s:get_api_root().'/trends/available.json'
    let [error, output] = s:run_curl_oauth_get(url, {})
    if !empty(error)
        call s:errormsg("Error retrieving list of WOEIDs: ".error)
        return {}
    endif
    let result = s:parse_json(output)

    if type(result) != type([])
        call s:errormsg("Invalid JSON result from ".url)
        return {}
    endif

    for location in result
        let name = get(location, 'name', '')
        let woeid = get(location, 'woeid', '')
        let placetype = get(get(location, 'placeType', {}), 'name', '')
        let country = get(location, 'country', '')

        if placetype == 'Supername'
            let s:woeid_list[name] = { 'woeid' : woeid, 'towns' : {} }
        elseif placetype == 'Country'
            if !has_key(s:woeid_list, country)
                let s:woeid_list[country] = { 'towns' : {} }
            endif
            let s:woeid_list[country]['woeid'] = woeid
        elseif placetype == 'Town'
            if !has_key(s:woeid_list, country)
                let s:woeid_list[country] = { 'towns' : {} }
            endif
            let s:woeid_list[country]['towns'][name] = { 'woeid' : woeid }
        else
            call s:errormsg('Unknown location type "'.placetype.'".')
            return {}
        endif
    endfor

    redraw
    echo "Retrieved list of WOEIDs."

    return s:woeid_list
endfunction

function! s:get_woeid_pagelen()
    let maxlen = &lines - 3
    if maxlen < 5
        call s:errormsg('Window is not tall enough for menu.')
        return -1
    endif
    return maxlen < 20 ? maxlen : 20
endfunction

function! s:comp_countries(a, b)
    if a:a == 'Worldwide'
        return -1
    elseif a:b == 'Worldwide'
        return 1
    elseif a:a == 'United States'
        return -1
    elseif a:b == 'United States'
        return 1
    elseif a:a == a:b
        return 0
    elseif a:a < a:b
        return -1
    else
        return 1
    endif
endfunction

function! s:get_country_list()
    return sort(keys(s:woeid_list), 's:comp_countries')
endfunction

function! s:get_town_list(country)
    return [ a:country ] + sort(keys(s:woeid_list[a:country]['towns']))
endfunction

function! s:get_woeid(country, town)
    if a:town == '' || a:town == a:country
        return s:woeid_list[a:country]['woeid']
    else
        return s:woeid_list[a:country]['towns'][a:town]['woeid']
    endif
endfunction

function! s:make_loc_menu(what, namelist, pagelen, indx)
    let sublist = a:namelist[a:indx : a:indx + a:pagelen - 1]
    let menu = [ 'Pick a '.a:what.':' ]
    let item_count = 0
    for name in sublist
        let item_count += 1
        call add(menu, printf('%2d', item_count).'. '.name)
    endfor
    if a:indx + a:pagelen < len(a:namelist)
        let item_count += 1
        call add(menu, printf('%2d', item_count).'. next page')
    endif
    if a:indx > 0
        let item_count += 1
        call add(menu, printf('%2d', item_count).'. previous page')
    endif
    return menu
endfunction

function! s:pick_woeid_town(country)
    let indx = 0
    let towns = s:get_town_list(a:country)
    let pagelen = s:get_woeid_pagelen()

    while 1
        let menu = s:make_loc_menu('location', towns, pagelen, indx)

        call inputsave()
        let input = inputlist(menu)
        call inputrestore()

        if input < 1 || input >= len(menu)
            " Invalid input cancels the command.
            redraw
            echo 'Trends region unchanged.'
            return 0
        endif

        let select = menu[input][4:]

        if select == 'next page'
            let indx += pagelen
        elseif select == 'previous page'
            let indx -= pagelen
            if indx < 0
                indx = 0
            endif
        else
            let g:twitvim_woeid = s:get_woeid(a:country, select)

            redraw
            echo 'Trends region set to '.select.' ('.g:twitvim_woeid.').'

            return g:twitvim_woeid
        end
    endwhile
endfunction

" Allow the user to pick a WOEID for Trends from a list of WOEIDs.
function! twitvim#pick_woeid()
    let indx = 0
    if s:get_woeids() == {}
        return -1
    endif
    let countries = s:get_country_list()
    let pagelen = s:get_woeid_pagelen()

    while 1
        let menu = s:make_loc_menu('country', countries, pagelen, indx)

        call inputsave()
        let input = inputlist(menu)
        call inputrestore()

        if input < 1 || input >= len(menu)
            " Invalid input cancels the command.
            redraw
            echo 'Trends region unchanged.'
            return 0
        endif

        let select = menu[input][4:]

        if select == 'next page'
            let indx += pagelen
        elseif select == 'previous page'
            let indx -= pagelen
            if indx < 0
                indx = 0
            endif
        else
            if s:woeid_list[select]['towns'] == {}
                let g:twitvim_woeid = s:get_woeid(select, '')

                redraw
                echo 'Trends region set to '.select.' ('.g:twitvim_woeid.').'

                return g:twitvim_woeid
            else
                echo ' '
                return s:pick_woeid_town(select)
            end
        endif
    endwhile
endfunction

function! s:show_trends_json(timeline)
    let text = []

    let title = 'Trending topics'

    let s:curbuffer.showheader = s:get_show_header()
    if s:curbuffer.showheader
        call add(text, title.'*')
        call add(text, repeat('=', s:mbdisplen(title)).'*')
    endif

    for item in get(get(a:timeline, 0, {}), 'trends', {})
        call add(text, s:convert_entity(get(item, 'name', '')))
    endfor

    call s:twitter_wintext(text, "timeline")
    let s:curbuffer.buffer = text
endfunction

" Get trending topics.
function! s:Local_Trends()
    redraw
    echo "Getting trending topics..."

    let url = s:get_api_root().'/trends/place.json'
    let [error, output] = s:run_curl_oauth_get(url, { 'id' : s:get_twitvim_woeid() })
    if !empty(error)
        call s:errormsg("Error retrieving trending topics: ".error)
        return {}
    endif
    let result = s:parse_json(output)

    if type(result) != type([])
        call s:errormsg("Invalid JSON result from ".url)
        return {}
    endif

    call s:save_buffer(0)
    let s:curbuffer = {}
    call s:show_trends_json(result)
    let s:curbuffer.buftype = 'trends'
    let s:curbuffer.user = ''
    let s:curbuffer.list = ''
    let s:curbuffer.page = ''
    redraw
    call s:save_buffer(0)

    echo 'Trending topics retrieved.'
endfunction

function! twitvim#Local_Trends()
    return s:Local_Trends()
endfunction

" === End of Trends Code ===

" Function to load a timeline from the given parameters. For use by refresh and
" next/prev pagination commands.
" max_id (maximum tweet ID to load) is for the Twitter API max_id parameter.
" max_id = 0 if loading tweets from the start of timeline.
function! s:load_timeline(buftype, user, list, page, max_id)
    if a:buftype == "friends" || a:buftype == "user" || a:buftype == "replies" || a:buftype == "retweeted_by_me" || a:buftype == "retweeted_to_me" || a:buftype == 'favorites'
        call s:get_timeline(a:buftype, a:user, a:page, a:max_id)
    elseif a:buftype == "list"
        call s:get_list_timeline(a:user, a:list, a:page, a:max_id)
    elseif a:buftype == "dmsent" || a:buftype == "dmrecv"
        call s:Direct_Messages(a:buftype, a:page, a:max_id)
    elseif a:buftype == "search"
        call s:get_summize(a:user, a:page, a:max_id)
    elseif a:buftype == 'trends'
        call s:Local_Trends()
    endif
endfunction

" Returns the first (most recent) status in the current buffer.
function! s:get_first_status()
    let isdm = (s:curbuffer.buftype == "dmrecv" || s:curbuffer.buftype == "dmsent")
    if s:curbuffer.page <= 1
        " If we are on the first page, always return 0 to make it refresh from
        " the top of the timeline.
        return 0
    endif
    let statuses = isdm ? s:curbuffer.dmids : s:curbuffer.statuses
    for status in statuses
        if status != 0
            return status
        endif
    endfor
    return 0
endfunction

" Returns the last (least recent) status in the current buffer.
function! s:get_last_status()
    let isdm = (s:curbuffer.buftype == "dmrecv" || s:curbuffer.buftype == "dmsent")
    return get(isdm ? s:curbuffer.dmids : s:curbuffer.statuses, -1)
endfunction

" Refresh the timeline buffer.
function! s:RefreshTimeline()
    if s:curbuffer != {}
        call s:load_timeline(s:curbuffer.buftype, s:curbuffer.user, s:curbuffer.list, s:curbuffer.page, s:get_first_status())
    else
        call s:warnmsg("No timeline buffer to refresh.")
    endif
endfunction

function! twitvim#RefreshTimeline()
    call s:RefreshTimeline()
endfunction

" Go to next page in timeline.
function! s:NextPageTimeline()
    if s:curbuffer != {}
        call s:load_timeline(s:curbuffer.buftype, s:curbuffer.user, s:curbuffer.list, s:curbuffer.page + 1, s:get_last_status())
    else
        call s:warnmsg("No timeline buffer.")
    endif
endfunction

function! twitvim#NextPageTimeline()
    call s:NextPageTimeline()
endfunction

" Go to previous page in timeline.
function! s:PrevPageTimeline()
    if s:curbuffer != {}
        if s:curbuffer.page <= 1
            call s:warnmsg("Timeline is already on first page.")
        else
            call s:load_timeline(s:curbuffer.buftype, s:curbuffer.user, s:curbuffer.list, 1, 0)
        endif
    else
        call s:warnmsg("No timeline buffer.")
    endif
endfunction

function! twitvim#PrevPageTimeline()
    call s:PrevPageTimeline()
endfunction

" Get a Twitter list. Need to do a little fiddling because the
" username argument is optional.
function! twitvim#DoList(page, arg1, ...)
    let user = ''
    let list = a:arg1
    if a:0 > 0
        let user = a:arg1
        let list = a:1
    endif
    call s:get_list_timeline(user, list, a:page, 0)
endfunction

" Send a direct message.
function! s:do_send_dm(user, mesg)
    let mesg = a:mesg

    " Remove trailing newline. You see that when you visual-select an entire
    " line. Don't let it count towards the message length.
    let mesg = substitute(mesg, '\n$', '', "")

    " Convert internal newlines to spaces.
    let mesg = substitute(mesg, '\n', ' ', "g")

    " Only Twitter has a built-in URL wrapper thus far.
    if s:get_cur_service() == 'twitter'
        " Pretend to shorten URLs.
        let sim_mesg = s:sim_shorten_urls(mesg)
    else
        " Assume that identi.ca and other non-Twitter services don't do this
        " URL-shortening madness.
        let sim_mesg = mesg
    endif

    let mesglen = s:mbstrlen(sim_mesg)

    " Check message length. Note that the message length should be checked
    " before URL-encoding the special characters because URL-encoding increases
    " the string length.
    if mesglen > s:dm_char_limit
        call s:warnmsg("Your message has ".(mesglen - s:dm_char_limit)." too many characters. It was not sent.")
    elseif mesglen < 1
        call s:warnmsg("Your message was empty. It was not sent.")
    else
        redraw
        echo "Sending message to ".a:user."..."

        let url = s:get_api_root()."/direct_messages/new.json"
        let parms = { "source" : "twitvim", "user" : a:user, "text" : mesg }

        let [error, output] = s:run_curl_oauth_post(url, parms)
        if !empty(error)
            call s:errormsg("Error sending your message: ".error)
            return
        endif
        let result = s:parse_json(output)
        if empty(result)
            return
        endif
        if s:has_error(result)
            call s:errormsg("Error sending your message: ".s:get_error_message(result))
            return
        endif

        redraw
        echo "Your message was sent to ".a:user.". You used ".mesglen." characters."
    endif
endfunction

" Send a direct message. Prompt user for message if not given.
function! s:send_dm(user, mesg)
    if a:user == ""
        call s:warnmsg("No recipient specified for direct message.")
        return
    endif

    let mesg = a:mesg
    if mesg == ""
        call inputsave()
        let mesg = input("DM ".a:user.": ")
        call inputrestore()
    endif

    if mesg == ""
        call s:warnmsg("Your message was empty. It was not sent.")
        return
    endif

    call s:do_send_dm(a:user, mesg)
endfunction

function! twitvim#send_dm(user, mesg)
    call s:send_dm(a:user, a:mesg)
endfunction

" Call Twitter API to get rate limit information.
function! twitvim#get_rate_limit()
    redraw
    echo "Querying for rate limit information..."

    let url = s:get_api_root()."/application/rate_limit_status.json"
    let [error, output] = s:run_curl_oauth_get(url, {})
    if !empty(error)
        call s:errormsg("Error getting rate limit info: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting rate limit info: ".s:get_error_message(result))
        return
    endif

    redraw
    let resources = get(result, 'resources', {})
    for [ resource, endpoints ] in items(resources)
        for [ endpoint, endp_rec ] in items(endpoints)
            let remaining = get(endp_rec, 'remaining')
            let resettime = s:time_fmt(get(endp_rec, 'reset'))
            let limit = get(endp_rec, 'limit')

            echo endpoint . ' - Limit: '.limit."  Remaining: ".remaining."  Reset at: ".resettime
        endfor
    endfor
endfunction

function! twitvim#show_user_agent()
    echo s:user_agent
endfunction

" Set location field on Twitter profile.
function! twitvim#set_location(loc)
    redraw
    echo "Setting location on profile..."

    let url = s:get_api_root()."/account/update_profile.json"
    let [error, output] = s:run_curl_oauth_post(url, { 'location' : a:loc })
    if !empty(error)
        call s:errormsg("Error setting location: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error setting location: ".s:get_error_message(result))
        return
    endif

    redraw
    echo "Location: ".get(result, 'location', '')
endfunction

" Start following a user.
function! twitvim#follow_user(user)
    redraw
    echo 'Following user '.a:user.'...'

    " Make sure that we are not already following that user.
    let url = s:get_api_root().'/friendships/show.json'
    let [error, output] = s:run_curl_oauth_get(url, { 'target_screen_name' : a:user })
    if !empty(error)
        call s:errormsg("Error getting friendship info: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting friendship info: ".s:get_error_message(result))
        return
    endif

    let fship_source = get(get(result, 'relationship', {}), 'source', {})
    let following = get(fship_source, 'following')
    if following
        redraw
        echo "Already following ".a:user."'s timeline."
        return
    endif

    let url = s:get_api_root().'/friendships/create.json'
    let [error, output] = s:run_curl_oauth_post(url, { "screen_name" : a:user })
    if !empty(error)
        call s:errormsg("Error following user: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error following user: ".s:get_error_message(error))
        return
    endif

    let protected = get(result, 'protected')
    redraw
    if protected
        echo "Made request to follow ".a:user."'s protected timeline."
    else
        echo "Now following ".a:user."'s timeline."
    endif
endfunction

" Stop following a user.
function! twitvim#unfollow_user(user)
    redraw
    echo "Unfollowing user ".a:user."..."

    let url = s:get_api_root()."/friendships/destroy.json"
    let [error, output] = s:run_curl_oauth_post(url, { "screen_name" : a:user })
    if !empty(error)
        call s:errormsg("Error unfollowing user: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error unfollowing user: ".s:get_error_message(result))
        return
    endif

    redraw
    echo "Stopped following ".a:user."'s timeline."
endfunction

" Block a user.
function! twitvim#block_user(user, unblock)
    redraw
    echo (a:unblock ? "Unblocking" : "Blocking")." user ".a:user."..."

    let url = s:get_api_root()."/blocks/".(a:unblock ? "destroy" : "create").".json"
    let [error, output] = s:run_curl_oauth_post(url, { 'screen_name' : a:user })
    if !empty(error)
        call s:errormsg("Error ".(a:unblock ? "unblocking" : "blocking")." user: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error ".(a:unblock ? "unblocking" : "blocking")." user: ".s:get_error_message(result))
        return
    endif

    redraw
    echo "User ".a:user." is now ".(a:unblock ? "unblocked" : "blocked")."."
endfunction

" Mute a user.
function! twitvim#mute_user(user, unmute)
    redraw
    echo (a:unmute ? "Unmuting" : "Muting")." user ".a:user."..."

    let url = s:get_api_root()."/mutes/".(a:unmute ? "destroy" : "create").".json"
    let [error, output] = s:run_curl_oauth_post(url, { 'screen_name' : a:user })
    if !empty(error)
        call s:errormsg("Error ".(a:unmute ? "unmuting" : "muting")." user: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error ".(a:unmute ? "unmuting" : "muting")." user: ".s:get_error_message(result))
        return
    endif

    redraw
    echo "User ".a:user." is now ".(a:unmute ? "unmuted" : "muted")."."
endfunction

" Report user for spam.
function! twitvim#report_spam(user)
    redraw
    echo "Reporting ".a:user." for spam..."

    let url = s:get_api_root()."/users/report_spam.json"
    let [error, output] = s:run_curl_oauth_post(url, { 'screen_name' : a:user })
    if !empty(error)
        call s:errormsg("Error reporting user for spam: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error reporting user for spam: ".s:get_error_message(result))
        return
    endif

    redraw
    echo "Reported user ".a:user." for spam."
endfunction

" Enable/disable retweets from user.
function! twitvim#enable_retweets(user, enable)
    if a:enable
        let msg1 = "Enabling"
        let msg2 = "Enabled"
    else
        let msg1 = "Disabling"
        let msg2 = "Disabled"
    endif
    let msg3 = substitute(msg1, '^.', '\l&', '')

    redraw
    echo msg1." retweets for user ".a:user."..."

    let url = s:get_api_root()."/friendships/update.json"

    let parms = {}
    let parms['screen_name'] = a:user
    let parms['retweets'] = a:enable ? 'true' : 'false'

    let [error, output] = s:run_curl_oauth_post(url, parms)
    if !empty(error)
        call s:errormsg("Error ".msg3." retweets from user: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error ".msg3." retweets from user: ".s:get_error_message(result))
        return
    endif

    redraw
    echo msg2." retweets from user ".a:user."."
endfunction

" Add user to a list or remove user from a list.
function! s:add_to_list(remove, listname, username)
    let user = s:get_twitvim_username()
    if user == ''
        call s:errormsg('Login not set. Please specify a username.')
        return -1
    endif

    redraw
    if a:remove
        echo "Removing ".a:username." from list ".a:listname."..."
        let verb = 'destroy'
    else
        echo "Adding ".a:username." to list ".a:listname."..."
        let verb = 'create'
    endif

    let parms = {}
    let parms['slug'] = a:listname
    let parms['owner_screen_name'] = user
    let parms['screen_name'] = a:username

    let url = s:get_api_root().'/lists/members/'.verb.'.json'

    let [error, output] = s:run_curl_oauth_post(url, parms)
    if !empty(error)
        call s:errormsg("Error ".(a:remove ? "removing user from" : "adding user to")." list: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error ".(a:remove ? "removing user from" : "adding user to")." list: ".s:get_error_message(result))
        return
    endif

    redraw
    if a:remove
        echo "Removed ".a:username." from list ".a:listname."."
    else
        echo "Added ".a:username." to list ".a:listname."."
    endif
endfunction

function! twitvim#do_add_to_list(arg1, ...)
    if a:0 == 0
        call s:errormsg("Syntax: :AddToListTwitter listname username")
    else
        call s:add_to_list(0, a:arg1, a:1)
    endif
endfunction

function! twitvim#do_remove_from_list(arg1, ...)
    if a:0 == 0
        call s:errormsg("Syntax: :RemoveFromListTwitter listname username")
    else
        call s:add_to_list(1, a:arg1, a:1)
    endif
endfunction

let s:user_winname = "TwitterInfo_".localtime()

" Convert true/false into yes/no.
function! s:yesorno(s)
    let s = tolower(a:s)
    if s == "true" || s == "yes" || s == 1
        return "yes"
    elseif s == "false" || s == "no" || s == "" || s == 0
        return "no"
    else
        return s
    endif
endfunction

" Process/format the user information.
function! s:format_user_info(result, fship_result)
    let text = []
    let result = a:result
    let fship_result = a:fship_result

    let name = s:convert_entity(get(result, 'name', ''))
    let screen = get(result, 'screen_name', '')
    call add(text, 'Name: '.screen.' ('.name.')')

    call add(text, 'Location: '.s:convert_entity(get(result, 'location', '')))
    call add(text, 'Website: '.get(result, 'url', ''))
    call add(text, 'Bio: '.s:convert_entity(get(result, 'description', '')))
    call add(text, '')
    call add(text, 'Following: '.get(result, 'friends_count'))
    call add(text, 'Followers: '.get(result, 'followers_count'))
    call add(text, 'Listed: '.get(result, 'listed_count'))
    call add(text, 'Updates: '.get(result, 'statuses_count'))
    call add(text, 'Favorites: '.get(result, 'favourites_count'))
    call add(text, '')

    call add(text, 'Protected: '.s:yesorno(get(result, 'protected', '')))

    let follow_req = get(result, 'follow_request_sent', '')
    let following_str = follow_req ? 'Follow request sent' : s:yesorno(get(result, 'following', ''))
    call add(text, 'Following: '.following_str)

    let fship_source = get(get(fship_result, 'relationship', {}), 'source', {})
    call add(text, 'Followed_by: '.s:yesorno(get(fship_source, 'followed_by', '')))
    call add(text, 'Blocked: '.s:yesorno(get(fship_source, 'blocking', '')))
    call add(text, 'Muted: '.s:yesorno(get(fship_source, 'muting', '')))
    call add(text, 'Marked_spam: '.s:yesorno(get(fship_source, 'marked_spam', '')))
    call add(text, 'Retweets: '.s:yesorno(get(fship_source, 'want_retweets', '')))
    call add(text, 'Notifications: '.s:yesorno(get(fship_source, 'notifications_enabled', '')))

    call add(text, '')

    let startdate = s:time_filter(get(result, 'created_at', ''))
    call add(text, 'Started: |'.startdate.'|')
    let timezone = s:convert_entity(get(result, 'time_zone', ''))
    call add(text, 'Timezone: '.timezone)
    call add(text, '')

    let statusnode = get(result, 'status', {})
    if statusnode != {}
        let status = s:get_status_text_json(statusnode)
        let pubdate = s:time_filter(get(statusnode, 'created_at', ''))
        call add(text, 'Status: '.s:convert_entity(status).' |'.pubdate.'|')
    endif

    return text
endfunction

" Call Twitter API to get user's info.
function! s:get_user_info(username)
    let user = a:username
    if user == ''
        let user = s:get_twitvim_username()
        if user == ''
            call s:errormsg('Login not set. Please specify a username.')
            return
        endif
    endif

    redraw
    echo "Querying for user information..."

    let url = s:get_api_root()."/users/show.json"

    let parms = {}
    let parms.screen_name = user

    " Include entities to get URL expansions for t.co.
    let parms.include_entities = 'true'

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg("Error getting user info: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting user info: ".s:get_error_message(result))
        return
    endif

    let url = s:get_api_root()."/friendships/show.json"
    let [error, fship_output] = s:run_curl_oauth_get(url, { 'target_screen_name' : user })
    let fship_result = s:parse_json(fship_output)
    if !empty(error)
        call s:errormsg("Error getting friendship info: ".s:get_error_message(error))
        return
    endif

    call s:save_buffer(1)
    let s:infobuffer = {}
    call s:twitter_wintext(s:format_user_info(result, fship_result), "userinfo")
    let s:infobuffer.buftype = 'profile'
    let s:infobuffer.next_cursor = 0
    let s:infobuffer.prev_cursor = 0
    let s:infobuffer.cursor = 0
    let s:infobuffer.user = user
    let s:infobuffer.list = ''
    redraw
    call s:save_buffer(1)
    echo "User information retrieved."
endfunction

function! twitvim#get_user_info(username)
    call s:get_user_info(a:username)
endfunction

" Format the list information.
function! s:format_list_info(result)
    let text = []
    let result = a:result
    call add(text, 'Name: '.s:convert_entity(get(result, 'full_name', '')))
    call add(text, 'Description: '.s:convert_entity(get(result, 'description', '')))
    call add(text, '')
    call add(text, 'Members: '.get(result, 'member_count'))
    call add(text, 'Subscribers: '.get(result, 'subscriber_count'))
    call add(text, '')
    call add(text, 'Following: '.s:yesorno(get(result, 'following', '')))
    call add(text, 'Mode: '.get(result, 'mode', ''))
    return text
endfunction

" Call Twitter API to get list info.
function! s:get_list_info(username, listname)
    let user = a:username
    if user == ''
        let user = s:get_twitvim_username()
        if user == ''
            call s:errormsg('Login not set. Please specify a username.')
            return
        endif
    endif

    let list = a:listname

    redraw
    echo 'Querying for information on list '.user.'/'.list.'...'

    let url = s:get_api_root().'/lists/show.json'
    let parms = {}
    let parms.slug = list
    let parms.owner_screen_name = user
    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg('Error getting information on list '.user.'/'.list.': '.error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg('Error getting information on list '.user.'/'.list.': '.s:get_error_message(result))
        return
    endif

    call s:save_buffer(1)
    let s:infobuffer = {}
    call s:twitter_wintext(s:format_list_info(result), "userinfo")
    let s:infobuffer.buftype = 'listinfo'
    let s:infobuffer.next_cursor = 0
    let s:infobuffer.prev_cursor = 0
    let s:infobuffer.cursor = 0
    let s:infobuffer.user = user
    let s:infobuffer.list = list
    redraw
    call s:save_buffer(1)
    echo 'List information retrieved.'
endfunction

" Get info on a Twitter list. Need to do a little fiddling because the username
" argument is optional.
function! twitvim#DoListInfo(arg1, ...)
    let user = ''
    let list = a:arg1
    if a:0 > 0
        let user = a:arg1
        let list = a:1
    endif
    call s:get_list_info(user, list)
endfunction

" Format a list of users, e.g. friends/followers list.
function! s:format_user_list_json(result, title, show_following)
    let text = []

    let showheader = s:get_show_header()
    if showheader
        " The extra stars at the end are for the syntax highlighter to
        " recognize the title. Then the syntax highlighter hides the stars by
        " coloring them the same as the background. It is a bad hack.
        call add(text, a:title.'*')
        call add(text, repeat('=', s:mbdisplen(a:title)).'*')
    endif

    for user in a:result
        let following_str = ''
        if a:show_following
            let following = get(user, 'following')
            if following
                let following_str = ' Following'
            else
                let follow_req = get(user, 'follow_request_sent')
                let following_str = follow_req ? ' Follow request sent' : ' Not following'
            endif
        endif

        let name = s:convert_entity(get(user, 'name', ''))
        let screen = get(user, 'screen_name', '')
        let location = s:convert_entity(get(user, 'location', ''))
        let slocation = location == '' ? '' : '|'.location
        call add(text, 'Name: '.screen.' ('.name.slocation.')'.following_str)

        let desc = get(user, 'description', '')
        if desc != ''
            call add(text, 'Bio: '.s:convert_entity(desc))
        endif

        let statusnode = get(user, 'status', {})
        if statusnode != {}
            let status = s:get_status_text_json(statusnode)
            let pubdate = s:time_filter(get(statusnode, 'created_at', ''))
            call add(text, 'Status: '.s:convert_entity(status).' |'.pubdate.'|')
        endif

        call add(text, '')
    endfor
    return text
endfunction

" Call Twitter API to get list of friends/followers IDs.
function! s:get_friends_ids_2(cursor, user, followers)
    let what = a:followers ? 'followers IDs' : 'friends IDs'
    if a:user != ''
        let what .= ' of '.a:user
    endif

    let query = '/' . (a:followers ? 'followers' : 'friends') . '/ids.json'

    redraw
    echo 'Querying for '.what.'...'

    let url = s:get_api_root().query

    let parms = {}
    let parms.cursor = a:cursor
    if a:user != ''
        let parms.screen_name = a:user
    endif
    let parms.stringify_ids = 'true'

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg('Error getting '.what.': '.s:get_error_message(error))
        return {}
    endif
    let result = s:parse_json(output)
    let res = {}
    let res.next_cursor = get(result, 'next_cursor_str')
    let res.prev_cursor = get(result, 'previous_cursor_str')
    let res.ids = get(result, 'ids', [])
    return res
endfunction

" The size of each slice of IDs we'll cut from the list of 5000 user IDs
" returned by friends or followers/ids. This number cannot be larger than 100
" because that is the limit for users/lookup.
let s:idslice_len = 100

" Call Twitter API to look up friends info from list of IDs.
function! s:get_friends_info_2(ids, index)
    redraw
    echo 'Querying for friends/followers info...'

    let idslice = a:ids[a:index : a:index + s:idslice_len - 1]

    if idslice == []
        call s:errormsg('No friends/followers?')
        return []
    endif

    let url = s:get_api_root().'/users/lookup.json'
    let parms = {}
    let parms.include_entities = 'true'
    let parms.user_id = join(idslice, ',')

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg('Error getting friends/followers info: '.error)
        return []
    endif
    let result = s:parse_json(output)
    if empty(result)
        return []
    endif
    if s:has_error(result)
        call s:errormsg('Error getting friends/followers info: '.s:get_error_message(result))
        return []
    endif

    " Reorder result according to ID list. Twitter loses the ordering when you call it on 100 user IDs.
    let idindex = {}
    for user in result
        let idindex[get(user, 'id_str', '')] = user
    endfor

    " users/lookup may skip some IDs that have been suspended. So we have to be
    " careful and filter out any IDs for which there is no info.
    return filter(map(copy(idslice), 'get(idindex, v:val, {})'), 'v:val != {}')
endfunction

" Call Twitter API to get friends or followers list.
function! s:get_friends_2(cursor, ids, next_cursor, prev_cursor, index, user, followers)
    if a:ids == []
        let result = s:get_friends_ids_2(a:cursor, a:user, a:followers)
        if result == {}
            return
        endif
        let ids = result.ids
        let next_cursor = result.next_cursor
        let prev_cursor = result.prev_cursor
        if a:index < 0
            " If user is paging backwards, we want the last 100 IDs in the
            " list.
            let index = len(ids) - s:idslice_len
            if index < 0
                let index = 0
            endif
        else
            let index = 0
        endif
    else
        let ids = a:ids
        let next_cursor = a:next_cursor
        let prev_cursor = a:prev_cursor
        let index = a:index
    endif

    let result2 = s:get_friends_info_2(ids, index)
    if result2 == []
        return
    endif

    let title = a:followers ? 'Followers list' : 'Friends list'
    if a:user != ''
        let title .= ' of '.a:user
    endif

    let buftype = a:followers ? 'followers' : 'friends'

    call s:save_buffer(1)
    let s:infobuffer = {}
    call s:twitter_wintext(s:format_user_list_json(result2, title, a:followers || a:user != ''), "userinfo")
    let s:infobuffer.buftype = buftype
    let s:infobuffer.next_cursor = next_cursor
    let s:infobuffer.prev_cursor = prev_cursor
    let s:infobuffer.cursor = a:cursor
    let s:infobuffer.user = a:user
    let s:infobuffer.list = ''

    let s:infobuffer.flist = ids
    let s:infobuffer.findex = index

    redraw
    call s:save_buffer(1)
    echo title.' retrieved.'
endfunction

" Call Twitter API to get members or subscribers of list.
function! s:get_list_members(cursor, user, list, subscribers)
    let user = a:user
    if user == ''
        let user = s:get_twitvim_username()
        if user == ''
            call s:errormsg('Login not set. Please specify a username.')
            return
        endif
    endif

    if a:subscribers
        let item = "list subscribers"
        let query = "/subscribers"
        let buftype = "listsubs"
        let title = 'Subscribers to list '.user.'/'.a:list
    else
        let item = "list members"
        let query = "/members"
        let buftype = "listmembers"
        let title = 'Members of list '.user.'/'.a:list
    endif

    redraw
    echo "Querying for ".item."..."

    let url = s:get_api_root().'/lists'.query.'.json'

    let parms = {}
    let parms.cursor = a:cursor
    let parms.slug = a:list
    let parms.owner_screen_name = user

    " Include entities to get URL expansions for t.co.
    let parms.include_entities = 'true'

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg("Error getting ".item.": ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting ".item.": ".s:get_error_message(result))
        return
    endif

    call s:save_buffer(1)
    let s:infobuffer = {}
    call s:twitter_wintext(s:format_user_list_json(get(result, 'users', []), title, 1), 'userinfo')
    let s:infobuffer.buftype = buftype
    let s:infobuffer.next_cursor = get(result, 'next_cursor_str')
    let s:infobuffer.prev_cursor = get(result, 'previous_cursor_str')
    let s:infobuffer.cursor = a:cursor
    let s:infobuffer.user = user
    let s:infobuffer.list = a:list
    redraw
    call s:save_buffer(1)
    echo "Retrieved ".item."."
endfunction

" Get Twitter list members. Need to do a little fiddling because the
" username argument is optional.
function! twitvim#DoListMembers(subscribers, arg1, ...)
    let user = ''
    let list = a:arg1
    if a:0 > 0
        let user = a:arg1
        let list = a:1
    endif
    call s:get_list_members(-1, user, list, a:subscribers)
endfunction

" Format a list of lists, e.g. user's list memberships or list subscriptions.
function! s:format_list_list(result, title)
    let text = []

    let showheader = s:get_show_header()
    if showheader
        " The extra stars at the end are for the syntax highlighter to
        " recognize the title. Then the syntax highlighter hides the stars by
        " coloring them the same as the background. It is a bad hack.
        call add(text, a:title.'*')
        call add(text, repeat('=', s:mbdisplen(a:title)).'*')
    endif

    for list in a:result
        let name = get(list, 'full_name', '')
        let following = get(list, 'member_count')
        let followers = get(list, 'subscriber_count')
        call add(text, 'List: '.name.' (Following: '.following.' Followers: '.followers.')')
        let desc = s:convert_entity(get(list, 'description', ''))
        if desc != ""
            call add(text, 'Desc: '.desc)
        endif
        call add(text, '')
    endfor
    return text
endfunction

" Call Twitter API to get a user's lists, list memberships, or list subscriptions.
function! s:get_user_lists(cursor, user, what)
    let user = a:user
    let titlename = user
    if user == ''
        let titlename = 'you'
    endif
    if a:what == "owned"
        let item = "lists"
        let query = "lists/list"
        let title = "Lists owned by ".titlename
        let buftype = 'userlists'
    elseif a:what == "memberships"
        let item = "list memberships"
        let query = "lists/memberships"
        let title = "Lists following ".titlename
        let buftype = 'userlistmem'
    else
        let item = "list subscriptions"
        let query = "lists/subscriptions"
        let title = "Lists followed by ".titlename
        let buftype = 'userlistsubs'
    endif

    redraw
    echo "Querying for user's ".item."..."

    let url = s:get_api_root().'/'.query.'.json'

    let parms = {}
    let parms.cursor = a:cursor
    if user != ''
        let parms.screen_name = user
    endif
    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg("Error getting user's ".item.": ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error getting user's ".item.": ".s:get_error_message(result))
        return
    endif

    " For :OwnedListsTwitter, filter out non-owned lists.
    let user2 = user == '' ? s:get_twitvim_username() : user
    if a:what == "owned"
        call filter(result, 'get(get(v:val, "user", {}), "screen_name", "") ==? user2')
    endif

    call s:save_buffer(1)
    let s:infobuffer = {}
    call s:twitter_wintext(s:format_list_list(a:what == 'owned' ? result : get(result, 'lists', []), title), 'userinfo')
    let s:infobuffer.buftype = buftype
    let s:infobuffer.next_cursor = get(result, 'next_cursor_str')
    let s:infobuffer.prev_cursor = get(result, 'previous_cursor_str')
    let s:infobuffer.cursor = a:cursor
    let s:infobuffer.user = user
    let s:infobuffer.list = ''
    redraw
    call s:save_buffer(1)
    echo "User's ".item." retrieved."
endfunction

function! twitvim#get_user_lists(cursor, user, what)
    call s:get_user_lists(a:cursor, a:user, a:what)
endfunction

" Function to load previous or next friends/followers info page.
" For use by next/prev pagination commands.
function! s:load_prevnext_friends_info_2(buftype, infobuffer, previous)
    if a:previous
        if a:infobuffer.findex == 0
            if a:infobuffer.prev_cursor == 0
                call s:warnmsg('No previous page in info buffer.')
                return
            endif
            let cursor = a:infobuffer.prev_cursor
            let ids = []
            let next_cursor = 0
            let prev_cursor = 0

            " This tells s:get_friends_2() that we are paging backwards so
            " it'll display the last 100 items in the new ID list.
            let index = -1
        else
            let cursor = a:infobuffer.cursor
            let ids = a:infobuffer.flist
            let next_cursor = a:infobuffer.next_cursor
            let prev_cursor = a:infobuffer.prev_cursor
            let index = a:infobuffer.findex - s:idslice_len
            if index < 0
                let index = 0
            endif
        endif
    else
        let nextindex = a:infobuffer.findex + s:idslice_len
        if nextindex >= len(a:infobuffer.flist)
            if a:infobuffer.next_cursor == 0
                call s:warnmsg('No next page in info buffer.')
                return
            endif
            let cursor = a:infobuffer.next_cursor
            let ids = []
            let next_cursor = 0
            let prev_cursor = 0
            let index = 0
        else
            let cursor = a:infobuffer.cursor
            let ids = a:infobuffer.flist
            let next_cursor = a:infobuffer.next_cursor
            let prev_cursor = a:infobuffer.prev_cursor
            let index = nextindex
        endif
    endif

    call s:get_friends_2(cursor, ids, next_cursor, prev_cursor, index, a:infobuffer.user, a:buftype == 'followers')
endfunction

" Function to load an info buffer from the given parameters.
" For use by next/prev pagination commands.
" Note: friends and followers buffer types need special handling.
function! s:load_info(buftype, cursor, user, list)
    if a:buftype == "listmembers"
        call s:get_list_members(a:cursor, a:user, a:list, 0)
    elseif a:buftype == "listsubs"
        call s:get_list_members(a:cursor, a:user, a:list, 1)
    elseif a:buftype == "userlists"
        call s:get_user_lists(a:cursor, a:user, 'owned')
    elseif a:buftype == "userlistmem"
        call s:get_user_lists(a:cursor, a:user, 'memberships')
    elseif a:buftype == "userlistsubs"
        call s:get_user_lists(a:cursor, a:user, 'subscriptions')
    elseif a:buftype == "profile"
        call s:get_user_info(a:user)
    elseif a:buftype == 'listinfo'
        call s:get_list_info(a:user, a:list)
    endif
endfunction

" Go to next page in info buffer.
function! s:NextPageInfo()
    if s:infobuffer != {}
        if s:infobuffer.buftype == 'friends' || s:infobuffer.buftype == 'followers'
            call s:load_prevnext_friends_info_2(s:infobuffer.buftype, s:infobuffer, 0)
            return
        endif
        if s:infobuffer.next_cursor == 0
            call s:warnmsg("No next page in info buffer.")
        else
            call s:load_info(s:infobuffer.buftype, s:infobuffer.next_cursor, s:infobuffer.user, s:infobuffer.list)
        endif
    else
        call s:warnmsg("No info buffer.")
    endif
endfunction

function! twitvim#NextPageInfo()
    call s:NextPageInfo()
endfunction

" Go to previous page in info buffer.
function! s:PrevPageInfo()
    if s:infobuffer != {}
        if s:infobuffer.buftype == 'friends' || s:infobuffer.buftype == 'followers'
            call s:load_prevnext_friends_info_2(s:infobuffer.buftype, s:infobuffer, 1)
            return
        endif
        if s:infobuffer.prev_cursor == 0
            call s:warnmsg("No previous page in info buffer.")
        else
            call s:load_info(s:infobuffer.buftype, s:infobuffer.prev_cursor, s:infobuffer.user, s:infobuffer.list)
        endif
    else
        call s:warnmsg("No info buffer.")
    endif
endfunction

function! twitvim#PrevPageInfo()
    call s:PrevPageInfo()
endfunction

" Refresh info buffer.
function! s:RefreshInfo()
    if s:infobuffer != {}
        if s:infobuffer.buftype == 'friends' || s:infobuffer.buftype == 'followers'
            call s:get_friends_2(s:infobuffer.cursor, s:infobuffer.flist, s:infobuffer.next_cursor, s:infobuffer.prev_cursor, s:infobuffer.findex, s:infobuffer.user, s:infobuffer.buftype == 'followers')
            return
        endif
        call s:load_info(s:infobuffer.buftype, s:infobuffer.cursor, s:infobuffer.user, s:infobuffer.list)
    else
        call s:warnmsg("No info buffer.")
    endif
endfunction

function! twitvim#RefreshInfo()
    call s:RefreshInfo()
endfunction

function! twitvim#do_get_friends(user, followers)
    call s:get_friends_2(-1, [], 0, 0, 0, a:user, a:followers)
endfunction

" Follow or unfollow a list.
function! twitvim#follow_list(unfollow, arg1, ...)
    if a:0 < 1
        call s:errormsg('Please specify both a username and a list.')
        return
    endif
    let user = a:arg1
    let list = a:1

    if a:unfollow
        let v1 = "Unfollowing"
        let v2 = "unfollowing"
        let v3 = "Stopped following"
        let verb = 'destroy'
    else
        let v1 = "Following"
        let v2 = "following"
        let v3 = "Now following"
        let verb = 'create'
    endif

    redraw
    echo v1." list ".user."/".list."..."

    let parms = {}
    let parms.slug = list
    let parms.owner_screen_name = user
    let url = s:get_api_root().'/lists/subscribers/'.verb.'.json'

    let [error, output] = s:run_curl_oauth_post(url, parms)
    if !empty(error)
        call s:errormsg("Error ".v2." list: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error ".v2." list: ".s:get_error_message(result))
        return
    endif

    redraw
    echo v3." list ".user."/".list."."
endfunction

" Get bit.ly access token if configured by the user. Otherwise, use a default
" access token.
function! s:get_bitly_key()
    return get(g:, 'twitvim_bitly_key', 'da11381ea442aa466a301a28bb3dcd334448f83a')
endfunction

" Call bit.ly API to shorten a URL.
function! s:call_bitly(url)
    let key = s:get_bitly_key()

    redraw
    echo "Sending request to bit.ly..."

    let url = 'https://api-ssl.bitly.com/v3/shorten'
    let url = s:add_to_url(url, 'access_token='.key)
    let url = s:add_to_url(url, 'longUrl='.s:url_encode(a:url))
    let [error, output] = s:run_curl(url, '', s:get_proxy(), s:get_proxy_login(), {})
    " Remove trailing newlines.
    let output = substitute(output, '\n\+$', '', '')
    let result = s:parse_json(output)

    let status_txt = get(result, 'status_txt', 'Error parsing result from bit.ly')
    let status_code = get(result, 'status_code', -1)

    if !empty(error) || status_code != 200
        call s:errormsg('Error calling bit.ly API: '.(status_txt != '' ? status_code.' '.status_txt : error))
        return ''
    endif

    let shorturl = get(get(result, 'data', {}), 'url', '')

    if shorturl == ''
        call s:errormsg("Bit.ly didn't return a shortened URL??")
        return ''
    endif

    redraw
    echo 'Received response from bit.ly.'
    return shorturl
endfunction

" Call is.gd API to shorten a URL.
function! s:call_isgd(url)
    redraw
    echo "Sending request to is.gd..."

    let url = 'https://is.gd/api.php?longurl='.s:url_encode(a:url)
    let [error, output] = s:run_curl(url, '', s:get_proxy(), s:get_proxy_login(), {})

    if !empty(error)
        call s:errormsg("Error calling is.gd API: ".error)
        return ""
    else
        redraw
        echo "Received response from is.gd."
        return output
    endif
endfunction

let s:googl_api_key = 'AIzaSyDvAhCUJppsPnPHgazgKktMoYap-QXCy5c'

" Call Goo.gl API (documented version) to shorten a URL.
function! s:call_googl(url)
    let url = 'https://www.googleapis.com/urlshortener/v1/url?key='.s:googl_api_key
    let parms = { '__json' : '{ "longUrl" : "'.a:url.'" }' }

    redraw
    echo "Sending request to goo.gl..."

    let [error, output] = s:run_curl(url, '', s:get_proxy(), s:get_proxy_login(), parms)

    " Remove nul characters.
    let output = substitute(output, '[\x0]', ' ', 'g')

    let result = s:parse_json(output)

    if has_key(result, 'error') && has_key(result.error, 'message')
        call s:errormsg("Error calling goo.gl API: ".result.error.message)
        return ""
    endif

    if has_key(result, 'id')
        redraw
        echo "Received response from goo.gl."
        return result.id
    endif

    if !empty(error)
        call s:errormsg("Error calling goo.gl API: ".error)
        return ""
    endif

    call s:errormsg("No result returned by goo.gl API.")
    return ""
endfunction

" Invoke URL shortening service to shorten a URL and insert it at the current
" position in the current buffer.
function! twitvim#GetShortURL(tweetmode, url, shortfn)
    let url = a:url

    " Prompt the user to enter a URL if not provided on :IsGd command
    " line.
    if url == ""
        call inputsave()
        let url = input("URL to shorten: ")
        call inputrestore()
    endif

    if url == ""
        call s:warnmsg("No URL provided.")
        return
    endif

    let shorturl = call(function("s:".a:shortfn), [url])
    if shorturl != ""
        if a:tweetmode == "cmdline"
            call s:CmdLine_Twitter(shorturl." ", 0)
        elseif a:tweetmode == "append"
            execute "normal! a".shorturl."\<esc>"
        else
            execute "normal! i".shorturl." \<esc>"
        endif
    endif
endfunction

" Get status text with t.co URL expansion. (JSON version)
function! s:get_status_text_json(item)
    let text = get(a:item, 'text', '')

    " Remove nul characters.
    let text = substitute(text, '[\x0]', ' ', 'g')

    let entities = get(a:item, 'entities', {})

    let urls = get(entities, 'urls', []) + get(entities, 'media', [])
    for url in urls
        let fromurl = get(url, 'url', '')
        let tourl = get(url, 'expanded_url', '')
        if fromurl != '' && tourl != ''
            let text = s:str_replace_all(text, fromurl, tourl)
        endif
    endfor

    return text
endfunction

" Parse and format search results from Twitter Search API.
function! s:show_summize_new(searchres, page)
    let text = []

    let s:curbuffer.dmids = []

    let title = 'Search - '.s:url_decode(get(get(a:searchres, 'search_metadata', {}), 'query', ''))
    if a:page > 1
        let title .= ' (page '.a:page.')'
    endif

    let s:curbuffer.showheader = s:get_show_header()
    if s:curbuffer.showheader
        " Index of first status will be 3 to match line numbers in timeline
        " display.
        let s:curbuffer.statuses = [0, 0, 0]
        let s:curbuffer.inreplyto = [0, 0, 0]

        " The extra stars at the end are for the syntax highlighter to
        " recognize the title. Then the syntax highlighter hides the stars by
        " coloring them the same as the background. It is a bad hack.
        call add(text, title.'*')
        call add(text, repeat('=', s:mbdisplen(title)).'*')
    else
        " Index of first status will be 1 to match line numbers in timeline
        " display.
        let s:curbuffer.statuses = [0]
        let s:curbuffer.inreplyto = [0]
    endif

    for item in get(a:searchres, 'statuses', [])
        let user = get(get(item, 'user', {}), 'screen_name', '')

        let line = s:convert_entity(s:get_status_text_json(item))
        let pubdate = s:time_filter(get(item, 'created_at', ''))

        let status = get(item, 'id_str', '')
        call add(s:curbuffer.statuses, status)
        call add(s:curbuffer.inreplyto, get(item, 'in_reply_to_status_id_str', ''))

        call add(text, user.': '.line.' |'.pubdate.'|')
    endfor

    call s:twitter_wintext(text, "timeline")
    let s:curbuffer.buffer = text
endfunction

" Query Search API and retrieve results.
" History: Summize was the original name of a third-party Twitter search
" service before it was acquired by Twitter.
function! s:get_summize(query, page, max_id)
    redraw
    echo "Sending search request..."

    let svc = s:get_cur_service()
    let url = svc == '' ? s:get_api_root().'/search.json' : s:service_info[svc]['search_api']

    let parms = {}
    let parms.q = a:query

    " Support max_id parameter.
    if a:max_id != 0
        let parms.max_id = a:max_id
    endif

    " Support count parameter in search results.
    let tcount = s:get_count()
    if tcount > 0
        let parms.rpp = tcount
        let parms.count = tcount
    endif

    " Include entities to get URL expansions for t.co.
    let parms.include_entities = 'true'

    let [error, output] = s:run_curl_oauth_get(url, parms)
    if !empty(error)
        call s:errormsg("Error querying Search: ".error)
        return
    endif
    let result = s:parse_json(output)
    if empty(result)
        return
    endif
    if s:has_error(result)
        call s:errormsg("Error querying Search: ".s:get_error_message(result))
        return
    endif

    if type(result) != type({})
        call s:errormsg("Invalid JSON result from ".url)
        return
    endif

    call s:save_buffer(0)
    let s:curbuffer = {}

    call s:show_summize_new(result, a:page)

    let s:curbuffer.buftype = "search"

    " Stick the query in here to differentiate between sets of search results.
    let s:curbuffer.user = a:query

    let s:curbuffer.list = ''
    let s:curbuffer.page = a:page
    redraw
    call s:save_buffer(0)
    echo "Received search results."
endfunction

" Prompt user for Twitter Search query string if not entered on command line.
function! twitvim#Summize(query, page)
    let query = a:query

    " Prompt the user to enter a query if not provided on :SearchTwitter
    " command line.
    if query == ""
        call inputsave()
        let query = input("Search: ")
        call inputrestore()
    endif

    if query == ""
        call s:warnmsg("No query provided for Search.")
        return
    endif

    call s:get_summize(query, a:page, 0)
endfunction

let &cpo = s:save_cpo
finish

" vim:set tw=0 et:
