" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/twitvim.vim	[[[1
329
" ==============================================================
" TwitVim - Post to Twitter from Vim
" Based on Twitter Vim script by Travis Jeffery <eatsleepgolf@gmail.com>
"
" Version: 0.9.0
" License: Vim license. See :help license
" Language: Vim script
" Maintainer: Po Shan Cheah <morton@mortonfox.com>
" Created: March 28, 2008
" Last updated: April 10, 2015
"
" GetLatestVimScripts: 2204 1 twitvim.vim
" ==============================================================

" Load this module only once.
if exists('g:loaded_twitvim')
    finish
endif
let g:loaded_twitvim = '0.9.0 2015-04-10'

" Check Vim version.
if v:version < 703
    echohl ErrorMsg
    echomsg 'You need Vim 7.3 or later for this version of TwitVim'
    echohl None
    finish
endif

" Avoid side-effects from cpoptions setting.
let s:save_cpo = &cpo
set cpo&vim

" For debugging. Reset Hmac method.
if !exists(":TwitVimResetHmacMethod")
    command TwitVimResetHmacMethod :call twitvim#reset_hmac_method()
endif

" For debugging. Show current Hmac method.
if !exists(":TwitVimShowHmacMethod")
    command TwitVimShowHmacMethod :call twitvim#show_hmac_method()
endif

" For debugging. Reset networking method.
if !exists(":TwitVimResetMethod")
    command TwitVimResetMethod :call twitvim#reset_curl_method()
endif

" For debugging. Show current networking method.
if !exists(":TwitVimShowMethod")
    command TwitVimShowMethod :call twitvim#show_curl_method()
endif

if !exists(":BackTwitter")
    command BackTwitter :call twitvim#back_buffer(0)
endif
if !exists(":ForwardTwitter")
    command ForwardTwitter :call twitvim#fwd_buffer(0)
endif
if !exists(":BackInfoTwitter")
    command BackInfoTwitter :call twitvim#back_buffer(1)
endif
if !exists(":ForwardInfoTwitter")
    command ForwardInfoTwitter :call twitvim#fwd_buffer(1)
endif

if !exists(":TwitVimShowBufstack")
    command TwitVimShowBufstack :call twitvim#show_bufstack(0)
endif
if !exists(":TwitVimShowInfoBufstack")
    command TwitVimShowInfoBufstack :call twitvim#show_bufstack(1)
endif

" For debugging. Show curbuffer variable.
if !exists(":TwitVimShowCurbuffer")
    command TwitVimShowCurbuffer :call twitvim#show_bufvar(0)
endif
" For debugging. Show infobuffer variable.
if !exists(":TwitVimShowInfobuffer")
    command TwitVimShowInfobuffer :call twitvim#show_bufvar(1)
endif

" Prompt user for tweet.
if !exists(":PosttoTwitter")
    command PosttoTwitter :call twitvim#CmdLine_Twitter('', 0)
endif

nnoremenu Plugin.TwitVim.Post\ from\ cmdline :call twitvim#CmdLine_Twitter('', 0)<cr>

" Post current line to Twitter.
if !exists(":CPosttoTwitter")
    command CPosttoTwitter :call twitvim#post_twitter(getline('.'), 0)
endif

nnoremenu Plugin.TwitVim.Post\ current\ line :call twitvim#post_twitter(getline('.'), 0)<cr>

" Post entire buffer to Twitter.
if !exists(":BPosttoTwitter")
    command BPosttoTwitter :call twitvim#post_twitter(join(getline(1, "$")), 0)
endif

" Post visual selection to Twitter.
noremap <SID>Visual y:call twitvim#post_twitter(@", 0)<cr>
noremap <unique> <script> <Plug>TwitvimVisual <SID>Visual
if !hasmapto('<Plug>TwitvimVisual')
    vmap <unique> <A-t> <Plug>TwitvimVisual

    " Allow Ctrl-T as an alternative to Alt-T.
    " Alt-T pulls down the Tools menu if the menu bar is enabled.
    vmap <unique> <C-t> <Plug>TwitvimVisual
endif

vmenu Plugin.TwitVim.Post\ selection <Plug>TwitvimVisual

if !exists(":SetTrendLocationTwitter")
    command SetTrendLocationTwitter :call twitvim#pick_woeid()
endif

if !exists(":TrendTwitter")
    command TrendTwitter :call twitvim#Local_Trends()
endif

if !exists(":FriendsTwitter")
    command FriendsTwitter :call twitvim#get_timeline("friends", '', 1, 0)
endif
if !exists(":UserTwitter")
    command -nargs=? UserTwitter :call twitvim#get_timeline("user", <q-args>, 1, 0)
endif
if !exists(":MentionsTwitter")
    command MentionsTwitter :call twitvim#get_timeline("replies", '', 1, 0)
endif
if !exists(":RepliesTwitter")
    command RepliesTwitter :call twitvim#get_timeline("replies", '', 1, 0)
endif
if !exists(":DMTwitter")
    command DMTwitter :call twitvim#Direct_Messages("dmrecv", 1, 0)
endif
if !exists(":DMSentTwitter")
    command DMSentTwitter :call twitvim#Direct_Messages("dmsent", 1, 0)
endif
if !exists(":ListTwitter")
    command -nargs=+ ListTwitter :call twitvim#DoList(1, <f-args>)
endif
if !exists(":RetweetedByMeTwitter")
    command RetweetedByMeTwitter :call twitvim#get_timeline("retweeted_by_me", '', 1, 0)
endif
if !exists(":RetweetedToMeTwitter")
    command RetweetedToMeTwitter :call twitvim#get_timeline("retweeted_to_me", '', 1, 0)
endif
if !exists(":FavTwitter")
    command FavTwitter :call twitvim#get_timeline('favorites', '', 1, 0)
endif

nnoremenu Plugin.TwitVim.-Sep1- :
nnoremenu Plugin.TwitVim.&Friends\ Timeline :call twitvim#get_timeline("friends", '', 1, 0)<cr>
nnoremenu Plugin.TwitVim.&User\ Timeline :call twitvim#get_timeline("user", '', 1, 0)<cr>
nnoremenu Plugin.TwitVim.&Mentions\ Timeline :call twitvim#get_timeline("replies", '', 1, 0)<cr>
nnoremenu Plugin.TwitVim.&Direct\ Messages :call twitvim#Direct_Messages("dmrecv", 1, 0)<cr>
nnoremenu Plugin.TwitVim.Direct\ Messages\ &Sent :call twitvim#Direct_Messages("dmsent", 1, 0)<cr>

nnoremenu Plugin.TwitVim.Retweeted\ &By\ Me :call twitvim#get_timeline("retweeted_by_me", '', 1, 0)<cr>
nnoremenu Plugin.TwitVim.Retweeted\ &To\ Me :call twitvim#get_timeline("retweeted_to_me", '', 1, 0)<cr>
nnoremenu Plugin.TwitVim.Fa&vorites :call twitvim#get_timeline("favorites", '', 1, 0)<cr>

if !exists(":RefreshTwitter")
    command RefreshTwitter :call twitvim#RefreshTimeline()
endif
if !exists(":NextTwitter")
    command NextTwitter :call twitvim#NextPageTimeline()
endif
if !exists(":PreviousTwitter")
    command PreviousTwitter :call twitvim#PrevPageTimeline()
endif

if !exists(":SetLoginTwitter")
    command SetLoginTwitter :call twitvim#prompt_twitvim_login()
endif
if !exists(":ResetLoginTwitter")
    command ResetLoginTwitter :call twitvim#reset_twitvim_login()
endif
if !exists(':SwitchLoginTwitter')
    command -nargs=? -complete=custom,twitvim#name_list_tokens SwitchLoginTwitter :call twitvim#switch_twitvim_login(<q-args>)
endif
if !exists(':DeleteLoginTwitter')
    command -nargs=? -complete=custom,twitvim#name_list_tokens_for_del DeleteLoginTwitter :call twitvim#delete_twitvim_login(<q-args>)
endif

nnoremenu Plugin.TwitVim.-Sep2- :
nnoremenu Plugin.TwitVim.Set\ Twitter\ Login :call twitvim#prompt_twitvim_login()<cr>
nnoremenu Plugin.TwitVim.Reset\ Twitter\ Login :call twitvim#reset_twitvim_login()<cr>

if !exists(":SendDMTwitter")
    command -nargs=1 SendDMTwitter :call twitvim#send_dm(<q-args>, '')
endif

if !exists(":RateLimitTwitter")
    command RateLimitTwitter :call twitvim#get_rate_limit()
endif

" Show TwitVim version.
if !exists(":TwitVimVersion")
    command TwitVimVersion :call twitvim#show_user_agent()
endif

if !exists(":LocationTwitter")
    command -nargs=+ LocationTwitter :call twitvim#set_location(<q-args>)
endif

if !exists(":FollowTwitter")
    command -nargs=1 FollowTwitter :call twitvim#follow_user(<q-args>)
endif

if !exists(":UnfollowTwitter")
    command -nargs=1 UnfollowTwitter :call twitvim#unfollow_user(<q-args>)
endif

if !exists(":BlockTwitter")
    command -nargs=1 BlockTwitter :call twitvim#block_user(<q-args>, 0)
endif
if !exists(":UnblockTwitter")
    command -nargs=1 UnblockTwitter :call twitvim#block_user(<q-args>, 1)
endif

if !exists(":ReportSpamTwitter")
    command -nargs=1 ReportSpamTwitter :call twitvim#report_spam(<q-args>)
endif

if !exists(":EnableRetweetsTwitter")
    command -nargs=1 EnableRetweetsTwitter :call twitvim#enable_retweets(<q-args>, 1)
endif
if !exists(":DisableRetweetsTwitter")
    command -nargs=1 DisableRetweetsTwitter :call twitvim#enable_retweets(<q-args>, 0)
endif

if !exists(":AddToListTwitter")
    command -nargs=+ AddToListTwitter :call twitvim#do_add_to_list(<f-args>)
endif

if !exists(":RemoveFromListTwitter")
    command -nargs=+ RemoveFromListTwitter :call twitvim#do_remove_from_list(<f-args>)
endif

if !exists(":ProfileTwitter")
    command -nargs=? ProfileTwitter :call twitvim#get_user_info(<q-args>)
endif

if !exists(":ListInfoTwitter")
    command -nargs=+ ListInfoTwitter :call twitvim#DoListInfo(<f-args>)
endif

if !exists(":RefreshInfoTwitter")
    command RefreshInfoTwitter :call twitvim#RefreshInfo()
endif
if !exists(":NextInfoTwitter")
    command NextInfoTwitter :call twitvim#NextPageInfo()
endif
if !exists(":PreviousInfoTwitter")
    command PreviousInfoTwitter :call twitvim#PrevPageInfo()
endif

if !exists(":FollowingTwitter")
    command -nargs=? FollowingTwitter :call twitvim#do_get_friends(<q-args>, 0)
endif
if !exists(":FollowersTwitter")
    command -nargs=? FollowersTwitter :call twitvim#do_get_friends(<q-args>, 1)
endif
if !exists(":MembersOfListTwitter")
    command -nargs=+ MembersOfListTwitter :call twitvim#DoListMembers(0, <f-args>)
endif
if !exists(":SubsOfListTwitter")
    command -nargs=+ SubsOfListTwitter :call twitvim#DoListMembers(1, <f-args>)
endif
if !exists(":OwnedListsTwitter")
    command -nargs=? OwnedListsTwitter :call twitvim#get_user_lists(-1, <q-args>, "owned")
endif
if !exists(":MemberListsTwitter")
    command -nargs=? MemberListsTwitter :call twitvim#get_user_lists(-1, <q-args>, "memberships")
endif
if !exists(":SubsListsTwitter")
    command -nargs=? SubsListsTwitter :call twitvim#get_user_lists(-1, <q-args>, "subscriptions")
endif

if !exists(":FollowListTwitter")
    command -nargs=+ FollowListTwitter :call twitvim#follow_list(0, <f-args>)
endif
if !exists(":UnfollowListTwitter")
    command -nargs=+ UnfollowListTwitter :call twitvim#follow_list(1, <f-args>)
endif

if !exists(":BitLy")
    command -nargs=? BitLy :call twitvim#GetShortURL("insert", <q-args>, "call_bitly")
endif
if !exists(":ABitLy")
    command -nargs=? ABitLy :call twitvim#GetShortURL("append", <q-args>, "call_bitly")
endif
if !exists(":PBitLy")
    command -nargs=? PBitLy :call twitvim#GetShortURL("cmdline", <q-args>, "call_bitly")
endif

if !exists(":IsGd")
    command -nargs=? IsGd :call twitvim#GetShortURL("insert", <q-args>, "call_isgd")
endif
if !exists(":AIsGd")
    command -nargs=? AIsGd :call twitvim#GetShortURL("append", <q-args>, "call_isgd")
endif
if !exists(":PIsGd")
    command -nargs=? PIsGd :call twitvim#GetShortURL("cmdline", <q-args>, "call_isgd")
endif

if !exists(":Googl")
    command -nargs=? Googl :call twitvim#GetShortURL("insert", <q-args>, "call_googl")
endif
if !exists(":AGoogl")
    command -nargs=? AGoogl :call twitvim#GetShortURL("append", <q-args>, "call_googl")
endif
if !exists(":PGoogl")
    command -nargs=? PGoogl :call twitvim#GetShortURL("cmdline", <q-args>, "call_googl")
endif

if !exists(":Summize")
    command -nargs=? Summize :call twitvim#Summize(<q-args>, 1)
endif
if !exists(":SearchTwitter")
    command -nargs=? SearchTwitter :call twitvim#Summize(<q-args>, 1)
endif

let &cpo = s:save_cpo
finish

" vim:set tw=0 et:
autoload/twitvim.vim	[[[1
4933
" Load this module only once.
if exists('g:loaded_twitvim_autoload')
    finish
endif
let g:loaded_twitvim_autoload = '0.9.0 2015-04-10'

" Avoid side-effects from cpoptions setting.
let s:save_cpo = &cpo
set cpo&vim

" User agent header string.
let s:user_agent = 'TwitVim '.g:loaded_twitvim_autoload

" Twitter character limit. Twitter used to accept tweets up to 246 characters
" in length and display those in truncated form, but that is no longer the
" case. So 140 is now the hard limit.
let s:char_limit = 140


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
    return get(g:, 'twitvim_net_timeout', 0)
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg('Error verifying login credentials: '.(errormsg != '' ? errormsg : error))
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

digest = OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), key, str)
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
    let output = system('openssl dgst -binary -sha1 -hmac "'.a:key.'" | openssl base64', a:str)
    if v:shell_error != 0
        call s:errormsg("Error running openssl command: ".output)
        return ""
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

    let [error, output] = s:run_curl(req_url, oauth_hdr, s:get_proxy(), s:get_proxy_login(), { "dummy" : "1" })

    if error != ''
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

    let [error, output] = s:run_curl(access_url, oauth_hdr, s:get_proxy(), s:get_proxy_login(), { "dummy" : 1 })

    if error != ''
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

" Use curl to fetch a web page.
function! s:curl_curl(url, login, proxy, proxylogin, parms)
    let error = ""
    let output = ""

    let curlcmd = "curl -s -S "

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
            let curlcmd .= '-H "Authorization: '.a:login.'" '
        elseif stridx(a:login, ':') != -1
            let curlcmd .= '-u "'.a:login.'" '
        else
            let curlcmd .= '-H "Authorization: Basic '.a:login.'" '
        endif
    endif

    let got_json = 0
    for [k, v] in items(a:parms)
        if k == '__json'
            let got_json = 1
            let vsub = substitute(v, '"', '\\"', 'g')
            if  has('win32') || has('win64')
                " Under Windows only, we need to quote some special characters.
                let vsub = substitute(vsub, '[\\&|><^]', '"&"', 'g')
            endif
            let curlcmd .= '-d "'.vsub.'" '
        else
            let curlcmd .= '-d "'.s:url_encode(k).'='.s:url_encode(v).'" '
        endif
    endfor

    if got_json
        let curlcmd .= '-H "Content-Type: application/json" '
    endif
    
    let curlcmd .= '-H "User-Agent: '.s:user_agent.'" '

    let curlcmd .= '"'.a:url.'"'

    let output = system(curlcmd)
    let errormsg = s:xml_get_element(output, 'error')
    if v:shell_error != 0
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
        req.set_proxy(proxy, 'http')

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
function! s:get_short_url_lengths()
    let now = localtime()
    " Do the config query the first time it is needed and once a day thereafter.
    if s:short_url_length == 0 || s:short_url_length_https == 0 || now - s:last_config_query_time > 24 * 60 * 60
        let url = s:get_api_root().'/help/configuration.json'
        let [error, output] = s:run_curl_oauth_get(url, {})
        let result = s:parse_json(output)
        if error == ''
            let s:short_url_length = get(result, 'short_url_length', 0)
            let s:short_url_length_https = get(result, 'short_url_length_https', 0)
            let s:last_config_query_time = now
        endif
    endif
    return [ s:short_url_length, s:short_url_length_https ]
endfunction

" Simulate Twitter's URL shortener by replacing any matching URLs with dummy strings.
function! s:sim_shorten_urls(mesg)
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

    " Convert internal newlines to spaces.
    let mesg = substitute(mesg, '\n', ' ', "g")

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
        let result = s:parse_json(output)

        if error != ''
            let errormsg = get(result, 'error', '')
            call s:errormsg("Error posting your tweet: ".(errormsg != '' ? errormsg : error))
        else
            call s:add_update(result)
            redraw
            echo "Your tweet was sent. You used ".mesglen." characters."
        endif
    endif
endfunction

function! twitvim#post_twitter(mesg, inreplyto)
    call post_twitter(a:mesg, a:inreplyto)
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error retweeting: ".(errormsg != '' ? errormsg : error))
    else
        call s:add_update(result)
        redraw
        echo "Retweeted."
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting in-reply-to tweet: ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error deleting ".obj.": ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error ".(a:unfave ? 'unfavoriting' : 'favoriting')." the tweet: ".(errormsg != '' ? errormsg : error))
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
    let endcmd = has('unix') ? '> /dev/null &' : ''

    " Escape characters that have special meaning in the :! command.
    let url = substitute(a:url, '!\|#\|%', '\\&', 'g')

    " Escape the '&' character under Unix. This character is valid in URLs but
    " causes the shell to background the process and cut off the URL at that
    " point.
    if has('unix')
        let url = substitute(url, '&', '\\&', 'g')
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
    " non-word character.
    let matchres = matchlist(s, '\w\@<!\(#\w\+\)')
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
    if error != ''
        call s:errormsg("Error calling LongURL API: ".error)
        return ""
    else
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
    endif
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
        " non-word character.
        syntax match twitterLink "\w\@<!#\w\+"

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
        execute "new " . winname
        setlocal noswapfile
        setlocal buftype=nofile
        setlocal bufhidden=delete 
        setlocal foldcolumn=0
        setlocal nobuflisted
        setlocal nospell

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
    let result = s:parse_json(output)

    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting ".tl_name." timeline: ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)

    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting list timeline: ".(errormsg != '' ? errormsg : error))
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

    " Support count parameter.
    let tcount = s:get_count()
    if tcount > 0
        let parms.count = tcount
    endif

    let [error, output] = s:run_curl_oauth_get(url, parms)
    let result = s:parse_json(output)

    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting direct messages ".s_or_r." timeline: ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error retrieving list of WOEIDs: ".(errormsg != '' ? errormsg : error))
        return {}
    endif

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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error retrieving trending topics: ".(errormsg != '' ? errormsg : error))
        return {}
    endif

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
    if mesglen > s:char_limit
        call s:warnmsg("Your message has ".(mesglen - s:char_limit)." too many characters. It was not sent.")
    elseif mesglen < 1
        call s:warnmsg("Your message was empty. It was not sent.")
    else
        redraw
        echo "Sending message to ".a:user."..."

        let url = s:get_api_root()."/direct_messages/new.json"
        let parms = { "source" : "twitvim", "user" : a:user, "text" : mesg }

        let [error, output] = s:run_curl_oauth_post(url, parms)
        let result = s:parse_json(output)

        if error != ''
            let errormsg = get(result, 'error', '')
            call s:errormsg("Error sending your message: ".(errormsg != '' ? errormsg : error))
        else
            redraw
            echo "Your message was sent to ".a:user.". You used ".mesglen." characters."
        endif
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting rate limit info: ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error setting location: ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting friendship info: ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error following user: ".(errormsg != '' ? errormsg : error))
    else
        let protected = get(result, 'protected')
        redraw
        if protected
            echo "Made request to follow ".a:user."'s protected timeline."
        else
            echo "Now following ".a:user."'s timeline."
        endif
    endif
endfunction

" Stop following a user.
function! twitvim#unfollow_user(user)
    redraw
    echo "Unfollowing user ".a:user."..."

    let url = s:get_api_root()."/friendships/destroy.json"
    let [error, output] = s:run_curl_oauth_post(url, { "screen_name" : a:user })
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error unfollowing user: ".(errormsg != '' ? errormsg : error))
    else
        redraw
        echo "Stopped following ".a:user."'s timeline."
    endif
endfunction

" Block a user.
function! twitvim#block_user(user, unblock)
    redraw
    echo (a:unblock ? "Unblocking" : "Blocking")." user ".a:user."..."

    let url = s:get_api_root()."/blocks/".(a:unblock ? "destroy" : "create").".json"
    let [error, output] = s:run_curl_oauth_post(url, { 'screen_name' : a:user })
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error ".(a:unblock ? "unblocking" : "blocking")." user: ".(errormsg != '' ? errormsg : error))
    else
        redraw
        echo "User ".a:user." is now ".(a:unblock ? "unblocked" : "blocked")."."
    endif
endfunction

" Report user for spam.
function! twitvim#report_spam(user)
    redraw
    echo "Reporting ".a:user." for spam..."

    let url = s:get_api_root()."/users/report_spam.json"
    let [error, output] = s:run_curl_oauth_post(url, { 'screen_name' : a:user })
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error reporting user for spam: ".(errormsg != '' ? errormsg : error))
    else
        redraw
        echo "Reported user ".a:user." for spam."
    endif
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error ".msg3." retweets from user: ".(errormsg != '' ? errormsg : error))
    else
        redraw
        echo msg2." retweets from user ".a:user."."
    endif
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error ".(a:remove ? "removing user from" : "adding user to")." list: ".(errormsg != '' ? errormsg : error))
    else
        redraw
        if a:remove
            echo "Removed ".a:username." from list ".a:listname."."
        else
            echo "Added ".a:username." to list ".a:listname."."
        endif
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting user info: ".(errormsg != '' ? errormsg : error))
        return
    endif

    let url = s:get_api_root()."/friendships/show.json"
    let [error, fship_output] = s:run_curl_oauth_get(url, { 'target_screen_name' : user })
    let fship_result = s:parse_json(fship_output)
    if error != ''
        let errormsg = get(fship_result, 'error', '')
        call s:errormsg("Error getting friendship info: ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg('Error getting information on list '.user.'/'.list.': '.(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg('Error getting '.what.': '.(errormsg != '' ? errormsg : error))
        return {}
    endif
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg('Error getting friends/followers info: '.(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting ".item.": ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error getting user's ".item.": ".(errormsg != '' ? errormsg : error))
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
    let result = s:parse_json(output)
    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error ".v2." list: ".(errormsg != '' ? errormsg : error))
    else
        redraw
        echo v3." list ".user."/".list."."
    endif
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

    if error != '' || status_code != 200
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

    let url = 'http://is.gd/api.php?longurl='.s:url_encode(a:url)
    let [error, output] = s:run_curl(url, '', s:get_proxy(), s:get_proxy_login(), {})

    if error != ''
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

    if error != ''
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

    let result = s:parse_json(output)

    if error != ''
        let errormsg = get(result, 'error', '')
        call s:errormsg("Error querying Search: ".(errormsg != '' ? errormsg : error))
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
doc/twitvim.txt	[[[1
2011
*twitvim.txt*  Twitter client for Vim

		      ---------------------------------
		      TwitVim: A Twitter client for Vim
		      ---------------------------------

Author: Po Shan Cheah <morton@mortonfox.com> 
	http://twitter.com/mortonfox

License: The Vim License applies to twitvim.vim and twitvim.txt (see
	|copyright|) except use "TwitVim" instead of "Vim". No warranty,
	express or implied. Use at your own risk.


==============================================================================
1. Contents					*TwitVim* *TwitVim-contents*

	1. Contents...............................: |TwitVim-contents|
	2. Introduction...........................: |TwitVim-intro|
	3. Installation...........................: |TwitVim-install|
	   OpenSSL................................: |TwitVim-OpenSSL|
	   cURL...................................: |TwitVim-cURL|
	   twitvim_proxy..........................: |twitvim_proxy|
	   twitvim_proxy_login....................: |twitvim_proxy_login|
	3.1. TwitVim and OAuth....................: |TwitVim-OAuth|
	     twitvim_token_file...................: |twitvim_token_file|
	     twitvim_disable_token_file...........: |twitvim_disable_token_file|
	3.1.1. OAuth Consumer Key.................: |TwitVim-OAuth-Consumer|
	       twitvim_consumer_key...............: |twitvim_consumer_key|
	       twitvim_consumer_secret............: |twitvim_consumer_secret|
	3.2. Base64-Encoded Login.................: |TwitVim-login-base64|
	     twitvim_proxy_login_b64..............: |twitvim_proxy_login_b64|
	3.3. Alternatives to cURL.................: |TwitVim-non-cURL|
	     twitvim_enable_perl..................: |twitvim_enable_perl|
	     twitvim_enable_python................: |twitvim_enable_python|
	     twitvim_enable_ruby..................: |twitvim_enable_ruby|
	     twitvim_enable_tcl...................: |twitvim_enable_tcl|
	3.4. Using Twitter SSL API................: |TwitVim-ssl|
	     Twitter SSL via cURL.................: |TwitVim-ssl-curl|
	     twitvim_cert_insecure................: |twitvim_cert_insecure|
	     Twitter SSL via Perl interface.......: |TwitVim-ssl-perl|
	     Twitter SSL via Ruby interface.......: |TwitVim-ssl-ruby|
	     Twitter SSL via Python interface.....: |TwitVim-ssl-python|
	     Twitter SSL via Tcl interface........: |TwitVim-ssl-tcl|
	3.5. Hide the header in timeline buffer...: |TwitVim-hide-header|
	     twitvim_show_header..................: |twitvim_show_header|
	3.6. Timeline filtering...................: |TwitVim-filter|
	     twitvim_filter_enable................: |twitvim_filter_enable|
	     twitvim_filter_regex.................: |twitvim_filter_regex|
	3.7. Preventing Loading...................: |TwitVim-noload|
	4. Manual.................................: |TwitVim-manual|
	4.1. TwitVim's Buffers....................: |TwitVim-buffers|
	     twitvim_timestamp_format.............: |twitvim_timestamp_format|
	4.2. Update Commands......................: |TwitVim-update-commands|
	     :PosttoTwitter.......................: |:PosttoTwitter|
	     :CPosttoTwitter......................: |:CPosttoTwitter|
	     :BPosttoTwitter......................: |:BPosttoTwitter|
	     :SendDMTwitter.......................: |:SendDMTwitter|
	4.3. Timeline Commands....................: |TwitVim-timeline-commands|
	     :UserTwitter.........................: |:UserTwitter|
	     twitvim_count........................: |twitvim_count|
	     :FriendsTwitter......................: |:FriendsTwitter|
	     :MentionsTwitter.....................: |:MentionsTwitter|
	     :RepliesTwitter......................: |:RepliesTwitter|
	     :DMTwitter...........................: |:DMTwitter|
	     :DMSentTwitter.......................: |:DMSentTwitter|
	     :ListTwitter.........................: |:ListTwitter|
	     :RetweetedToMeTwitter................: |:RetweetedToMeTwitter|
	     :RetweetedByMeTwitter................: |:RetweetedByMeTwitter|
	     :FavTwitter..........................: |:FavTwitter|
	     :FollowingTwitter....................: |:FollowingTwitter|
	     :FollowersTwitter....................: |:FollowersTwitter|
	     :ListInfoTwitter.....................: |:ListInfoTwitter|
	     :MembersOfListTwitter................: |:MembersOfListTwitter|
	     :SubsOfListTwitter...................: |:SubsOfListTwitter|
	     :OwnedListsTwitter...................: |:OwnedListsTwitter|
	     :MemberListsTwitter..................: |:MemberListsTwitter|
	     :SubsListsTwitter....................: |:SubsListsTwitter|
	     :FollowListTwitter...................: |:FollowListTwitter|
	     :UnfollowListTwitter.................: |:UnfollowListTwitter|
	     :BackTwitter.........................: |:BackTwitter|
	     :BackInfoTwitter.....................: |:BackInfoTwitter|
	     :ForwardTwitter......................: |:ForwardTwitter|
	     :ForwardInfoTwitter..................: |:ForwardInfoTwitter|
	     :RefreshTwitter......................: |:RefreshTwitter|
	     :RefreshInfoTwitter..................: |:RefreshInfoTwitter|
	     :NextTwitter.........................: |:NextTwitter|
	     :NextInfoTwitter.....................: |:NextInfoTwitter|
	     :PreviousTwitter.....................: |:PreviousTwitter|
	     :PreviousInfoTwitter.................: |:PreviousInfoTwitter|
	     :SetLoginTwitter.....................: |:SetLoginTwitter|
	     :SwitchLoginTwitter..................: |:SwitchLoginTwitter|
	     :DeleteLoginTwitter..................: |:DeleteLoginTwitter|
	     :ResetLoginTwitter...................: |:ResetLoginTwitter|
	     :FollowTwitter.......................: |:FollowTwitter|
	     :UnfollowTwitter.....................: |:UnfollowTwitter|
	     :BlockTwitter........................: |:BlockTwitter|
	     :UnblockTwitter......................: |:UnblockTwitter|
	     :EnableRetweetsTwitter...............: |:EnableRetweetsTwitter|
	     :DisableRetweetsTwitter..............: |:DisableRetweetsTwitter|
	     :ReportSpamTwitter...................: |:ReportSpamTwitter|
	     :AddToListTwitter....................: |:AddToListTwitter|
	     :RemoveFromListTwitter...............: |:RemoveFromListTwitter|
	4.4. Mappings.............................: |TwitVim-mappings|
	     Alt-T................................: |TwitVim-A-t|
	     Ctrl-T...............................: |TwitVim-C-t|
	     Reply Feature........................: |TwitVim-reply|
	     Alt-R................................: |TwitVim-A-r|
	     <Leader>r............................: |TwitVim-Leader-r|
	     Reply to all Feature.................: |TwitVim-reply-all|
	     <Leader>Ctrl-R.......................: |TwitVim-Leader-C-r|
	     Retweet Feature......................: |TwitVim-retweet|
	     <Leader>R............................: |TwitVim-Leader-S-r|
	     Old-style retweets...................: |twitvim_old_retweet|
	     twitvim_retweet_format...............: |twitvim_retweet_format|
	     Direct Message Feature...............: |TwitVim-direct-message|
	     Alt-D................................: |TwitVim-A-d|
	     <Leader>d............................: |TwitVim-Leader-d|
	     Goto Feature.........................: |TwitVim-goto|
	     Alt-G................................: |TwitVim-A-g|
	     <Leader>g............................: |TwitVim-Leader-g|
	     twitvim_browser_cmd..................: |twitvim_browser_cmd|
	     LongURL Feature......................: |TwitVim-LongURL|
	     <Leader>e............................: |TwitVim-Leader-e|
	     User Profiles........................: |TwitVim-profile|
	     <Leader>p............................: |TwitVim-Leader-p|
	     In-reply-to..........................: |TwitVim-inreplyto|
	     <Leader>@............................: |TwitVim-Leader-@|
	     Delete...............................: |TwitVim-delete|
	     <Leader>X............................: |TwitVim-Leader-X|
	     <Leader>f............................: |TwitVim-Leader-f|
	     <Leader>Ctrl-F.......................: |TwitVim-Leader-C-f|
	     Ctrl-O...............................: |TwitVim-C-o|
	     Ctrl-I...............................: |TwitVim-C-i|
	     Refresh..............................: |TwitVim-refresh|
	     <Leader><Leader>.....................: |TwitVim-Leader-Leader|
	     Next page............................: |TwitVim-next|
	     Ctrl-PageDown........................: |TwitVim-C-PageDown|
	     Previous page........................: |TwitVim-previous|
	     Ctrl-PageUp..........................: |TwitVim-C-PageUp|
	4.5. Utility Commands.....................: |TwitVim-utility|
	     :BitLy...............................: |:BitLy|
	     twitvim_bitly_key....................: |twitvim_bitly_key|
	     :ABitLy..............................: |:ABitLy|
	     :PBitLy..............................: |:PBitLy|
	     :IsGd................................: |:IsGd|
	     :AIsGd...............................: |:AIsGd|
	     :PIsGd...............................: |:PIsGd|
	     :Googl...............................: |:Googl|
	     :AGoogl..............................: |:AGoogl|
	     :PGoogl..............................: |:PGoogl|
	     :SearchTwitter.......................: |:SearchTwitter|
	     :RateLimitTwitter....................: |:RateLimitTwitter|
	     :ProfileTwitter......................: |:ProfileTwitter|
	     :LocationTwitter.....................: |:LocationTwitter|
	     :TrendTwitter........................: |:TrendTwitter|
	     :SetTrendLocationTwitter.............: |:SetTrendLocationTwitter|
	     twitvim_woeid........................: |twitvim_woeid|
	5. Timeline Highlighting..................: |TwitVim-highlight|
	   twitterUser............................: |hl-twitterUser|
	   twitterTime............................: |hl-twitterTime|
	   twitterTitle...........................: |hl-twitterTitle|
	   twitterLink............................: |hl-twitterLink|
	   twitterReply...........................: |hl-twitterReply|
	6. Tips and Tricks........................: |TwitVim-tips|
	6.1. Timeline Hotkeys.....................: |TwitVim-hotkeys|
	6.2. Line length in status line...........: |TwitVim-line-length|
	6.3. Network timeout......................: |TwitVim-network-timeout|
	7. History................................: |TwitVim-history|
	8. Credits................................: |TwitVim-credits|


==============================================================================
2. Introduction						*TwitVim-intro*

	TwitVim is a plugin that allows you to post to Twitter, a
	microblogging service at http://www.twitter.com.


==============================================================================
3. Installation						*TwitVim-install*

	
	1. Install OpenSSL or compile Vim with |Python|, |Perl|, |Ruby|, or |Tcl|.

	In order to compute HMAC-SHA1 digests and sign Twitter OAuth requests,
	TwitVim needs to either run the openssl command line tool from the
	OpenSSL toolkit or call a HMAC-SHA1 digest function via one of the
	above scripting interfaces.

	
							*TwitVim-OpenSSL*
	If you are using a precompiled Vim executable and do not wish to
	recompile Vim to add a scripting interface, then the OpenSSL approach
	is the simplest.

	If OpenSSL is not already on your system, you can download it from
	http://openssl.org/  If you are using Windows, check the OpenSSL FAQ
	for a link to a precompiled OpenSSL for Windows.

	After installing OpenSSL, make sure that the directory where the
	openssl executable resides is listed in your PATH environment
	variable so that TwitVim can find it.

	Note: TwitVim uses the openssl -hmac option, which is not available in
	old versions of OpenSSL. I recommend updating to OpenSSL 0.9.8o,
	1.0.0a, or later to get the -hmac option and the latest security
	fixes.


	Instead of using the openssl command line tool, you can also have
	TwitVim compute HMAC-SHA1 digests via a Vim scripting interface. This
	approach is significantly faster because it does not need to run an
	external program. You can use Perl, Python, Python 3, Ruby, or Tcl.

	Note: Additional setup may be needed on some systems to enable SSL,
	which we now require for security during the OAuth handshake. See
	|TwitVim-ssl|.


	If you compiled Vim with Perl, add the following to your vimrc:
>
		let twitvim_enable_perl = 1
<
	Also, verify that your Perl installation has the Digest::HMAC_SHA1
	module. This module comes standard in some Perl distributions, e.g.
	ActivePerl. In other Perl setups, you'll need to download and install
	Digest::HMAC_SHA1 from CPAN. The Perl Package Manager PPM may be
	helpful here.


	If you compiled Vim with Python, add the following to your vimrc:
>
		let twitvim_enable_python = 1
<
	Also, verify that your Python installation has the base64, hashlib,
	and hmac modules. All of these are in the Python standard library as
	of Python 2.5.

	If you compiled Vim with Python 3, add the following to your vimrc
	instead:
>
		let twitvim_enable_python3 = 1
<


	If you compiled Vim with Ruby, add the following to your vimrc:
>
		let twitvim_enable_ruby = 1
<
	TwitVim requires the openssl and base64 modules, both of which are
	in the Ruby standard library. However, you may need to install the
	OpenSSL library from http://www.openssl.org if it is not already on
	your system.


	If you compiled Vim with Tcl, add the following to your vimrc:
>
		let twitvim_enable_tcl = 1
<
	Also, verify that your Tcl installation has the base64 and sha1
	packages. These packages are in the Tcllib library. See
	|twitvim_enable_tcl| for help on obtaining and installing this
	library.


	2. Install cURL.				*TwitVim-cURL*

	If you don't already have cURL on your system, download it from
	http://curl.haxx.se/. Make sure that the curl executable is in a
	directory listed in your PATH environment variable, or the equivalent
	for your system.

	If you have already compiled Vim with Perl, Python, Python 3, Ruby, or
	Tcl for Step 1, I recommend that you use the scripting interface
	instead of installing cURL. See |TwitVim-non-cURL| for setup details.
	Using a scripting interface for network I/O is faster because it
	avoids the overhead of running an external program.


	3. twitvim_proxy				*twitvim_proxy*

	This step is only needed if you access the web through a HTTP proxy.
	If you use a HTTP proxy, add the following to your vimrc:
>
		let twitvim_proxy = "proxyserver:proxyport"
<
	Replace proxyserver with the address of the HTTP proxy and proxyport
	with the port number of the HTTP proxy.


	4. twitvim_proxy_login				*twitvim_proxy_login*

	If the HTTP proxy requires authentication, add the following to your
	vimrc:
>
		let twitvim_proxy_login = "proxyuser:proxypassword"
<
	Where proxyuser is your proxy user and proxypassword is your proxy
	password.

	It is possible to avoid having your proxy password in plaintext in
	your vimrc. See |TwitVim-login-base64| for details.


	5. Set twitvim_browser_cmd.

	In order to log in with Twitter OAuth, TwitVim needs to launch your
	web browser and bring up the Twitter authentication web page.

	See |twitvim_browser_cmd| for details. For example, if you use Firefox
	under Windows, add the following to your vimrc:
>
		let twitvim_browser_cmd = 'firefox.exe'
<
	Under Mac OS X, the following will use the default browser:
>
		let twitvim_browser_cmd = 'open'
<
	Note: If you do not set up twitvim_browser_cmd, TwitVim will display
	the authentication URL and wait for you to visit it in your browser
	manually and approve the application. If possible, this auth URL
	will be shortened with is.gd or Bit.ly for ease of entry.


	6. SSL prerequisites

	The Twitter API requires SSL. On most system setups, this should
	not be a problem but if you are having trouble connecting to
	Twitter with TwitVim, see |TwitVim-ssl| for instructions and
	prerequisites.


	7. Sign into Twitter with OAuth.

	Use any TwitVim command that requires authentication. For example,
	run |:FriendsTwitter|. |:SetLoginTwitter| is the normal way to
	initiate authentication without running a timeline command.

	Since TwitVim does not yet have an OAuth access token, it will
	initiate the Twitter OAuth handshake. Then it'll launch your web
	browser to a special Twitter web page that asks you to authorize
	TwitVim to use your account. On this page, sign in, if necessary,
	and then click on "Authorize app" to allow TwitVim access to your
	account.

	Twitter will then report that you have granted access to TwitVim
	and display a numeric PIN. Copy the PIN and paste it to the TwitVim
	input prompt "Enter OAuth PIN:".

	And now, you are ready to use TwitVim.


------------------------------------------------------------------------------
3.1. TwitVim and OAuth					*TwitVim-OAuth*

	After you log into Twitter with OAuth, TwitVim stores the OAuth
	access token in a file so that you won't have to log in again when
	you restart TwitVim. By default, this file is $HOME/.twitvim.token

						*twitvim_token_file*
	You can change the name and location of this token file by setting
	twitvim_token_file in your vimrc. For example:
>
		let twitvim_token_file = "/etc/.twitvim.token"
<
	Since the access token grants full access to your Twitter account,
	it is recommended that you place the token file in a directory that
	is not readable or accessible by other users.


						*twitvim_disable_token_file*
	If you are using TwitVim on an insecure system, you may prefer to 
	not save access tokens at all. To turn off the token file, add
	the following to your vimrc:
>
		let twitvim_disable_token_file = 1
<
	If the token file is disabled, TwitVim will initiate an OAuth
	handshake every time you restart it.


	If TwitVim is logged in and you need to log in as a different
	Twitter user:
	 - Visit the Twitter website in a web browser
	 - Sign out and then sign in as the other user.
	 - Then use |:SetLoginTwitter| to authenticate as that user.


------------------------------------------------------------------------------
3.1.1. OAuth Consumer Key			*TwitVim-OAuth-Consumer*

						*twitvim_consumer_key*
						*twitvim_consumer_secret*
	TwitVim comes with a default consumer key and secret pair. If you wish
	to use your own, add the following to your vimrc:
>
		let twitvim_consumer_key = "key"
		let twitvim_consumer_secret = "secret"
<
	where "key" and "secret" are consumer key and secret strings from the
	"My applications" section of the Twitter developers website after you
	have registered a Twitter application.

	The process of registering a Twitter application has changed from time
	to time. Currently, the steps are as follows:

	1. Go to https://dev.twitter.com/apps/new and fill in the details. Use
	anything you like for name, description, and website. Read and agree
	to the developer rules. No callback URL is needed.

	2. The Consumer key and secret are on the next screen under "OAuth
	settings". Add these strings to your vimrc.

	3. Go to the Settings tab. Select "Read, Write and Access direct
	messages" under Application Type / Access. Then click on "Update this
	Twitter application's settings". These permissions are required by
	TwitVim.


------------------------------------------------------------------------------
3.2. Base64-Encoded Login				*TwitVim-login-base64*

	For safety purposes, TwitVim allows you to configure your proxy
	login information preencoded in Base64. This is not truly secure as
	it is not encryption but it can stop casual onlookers from reading
	off your password when you edit your vimrc.

						*twitvim_proxy_login_b64*
	To configure the proxy login in base64, add the following to your
	vimrc:
>
		let twitvim_proxy_login_b64 = "base64string"
<
	Where base64string is your username:password encoded in Base64.


	An example:

	Let's say your HTTP proxy requires a login user name of "proxyuser"
	and a password of "proxypassword". So you need to encode
	"proxyuser:proxypassword" in Base64. You can either use a
	standalone utility or websites like the following:
	http://www.motobit.com/util/base64-decoder-encoder.asp
	http://www.opinionatedgeek.com/DotNet/Tools/Base64Encode/default.aspx
	http://www.base64encode.org/

	The result is: cHJveHl1c2VyOnByb3h5cGFzc3dvcmQ=

	Then you can add the following to your vimrc:
>
		let twitvim_login_b64 = "cHJveHl1c2VyOnByb3h5cGFzc3dvcmQ="
<
	And your setup is ready.


------------------------------------------------------------------------------
3.3. Alternatives to cURL				*TwitVim-non-cURL*

	TwitVim supports http networking through Vim's |Perl|, |Python|,
	|Ruby|, and |Tcl| interfaces, so if you have any of those interfaces
	compiled into your Vim program, you can use that instead of cURL.
	
	Generally, it is slightly faster to use one of those scripting
	interfaces for networking because it avoids running an external
	program. On Windows, it also avoids a brief taskbar flash when cURL
	runs.

	To find out if you have those interfaces, use the |:version| command
	and check the |+feature-list|. Then to enable this special http
	networking code in TwitVim, add one of the following lines to your
	vimrc:
>
		let twitvim_enable_perl = 1
		let twitvim_enable_python = 1
		let twitvim_enable_python3 = 1
		let twitvim_enable_ruby = 1
		let twitvim_enable_tcl = 1
<
	You can enable more than one scripting language but TwitVim will only
	use the first one it finds.


	1. Perl interface				*twitvim_enable_perl*

	To enable TwitVim's Perl networking code, add the following to your
	vimrc:
>
		let twitvim_enable_perl = 1
<
	TwitVim requires the MIME::Base64 and LWP::UserAgent modules. If you
	have ActivePerl, these modules are included in the default
	installation.


	2. Python interface				*twitvim_enable_python*
							*twitvim_enable_python3*

	To enable TwitVim's Python networking code, add the following to your
	vimrc:
>
		let twitvim_enable_python = 1
<
	TwitVim requires the urllib, urllib2, and base64 modules. These
	modules are in the Python standard library.

	If Vim is using Python 3, add the following to your vimrc instead:
>
		let twitvim_enable_python3 = 1
<
	For Python 3, TwitVim requires the urllib, socket, and base64 modules.
	These modules are in the Python 3 standard library.


	3. Ruby interface				*twitvim_enable_ruby*

	To enable TwitVim's Ruby networking code, add the following to your
	vimrc:
>
		let twitvim_enable_ruby = 1
<
	TwitVim requires the net/http, uri, and Base64 modules. These modules
	are in the Ruby standard library.

	In addition, TwitVim requires Vim 7.2.360 or later to fix an if_ruby
	problem with Windows sockets.

	Alternatively, you can add the following patch to the Vim sources:

	http://www.mail-archive.com/vim_dev@googlegroups.com/msg03693.html

	See also Bram's correction to the patch:

	http://www.mail-archive.com/vim_dev@googlegroups.com/msg03713.html


	3. Tcl interface				*twitvim_enable_tcl*

	To enable TwitVim's Tcl networking code, add the following to your
	vimrc:
>
		let twitvim_enable_tcl = 1
<
	TwitVim requires the http, uri, and base64 packages. uri and base64
	are in the Tcllib library so you may need to install that. See
	http://tcllib.sourceforge.net/

	If you have ActiveTcl 8.5, the default installation does not include
	Tcllib. Run the following command from the shell to add Tcllib:
>
		teacup install tcllib85
<

------------------------------------------------------------------------------
3.4. Using Twitter SSL API				*TwitVim-ssl*

	On most up-to-date systems, you should be able to use SSL with no
	problems. In case you do run into problems, I review the
	prerequisites below.


	1. SSL via cURL					*TwitVim-ssl-curl*

	To use SSL via cURL, you need to install the SSL libraries and an
	SSL-enabled build of cURL.

							*twitvim_cert_insecure*
	Even after you've done that, cURL may complain about certificates that
	failed verification. If you need to override certificate checking, set
	twitvim_cert_insecure:
>
		let twitvim_cert_insecure = 1
<

	2. SSL via Perl interface			*TwitVim-ssl-perl*

	To use SSL via the TwitVim Perl interface (See |twitvim_enable_perl|),
	you need to install the SSL libraries and the Crypt::SSLeay Perl
	module.

	If you are using SSL over a proxy, do not set twitvim_proxy and
	twitvim_proxy_login. Crypt::SSLeay gets proxy information from the
	environment, so add this to your vimrc instead:
>
		let $HTTPS_PROXY="http://proxyserver:proxyport"
		let $HTTPS_PROXY_USERNAME="user"
		let $HTTPS_PROXY_PASSWORD="password"
<
	Alternatively, you can set these environment variables before starting
	Vim.


	3. SSL via Ruby interface			*TwitVim-ssl-ruby*

	To use SSL via Ruby, you need to install the SSL libraries and an
	SSL-enabled build of Ruby.

	If Ruby produces the error "`write': Bad file descriptor" in http.rb,
	then you need to check your certificates or override certificate
	checking. See |twitvim_cert_insecure|.

	Set twitvim_proxy and twitvim_proxy_login as usual if using SSL over a
	proxy.


	4. SSL via Python interface			*TwitVim-ssl-python*

	To use SSL via Python, you need to install the SSL libraries and an
	SSL-enabled build of Python.

	The Python interface does not yet support SSL over a proxy. This is
	due to a missing feature in urllib2.


	5. SSL via Tcl interface			*TwitVim-ssl-tcl*

	To use SSL via Tcl, you need to install the SSL libraries and Tcllib.
	To be more specific, TwitVim needs the tls package from Tcllib.

	Versions of Vim up to 7.3.450 have a bug that prevents the tls package
	from being loaded if you compile Vim with Tcl 8.5. This discussion
	thread explains the problem:
>
	http://objectmix.com/tcl/15892-tcl-interp-inside-vim-throws-error-w-clock-format.html
<
	If you need to use Twitter SSL with the Tcl interface, you can try one
	of the following workarounds:

	a. Upgrade Vim to version 7.3.451 or later.
	b. Downgrade Tcl to Tcl 8.4.
	c. Edit if_tcl.c in the Vim source code to remove the redefinition of
	catch. Then rebuild Vim.


------------------------------------------------------------------------------
3.5. Hide the header in timeline and info buffers	*TwitVim-hide-header*

	In the timeline and info buffers, the first two lines are header
	lines. The first line tells you the type of buffer it is (e.g.
	friends, user, replies, direct messages, search in the timeline
	buffer; friends, followers, user profile in the info buffer) and other
	relevant buffer information. (e.g. user name, search terms, page
	number) The second line is a separator line.

	If you wish to suppress the header display, set twitvim_show_header
	to 0:

							*twitvim_show_header*
>
		let twitvim_show_header = 0
<
	If twitvim_show_header is unset, it defaults to 1, i.e. show the
	header.

	Note: Setting twitvim_show_header does not change the timeline buffer
	immediately. Use |:RefreshTwitter| to refresh the timeline (or
	|:RefreshInfoTwitter| to refresh the info buffer) to see the
	effect. Also, twitvim_show_header does not retroactively alter
	previous timelines in the timeline stack.


------------------------------------------------------------------------------
3.6. Timeline filtering					*TwitVim-filter*

	TwitVim allows you to filter your timeline buffer to hide tweets
	containing a pattern.

	To enable timeline filtering, set twitvim_filter_enable to 1:

							*twitvim_filter_enable*
>
		let twitvim_filter_enable = 1
<
	Then set twitvim_filter_regex to the pattern you wish to filter out of
	the timeline. For example, to hide GetGlue tweets and tweets
	containing Youtube URLs, use the following:

							*twitvim_filter_regex*
>
		let twitvim_filter_regex = '@GetGlue\|/youtu\.be/'
<
	The filter is a regular expression. See |pattern| for patterns that
	are accepted. The |'ignorecase'| option sets the ignore-caseness of
	the pattern. |'smartcase'| is not used. The matching is always done
	like 'magic' is set and 'cpoptions' is empty. (Essentially, this is
	the same as |match()| because that is what it uses.)

	Be as specific as possible when setting the filter. For example, if
	you filter on "youtube", you are potentially also filtering out
	conversations about Youtube in addition to Youtube status updates.

	Timeline filtering removes tweets from your timeline, so the timeline
	display may be shorter than usual. Increase |twitvim_count| to
	compensate, if necessary.


------------------------------------------------------------------------------
3.7. Preventing Loading					*TwitVim-noload*

	If you have TwitVim installed but for some reason don't wish to run
	it, then you can avoid loading the plugin by adding the following
	to your vimrc:
>
		let loaded_twitvim = 1
<

==============================================================================
4. TwitVim Manual					*TwitVim-manual*

------------------------------------------------------------------------------
4.1. TwitVim's Buffers					*TwitVim-buffers*

	TwitVim has 2 buffers, a timeline buffer and an info buffer.

	Commands such as |:FriendsTwitter|, |:MentionsTwitter|, |:DMTwitter|,
	and |:ListTwitter| bring up a timeline buffer. This buffer consists of
	a list of tweets or messages. See |TwitVim-mappings| for a list of
	mappings that are local to this buffer.

	Commands such as |:ProfileTwitter|, |:FollowingTwitter|,
	|:FollowersTwitter|, and |:OwnedListsTwitter| bring up an info buffer.
	This buffer may consist of a list of users or a list of Twitter lists.
	In the case of |:ProfileTwitter|, it is a list of fields from one user
	profile. Only a subset of the mappings in |:TwitVim-mappings| will
	work in the info buffer.

	TwitVim splits the window and opens a new timeline buffer only if one
	does not already exist. Otherwise, it reuses the existing timeline
	buffer. The same behavior applies to the info buffer.

						*twitvim_timestamp_format*
	You can customize the timestamp format in a timeline buffer by setting
	twitvim_timestamp_format. For example, to show only the time, add this
	to your vimrc:
>
		let twitvim_timestamp_format = '%I:%M %p'
<
	TwitVim uses |strftime()| to format timestamps, so you will need to
	check the manual page of the C function strftime() to see what
	formatting codes you can use here.


------------------------------------------------------------------------------
4.2. Update Commands				*TwitVim-update-commands*

	These commands post an update to your Twitter account. If the friends,
	user, or public timeline is visible, TwitVim will insert the update
	into the timeline view after posting it.

	Note: If you are replying to a tweet, use the <Leader>r mapping in the
	timeline buffer instead. See |TwitVim-reply|. That mapping will set
	the in-reply-to field, which :PosttoTwitter can't handle.

	:PosttoTwitter					*:PosttoTwitter*

	This command will prompt you for a message and post it to Twitter.

	Note: Since this command uses input(), command-line editing and
	history features are available here. In particular, you can use
	<Up> and <Down> to recall previous tweets. See |history|.

	:CPosttoTwitter					*:CPosttoTwitter*

	This command posts the current line in the current buffer to Twitter.

	:BPosttoTwitter					*:BPosttoTwitter*

	This command posts the contents of the current buffer to Twitter.

	:SendDMTwitter {username}			*:SendDMTwitter*

	This command will prompt you for a direct message to send to user
	{username}.

	Note: If you get a "403 Forbidden" error when you try to send a direct
	message, check if the user you're messaging is following you. That is
	the most common reason for this error when sending a direct message.

------------------------------------------------------------------------------
4.3. Timeline Commands				*TwitVim-timeline-commands*

	These commands retrieve a Twitter timeline and display it in a special
	Twitter buffer. TwitVim applies syntax highlighting to highlight
	certain elements in the timeline view. See |TwitVim-highlight| for a
	list of highlighting groups it uses.


	:UserTwitter					*:UserTwitter*
	:UserTwitter {username}

	This command displays your Twitter timeline.

	If you specify a {username}, this command displays the timeline for
	that user.

							*twitvim_count*
	You can configure the number of tweets returned by :UserTwitter by
	setting twitvim_count. For example,
>
		let twitvim_count = 50
<
	will make :UserTwitter return 50 tweets instead of the default of 20.
	You can set twitvim_count to any integer from 1 to 200.


	:FriendsTwitter					*:FriendsTwitter*

	This command displays your Twitter timeline with updates from friends
	merged in.

	You can configure the number of tweets returned by :FriendsTwitter by
	setting |twitvim_count|.


	:MentionsTwitter				*:MentionsTwitter*
	:RepliesTwitter					*:RepliesTwitter*

	This command displays a timeline of mentions (updates containing
	@username) that you've received from other Twitter users.

	:RepliesTwitter is the old name for :MentionsTwitter.

	You can configure the number of tweets returned by :MentionsTwitter by
	setting |twitvim_count|.


	:DMTwitter					*:DMTwitter*

	This command displays direct messages that you've received.


	:DMSentTwitter					*:DMSentTwitter*

	This command displays direct messages that you've sent.


	:ListTwitter {list}				*:ListTwitter*
	:ListTwitter {user} {list}

	This command displays a Twitter list timeline.

	In the first form, {user} is assumed to be you so the command will
	display a list of yours named {list}.

	In the second form, the command displays list {list} from user
	{user}.


	:RetweetedToMeTwitter				*:RetweetedToMeTwitter*

	This command displays a timeline of retweets by others to you.


	:RetweetedByMeTwitter				*:RetweetedByMeTwitter*

	This command displays a timeline of retweets by you.


	:FavTwitter					*:FavTwitter*

	This command displays a timeline of your favorites.


	:FollowingTwitter				*:FollowingTwitter*
	:FollowingTwitter {user}

	This command displays a list of people you're following.

	If {user} is specified, this command displays a list of people that
	user is following.

	You can use Ctrl-PageUp and Ctrl-PageDown to page back and forth in
	this list. See |TwitVim-previous| and |TwitVim-next|.


	:FollowersTwitter				*:FollowersTwitter*
	:FollowersTwitter {user}

	This command displays a list of people who follow you.

	If {user} is specified, this command displays a list of people
	following that user.

	You can use Ctrl-PageUp and Ctrl-PageDown to page back and forth in
	this list. See |TwitVim-previous| and |TwitVim-next|.


	:ListInfoTwitter {list}				*:ListInfoTwitter*
	:ListInfoTwitter {user} {list}

	This command displays summary information on the Twitter list {list}
	owned by user {user}. If not specified, {user} is the currently
	logged-in user.


	:MembersOfListTwitter {list}			*:MembersOfListTwitter*
	:MembersOfListTwitter {user} {list}

	This command displays members of the Twitter list {list} owned by 
	user {user}. If not specified, {user} is the currently logged-in user.


	:SubsOfListTwitter {list}			*:SubsOfListTwitter*
	:SubsOfListTwitter {user} {list}

	This command displays subscribers to the Twitter list {list} owned by 
	user {user}. If not specified, {user} is the currently logged-in user.


	:OwnedListsTwitter				*:OwnedListsTwitter*
	:OwnedListsTwitter {user}

	This command displays the lists owned by {user}. If not specified,
	{user} is the currently logged-in user.


	:MemberListsTwitter				*:MemberListsTwitter*
	:MemberListsTwitter {user}

	This command displays the lists following {user}. If not specified,
	{user} is the currently logged-in user.


	:SubsListsTwitter				*:SubsListsTwitter*
	:SubsListsTwitter {user}

	This command displays the lists followed by {user}. If not specified,
	{user} is the currently logged-in user.


	:FollowListTwitter {user} {list}		*:FollowListTwitter*

	Start following the list {list} owned by {user}.


	:UnfollowListTwitter {user} {list}		*:UnfollowListTwitter*

	Stop following the list {list} owned by {user}.


	:BackTwitter					*:BackTwitter*

	This command takes you back to the previous timeline in the timeline
	stack. TwitVim saves a limited number of timelines. This command
	will display a warning if you attempt to go beyond the oldest saved
	timeline. See |TwitVim-C-o|.


	:BackInfoTwitter				*:BackInfoTwitter*

	This command is similar to |:BackTwitter| but takes you to the
	previous display in the info buffer stack instead. See |TwitVim-C-o|.


	:ForwardTwitter					*:ForwardTwitter*

	This command takes you to the next timeline in the timeline stack.
	It will display a warning if you attempt to go past the newest saved
	timeline so this command can only be used after :BackTwitter.
	See |TwitVim-C-i|.
	

	:ForwardInfoTwitter				*:ForwardInfoTwitter*

	This command is similar to |:ForwardTwitter| but takes you to the
	next display in the info buffer stack instead. See |TwitVim-C-o|.


	:RefreshTwitter					*:RefreshTwitter*

	This command refreshes the timeline. See |TwitVim-Leader-Leader|.


	:RefreshInfoTwitter				*:RefreshInfoTwitter*

	This command refreshes the info buffer. See |TwitVim-Leader-Leader|.


	:NextTwitter					*:NextTwitter*

	This command loads the next (older) page in the timeline.
	See |TwitVim-C-PageDown|.


	:NextInfoTwitter				*:NextInfoTwitter*

	This command loads the next page in the info buffer.
	See |TwitVim-C-PageDown|.


	:PreviousTwitter				*:PreviousTwitter*

	This command returns to the first (newest) page in the timeline. If
	the timeline is already on the first page, this command issues a
	warning and doesn't do anything. See |TwitVim-C-PageUp|.


	:PreviousInfoTwitter				*:PreviousInfoTwitter*

	This command loads the previous page in the info buffer. If the info
	buffer is on the first page, this command issues a warning and doesn't
	do anything. See |TwitVim-C-PageUp|.


	:SetLoginTwitter				*:SetLoginTwitter*

	This command initiates an OAuth login handshake. 

	Use this command if you need to log in as another Twitter user.
	When the authentication web page comes up, use the "Sign Out" link
	to log in as a different user and grant TwitVim access to that
	user.
	
	When you use SetLoginTwitter, TwitVim does not discard the previous
	access token. So you can switch back to the previous user using
	|:SwitchLoginTwitter|.


	:SwitchLoginTwitter				*:SwitchLoginTwitter*
	:SwitchLoginTwitter {username},{service}

	Switch to another user from the list of saved logins. If
	{username},{service} is not specified, SwitchLoginTwitter will display
	a list of logins and prompt you to select one of those.

	Tab completion is available for this command, so you can enter
	:SwitchLoginTwitter, the space key, and then the tab key to pick from
	a list of saved logins.

	SwitchLoginTwitter knows only about user accounts to which you have
	logged in previously. To switch to a new user account, use
	|:SetLoginTwitter| instead.


	:DeleteLoginTwitter				*:DeleteLoginTwitter*
	:DeleteLoginTwitter {username},{service}

	Deletes a user from the list of saved logins. If {username},{service}
	is not specified, DeleteLoginTwitter will display a list of logins and
	prompt you to select one of those.

	Tab completion is available for this command, so you can enter
	:DeleteLoginTwitter, the space key, and then the tab key to pick from
	a list of saved logins.

	DeleteLoginTwitter knows only about user accounts to which you have
	logged in previously.
	
	Note: You cannot delete the currently active user. If you need to do
	so, use :SwitchLoginTwitter to switch to another user first.


	:ResetLoginTwitter				*:ResetLoginTwitter*

	This command discards the current OAuth access token and all saved
	tokens. The next TwitVim command that needs authentication will
	initiate an OAuth handshake.

	After using ResetLoginTwitter, you won't be able to switch to any
	users using |:SwitchLoginTwitter| because ResetLoginTwitter discards
	all saved access tokens. Use |:DeleteLoginTwitter| instead if you only
	wish to discard one saved token.


	:FollowTwitter {username}			*:FollowTwitter*

	Start following user {username}'s timeline. If the user's timeline is
	protected, this command makes a request to follow that user.

	Note: This command does not enable notifications for the target user.
	If you need that, you'll have to do that separately through the web
	interface.


	:UnfollowTwitter {username}			*:UnfollowTwitter*

	Stop following user {username}'s timeline.


	:BlockTwitter {username}			*:BlockTwitter*

	Block user {username}.


	:UnblockTwitter {username}			*:UnblockTwitter*

	Unblock user {username}.


	:ReportSpamTwitter {username}			*:ReportSpamTwitter*

	Reports user {username} for spam. This command will also block the
	user.


	:EnableRetweetsTwitter {username}	*:EnableRetweetsTwitter*

	Start showing retweets from user {username} in friends timeline.
	
	Note: This option may not take effect immediately since Twitter uses
	cached data to construct the timeline.


	:DisableRetweetsTwitter {username}	*:DisableRetweetsTwitter*

	Stop showing retweets from user {username} in friends timeline.
	
	Note: This option may not take effect immediately since Twitter uses
	cached data to construct the timeline.


	:AddToListTwitter {listname} {username}		*:AddToListTwitter*

	Adds user {username} to list {listname}.


	:RemoveFromListTwitter {listname} {username}	*:RemoveFromListTwitter*

	Removes user {username} from list {listname}.


------------------------------------------------------------------------------
4.4. Mappings						*TwitVim-mappings*

	Alt-T						*TwitVim-A-t*
	Ctrl-T						*TwitVim-C-t*

	In visual mode, Alt-T posts the highlighted text to Twitter.

	Ctrl-T is an alternative to the Alt-T mapping. In GUI Vim on
	certain platforms like Windows, if the menu bar is enabled, Alt-T
	pulls down the Tools menu. So use Ctrl-T instead.


							*TwitVim-reply*
	Alt-R						*TwitVim-A-r*
	<Leader>r					*TwitVim-Leader-r*

	This mapping is local to the timeline buffer. In the timeline buffer,
	it starts composing an @-reply on the command line to the author of
	the tweet on the current line.

	Under Cygwin, Alt-R is not recognized so you can use <Leader>r as an
	alternative. The <Leader> character defaults to \ (backslash) but see
	|mapleader| for information on customizing that.

	Note: Since this command uses input(), command-line editing and
	history features are available here. In particular, you can use
	<Up> and <Down> to recall previous tweets. See |history|.


							*TwitVim-reply-all*
	<Leader>Ctrl-R					*TwitVim-Leader-C-r*

	This mapping is local to the timeline buffer. It starts composing a
	reply to all, i.e. a reply to the tweet author and also to everyone
	mentioned in @-replies on the current line.


							*TwitVim-retweet*
	<Leader>R					*TwitVim-Leader-S-r*

	This mapping (Note: uppercase 'R' instead of 'r'.) is local to the
	timeline buffer. It is similar to the retweet feature in popular
	Twitter clients. In the timeline buffer, it retweets the current line.


							*twitvim_old_retweet*
	If you prefer old-style retweets, add this to your vimrc:
>
		let twitvim_old_retweet = 1
<	
	The difference is an old-style retweet does not use the retweet API.
	Instead, it copies the current line to the command line so that you
	can repost it as a new tweet and optionally edit it or add your own
	comments. Note that an old-style retweet may end up longer than 140
	characters. If you have problems posting a retweet, try editing it to
	make it shorter.

						    *twitvim_retweet_format*
	If you use old-style retweets, you can configure the retweet format.
	By default, TwitVim retweets tweets in the following format:

		RT @user: text of the tweet

	You can customize the retweet format by adding the following to your
	vimrc, for example:
>
		let twitvim_retweet_format = 'Retweet from %s: %t'

		let twitvim_retweet_format = '%t (retweeted from %s)'
<
	When you retweet a tweet, TwitVim will replace "%s" in
	twitvim_retweet_format with the user name of the original poster and
	"%t" with the text of the tweet.

	The default setting of twitvim_retweet_format is "RT %s: %t"


							*TwitVim-direct-message*
	Alt-D						*TwitVim-A-d*
	<Leader>d					*TwitVim-Leader-d*

	This mapping is local to the timeline buffer. In the timeline buffer,
	it starts composing a direct message on the command line to the author
	of the tweet on the current line.

	Under Cygwin, Alt-D is not recognized so you can use <Leader>d as an
	alternative. The <Leader> character defaults to \ (backslash) but see
	|mapleader| for information on customizing that.

	Note: If you get a "403 Forbidden" error when you try to send a direct
	message, check if the user you're messaging is following you. That is
	the most common reason for this error when sending a direct message.


							*TwitVim-goto*
	Alt-G						*TwitVim-A-g*
	<Leader>g					*TwitVim-Leader-g*

	This mapping is local to the timeline and info buffers. It
	launches the web browser with the URL at the cursor position. If you
	visually select text before invoking this mapping, it launches the web
	browser with the selected text as is.

	Special cases:

	- If the cursor is on a word of the form @user or in the user: portion
	  at the beginning of a line, TwitVim displays that user's
	  timeline.

	- If the cursor is on a Name: line in the info buffer, TwitVim
	  displays that user's timeline.

	- If the cursor is on a word of the form #hashtag, TwitVim does a
	  Twitter Search for that #hashtag.

	- In a trending topics buffer, TwitVim does a Twitter Search for the
	  phrase on the cursor line.


							*twitvim_browser_cmd*
	Before using this command, you need to tell TwitVim how to launch your
	browser. For example, you can add the following to your vimrc:
>
		let twitvim_browser_cmd = 'firefox.exe'
<
	Of course, replace firefox.exe with the browser of your choice.

	Under Mac OS X, the following will use the default browser:
>
		let twitvim_browser_cmd = 'open'
<

							*TwitVim-LongURL*
	<Leader>e					*TwitVim-Leader-e*

	This mapping is local to the timeline and info buffers. It
	calls the LongURL API (see http://longurl.org/) to expand the short
	URL at the cursor position. A short URL is a URL from a URL shortening
	service such as TinyURL, SnipURL, etc. Use this feature if you wish to
	preview a URL before browsing to it with |TwitVim-goto|.

	If you visually select text before invoking this mapping, it calls the
	LongURL API with the selected text as is.

	If successful, TwitVim will display the result from LongURL in the
	message area.


							*TwitVim-profile*
	<Leader>p					*TwitVim-Leader-p*

	This mapping is local to the timeline and info buffers. It retrieves
	user profile information (e.g. name, location, bio, update count) for
	the user name at the cursor position. It displays the profile
	information in an info buffer.

	If you visually select text before invoking this mapping, it uses the
	selected text for the user name.

	See also |:ProfileTwitter|.


							*TwitVim-inreplyto*
	<Leader>@					*TwitVim-Leader-@*

	This mapping is local to the timeline buffer. If the current line is
	an @-reply tweet, it retrieves the tweet to which this one is
	replying. Then it will display that predecessor tweet below the
	current one.
	
	If there is no in-reply-to information, it will show a warning and do
	nothing.

	This mapping is useful in the replies timeline. See |:RepliesTwitter|.


							*TwitVim-delete*
	<Leader>X					*TwitVim-Leader-X*

	This mapping is local to the timeline buffer. The 'X' in the mapping
	is uppercase. It deletes the tweet or direct message on the current
	line.

	Note: You have to be the author of the tweet in order to delete it.
	However, you can delete direct messages that you sent or received.


							*TwitVim-fave*
							*TwitVim-Leader-f*
	<Leader>f

	This mapping is local to the timeline buffer. It adds the tweet on the
	current line to your favorites.


							*TwitVim-unfave*
							*TwitVim-Leader-C-f*
	<Leader>Ctrl-F

	This mapping is local to the timeline buffer. It removes the tweet on
	the current line from your favorites.


	Ctrl-O						*TwitVim-C-o*

	This mapping takes you to the previous timeline in the timeline stack.
	See |:BackTwitter|.

	This mapping also works in the info buffer but uses a separate history
	stack. See |:BackInfoTwitter|.


	Ctrl-I						*TwitVim-C-i*

	This mapping takes you to the next timeline in the timeline stack.
	See |:ForwardTwitter|.

	This mapping also works in the info buffer but uses a separate history
	stack. See |:ForwardInfoTwitter|.


							*TwitVim-refresh*
	<Leader><Leader> 				*TwitVim-Leader-Leader*

	This mapping refreshes the timeline. See |:RefreshTwitter|.

	This mapping also works in the info buffer but is of limited utility
	there because that info shouldn't change as often as a timeline.
	See |:RefreshInfoTwitter|.


							*TwitVim-next*
	Ctrl-PageDown					*TwitVim-C-PageDown*

	This mapping loads the next (older) page in the timeline.
	See |:NextTwitter|.

	This mapping also works in the info buffer but only if the list is
	long enough to use more than one page. It does nothing in the user
	profile display. See |:NextInfoTwitter|.

	
							*TwitVim-previous*
	Ctrl-PageUp					*TwitVim-C-PageUp*

	This mapping returns to the first (newest) page in the timeline. If
	the timeline is already on the first page, it issues a warning and
	doesn't do anything. See |:PreviousTwitter|.

	This mapping also works in the info buffer but only if the list is
	long enough to use more than one page. It does nothing in the user
	profile display. See |:PreviousInfoTwitter|.


------------------------------------------------------------------------------
4.5. Utility Commands					*TwitVim-utility*

	Note: You do not need these URL shortening services to post to
	Twitter. Simply add the full URL to your tweet and Twitter will use
	its own URL wrapper.


	:BitLy						*:BitLy*
	:BitLy {url}

	bit.ly is a URL forwarding and shortening service. See
	https://bitly.com/

	This command calls the bit.ly API to get a short URL in place of
	{url}. If {url} is not provided on the command line, the command will
	prompt you to enter a URL. The short URL is then inserted into the
	current buffer at the current position.

	The bit.ly API requires bit.ly access token. A default
	access token is provided with TwitVim and no configuration is
	needed.
	
	However, if you wish to supply your own access token to track
	your bit.ly history and stats:
	- Go to https://bitly.com/a/oauth_apps
	- Enter your password and click on "Generate Token".
	- Copy the string below "Generic Access Token" and then add the
	  following to your vimrc:

							*twitvim_bitly_key*
>
		let twitvim_bitly_key = "accesstoken"
<
	Where accesstoken is the string you obtained from bit.ly.

	Note: The bit.ly access token is not the same as the bit.ly API key
	used in TwitVim 0.8 and earlier. If you are upgrading TwitVim and
	have a bit.ly API key in your vimrc, you'll need to replace it with
	a bit.ly access token.

	:ABitLy						*:ABitLy*
	:ABitLy {url}

	Same as :BitLy but appends, i.e. inserts after the current
	position instead of at the current position, the short URL instead.

	:PBitLy						*:PBitLy*
	:PBitLy {url}
	
	Same as :BitLy but prompts for a tweet on the command line with
	the short URL already inserted.


	:IsGd						*:IsGd*
	:IsGd {url}

	is.gd is a URL forwarding and shortening service. See
	http://is.gd

	This command calls the is.gd API to get a short URL in place of <url>.
	If {url} is not provided on the command line, the command will prompt
	you to enter a URL. The short URL is then inserted into the current
	buffer at the current position.

	:AIsGd						*:AIsGd*
	:AIsGd {url}

	Same as :IsGd but appends, i.e. inserts after the current position
	instead of at the current position, the short URL instead.

	:PIsGd						*:PIsGd*
	:PIsGd {url}
	
	Same as :IsGd but prompts for a tweet on the command line with the
	short URL already inserted.


	:Googl						*:Googl*
	:Googl {url}

	Goo.gl is Google's URL forwarding and shortening service.
	See http://goo.gl/

	This command calls the goo.gl API to get a short URL in place of
	<url>. If {url} is not provided on the command line, the command will
	prompt you to enter a URL. The short URL is then inserted into the
	current buffer at the current position.

	:AGoogl						*:AGoogl*
	:AGoogl {url}

	Same as :Googl but appends, i.e. inserts after the current position
	instead of at the current position, the short URL instead.

	:PGoogl						*:PGoogl*
	:PGoogl {url}
	
	Same as :Googl but prompts for a tweet on the command line with the
	short URL already inserted.


	:SearchTwitter					*:SearchTwitter*
	:SearchTwitter {query}
	
	This command calls the Search API to search for {query}. If {query} is
	not provided on the command line, the command will prompt you for it.
	Search results are then displayed in the timeline buffer.

	All of the Twitter Search operators are supported implicitly. For a
	list of search operators, see:
	https://support.twitter.com/groups/31-twitter-basics/topics/110-search/articles/71577-how-to-use-advanced-twitter-search

	You can configure the number of tweets returned by :SearchTwitter by
	setting |twitvim_count|.


	:RateLimitTwitter				*:RateLimitTwitter*

	This command retrieves rate limit information. It shows the current
	limit, how many API calls you have remaining, and when your quota will
	be reset. You can use it to check if you have been temporarily locked
	out of Twitter for hitting the rate limit.

	As of Twitter API 1.1, rate limits are per API endpoint. This
	command displays one line per API endpoint and is very verbose.


	:ProfileTwitter					*:ProfileTwitter*
	:ProfileTwitter {username}

	This command retrieves user profile information (e.g. name, location,
	bio, update count) for the specified user {username}. It displays the
	information in an info buffer.

	If {username} is not specified, this command will retrieve
	information for the currently logged-in user.

	See also |TwitVim-Leader-p|.


	:LocationTwitter {location}			*:LocationTwitter*

	This command sets the location field in your profile. There is no
	mandatory format for the location. It could be a zip code, a town,
	coordinates, or pretty much anything.

	For example:
>
	:LocationTwitter 10027
	:LocationTwitter New York, NY, USA
	:LocationTwitter 40.811583, -73.954486
<

	:TrendTwitter					*:TrendTwitter*

	This command retrieves a list of Twitter trending topics and displays
	them in the timeline buffer.

	In trending topics, |TwitVim-Leader-g| does a Twitter search for the
	phrase on the cursor line.

	By default, this command shows worldwide trends. To show regional
	trends, use |:SetTrendLocationTwitter| or set |twitvim_woeid|.


	:SetTrendLocationTwitter		 *:SetTrendLocationTwitter*

	This command displays a menu of trend locations by country and by
	town. It sets the region for |:TrendTwitter|.
	

							*twitvim_woeid*
	If you wish to set the default location for |:TrendTwitter| to
	something other than worldwide, set twitvim_woeid in your vimrc.
	
	For example:
>
		let twitvim_woeid = 2357024
<
	sets the location to Atlanta.
	
	You can find out what number to use for a location by checking the
	message displayed after |:SetTrendLocationTwitter| or by checking
	twitvim_woeid after |:SetTrendLocationTwitter|.


==============================================================================
5. Timeline Highlighting				*TwitVim-highlight*

	TwitVim uses a number of highlighting groups to highlight certain
	elements in the Twitter timeline views. See |:highlight| for details
	on how to customize these highlighting groups.

	twitterUser					*hl-twitterUser*
	
	The Twitter user name at the beginning of each line.

	twitterTime					*hl-twitterTime*

	The time a Twitter update was posted.

	twitterTitle					*hl-twitterTitle*

	The header at the top of the timeline view.

	twitterLink					*hl-twitterLink*

	Link URLs and #hashtags in a Twitter status.

	twitterReply					*hl-twitterReply*

	@-reply in a Twitter status.


==============================================================================
6. Tips and Tricks					*TwitVim-tips*

	Here are a few tips for using TwitVim more efficiently.


------------------------------------------------------------------------------
6.1. Timeline Hotkeys					*TwitVim-hotkeys*

	TwitVim does not autorefresh. However, you can make refreshing your
	timeline easier by mapping keys to the timeline commands. For example,
	I use the <F8> key for that:
>
		nnoremap <F8> :FriendsTwitter<cr>
		nnoremap <S-F8> :UserTwitter<cr>
		nnoremap <A-F8> :RepliesTwitter<cr>
		nnoremap <C-F8> :DMTwitter<cr>
<

------------------------------------------------------------------------------
6.2. Line length in status line				*TwitVim-line-length*

	Add the following to your |'statusline'| to display the length of the
	current line:
>
		%{strlen(getline('.'))}
<	
	This is useful if you compose tweets in a separate buffer and post
	them with |:CPosttoTwitter|. With the line length in your status line,
	you will know when you've reached the 140-character boundary.


------------------------------------------------------------------------------
6.3. Network timeout				*TwitVim-network-timeout*

	TwitVim may have problems connecting to Twitter sometimes. The system
	default for socket timeouts may be as long as a few minutes, so
	TwitVim will appear to hang for that length of time before displaying
	an error message.

							*twitvim_net_timeout*
	You can set twitvim_net_timeout to reduce this timeout interval. For
	example, add the following to your vimrc:
>
		let twitvim_net_timeout = 30
<
	to set the network timeout to 30 seconds.

	Note: This option does not seem to work correctly if you are using
	|twitvim_enable_perl|. It may take longer than that number of seconds
	to time out.


==============================================================================
7. TwitVim History					*TwitVim-history*

	0.9.0 : 2015-04-10 * Removed identi.ca support and legacy code.
                           * Removed support for old token file formats.
                           * Removed old Twitter search code.
                           * Removed some obscure URL shortening services.
                           * Updated to bit.ly v3 API.
                           * Removed old goo.gl URL shortening code.
                           * Removed services menu because we only have
                             Twitter now.
                           * Removed public timeline command.
                           * Moved most of the plugin code to an autoload
                             file.
                           * Search header fix in UTF-8 encoding. (@mattn_jp)
                           * Don't use curl -p for HTTP. (@mattn_jp)
                           * Handle surrogate pairs. (@mattn_jp)
	0.8.2 : 2014-03-26 * Change Twitter API URLs to https. Twitter no
			     longer supports non-SSL.
			   * Added support for highlighting $stocksymbol
		             and jumping to searches for $stocksymbol.
			   * Perform zero-length message check before
			     get_cur_service() so a non-logged-in user can
			     cancel.
			   * Made a proper folder structure and added a
			     vimball packing script.
	0.8.1 : 2013-08-12 * Fix for suspended users in followers list.
			   * Rewrote URL regex for new regex engine in Vim 7.4.
	0.8.0 : 2013-01-02 * Support for Twitter API 1.1.
			   * Support for identi.ca OAuth and switching between
			     Twitter OAuth and identi.ca OAuth logins.
			   * Added |twitvim_force_ssl|.
			   * Added |:DeleteLoginTwitter|.
			   * Add in-reply-to status to old-style retweets.
			     (@mattn_jp)
			   * Fix for old-style retweets with '&' characters.
			   * Some fixes for https proxy support.
	0.7.5 : 2012-08-10 * Partial support for identi.ca search.
			   * Tightened up |TwitVim-Leader-g| URL matching to
			     omit extraneous trailing characters.
	0.7.4 : 2012-05-04 * Allow users to customize timestamp format in
			     timeline displays. |twitvim_timestamp_format|
			   * Take Twitter's URL-wrapping into account when
			     counting characters in tweets. You do not have to
			     shorten URLs manually any more. Just post to
			     Twitter with the original URLs and TwitVim will
			     ensure that the tweet fits the 140-character
			     limit after Twitter's t.co link-wrapping.
			   * Added network timeout option.
			     |twitvim_net_timeout|
			   * Added Python 3 networking and OAuth code.
			     |twitvim_enable_python3|
			   * Switched from page-style pagination to
			     max_id-style pagination because page-style
			     pagination has been deprecated. As a result, all
			     timeline commands will cease to accept [count]
			     parameters and |:PreviousTwitter| will return to
			     the top page regardless of current page number.
			   * Switched to new API for |:FollowingTwitter| and
			     |:FollowersTwitter| because the old API was
			     deprecated.
			   * |:FollowTwitter| now stops you from following a
			     user that you are already following. This is to
			     avoid triggering a Twitter bug where the
			     following flag reverts to 'follow request sent'
			     if the subject's timeline is protected.
	0.7.3 : 2012-01-17 * Switched to JSON API for Twitter Search so that
			     TwitVim can support t.co URL expansion and
			     in-reply-to in search results.
			   * Made the URL-matching pattern more accurate.
	0.7.2 : 2011-11-16 * Allow users to use their own consumer key and
			     secret. |twitvim_consumer_key|
			     |twitvim_consumer_secret|
			   * Added t.co URL expansion for media URLs too.
			   * Added confirmation prompt before new-style
			     retweet.
			   * Request trends in JSON format. XML format no
			     longer works.
			   * Read token file before |:SwitchLoginTwitter|
			     (@mattn_jp)
	0.7.1 : 2011-09-21 * Added trending topics. |:TrendTwitter| and
			     |:SetTrendLocationTwitter|
			   * Some fixes for browser-launching issues.
			   * Fix for quoting issue when doing goo.gl URL
			     shortening with cURL network interface under
			     Windows.
			   * Support for HTML hex entities.
			   * Show 'follow request sent' in user profile
			     display if that is the case.
	0.7.0 : 2011-07-06 * Replaced many deprecated Twitter API calls with
			     updated versions.
			   * Improved XML parsing speed for high
			     |twitvim_count|.
			   * Added |:SwitchLoginTwitter| and other code to
			     support multiple saved OAuth logins.
	0.6.3 : 2011-05-13 * Expand t.co URLs in timeline displays.
			   * Added timeline filtering. |TwitVim-filter|
	0.6.2 : 2011-02-21 * Added more user relationship info to
			     |:ProfileTwitter|.
			   * Added |:EnableRetweetsTwitter| and
			     |:DisableRetweetsTwitter|.
			   * Switch to new (documented) goo.gl API.
			   * Added |:ListInfoTwitter|.
	0.6.1 : 2011-01-06 * Fix for buffer stack bug if user closes
			     a window manually.
			   * Use https OAuth endpoints if user has set up
			     https API root.
			   * Match a URL even if prefix is in mixed case.
	0.6.0 : 2010-10-27 * Added |:FollowingTwitter|, |:FollowersTwitter|.
			   * Added |:MembersOfListTwitter|,
			     |:SubsOfListTwitter|, |:OwnedListsTwitter|,
			     |:MemberListsTwitter|, |:SubsListsTwitter|,
			     |:FollowListTwitter|, |:UnfollowListTwitter|.
			   * Added support for goo.gl |:Googl| and Rga.la.
			     |:Rgala|
			   * Extended |TwitVim-Leader-g| to support Name: lines
			     in user profile and following/followers lists.
			   * Added history stack for info buffer.
			   * Added |:BackInfoTwitter|, |:ForwardInfoTwitter|,
			     |:RefreshInfoTwitter|, |:NextInfoTwitter|,
			     |:PreviousInfoTwitter| for the info buffer. Also
			     added support for |TwitVim-C-PageDown| and
			     |TwitVim-C-PageUp| in info buffer.
			   * Added twitvim filetype for user customization
			     via autocommands.
			   * Changed display of retweets to show the full
			     version instead of the truncated version
			     when the retweeted status is near the 
			     character limit.
			   * |:ProfileTwitter| with no argument now shows
			     info on logged-in user.
			   * Make |TwitVim-Leader-@| work on new-style
			     retweets by showing the retweeted status
			     as the parent.
	0.5.6 : 2010-09-19 * Exception handling for Python net interface.
			   * Added converter functions for non-UTF8 encoding
			     by @mattn_jp.
			   * Convert entities in profile name, bio, and
			     location. (Suggested by code933k)
			   * Fix for posting foreign chars when encoding is
			     not UTF8 and net method is not Curl.
			   * Support |twitvim_count| in |:DMTwitter| and
			     |:DMSentTwitter|.
			   * Added |:FavTwitter|.
			   * Added mappings to favorite and unfavorite tweets.
			     |TwitVim-Leader-f| |TwitVim-Leader-C-f|
	0.5.5 : 2010-08-16 * Added support for computing HMAC-SHA1 digests
			     using the openssl command line tool from the
			     OpenSSL toolkit. |TwitVim-OpenSSL|
	0.5.4 : 2010-08-11 * Added Ruby and Tcl versions of HMAC-SHA1 digest
			     code.
			   * Improved error messages for cURL users.
			   * Fix to keep |'nomodifiable'| setting from leaking
			     out into other buffers.
			   * Support Twitter SSL via Tcl interface.
			     |TwitVim-ssl-tcl|
	0.5.3 : 2010-06-23 * Improved error messages for most commands if 
			     using Perl, Python, Ruby, or Tcl interfaces.
			   * Added |:FollowTwitter|, |:UnfollowTwitter|,
			     |:BlockTwitter|, |:UnblockTwitter|,
			     |:ReportSpamTwitter|, |:AddToListTwitter|,
			     |:RemoveFromListTwitter|.
	0.5.2 : 2010-06-22 * More fixes for Twitter OAuth.
	0.5.1 : 2010-06-19 * Shorten auth URL with is.gd/Bitly if we need
			     to ask the user to visit it manually.
			   * Fixed the |:PublicTwitter| invalid request error.
			   * Include new-style retweets in user timeline.
	0.5.0 : 2010-06-16 * Switched to OAuth for user authentication on 
			     Twitter. |TwitVim-OAuth|
			   * Improved |:ProfileTwitter|.
	0.4.7 : 2010-03-13 * Added |:MentionsTwitter| as an alias for
			     |:RepliesTwitter|.
			   * Support |twitvim_count| in |:MentionsTwitter|.
			   * Fixed |twitvim_count| bug in |:ListTwitter|.
			   * Fixed Ruby interface problem with
			     Vim patch 7.2.374.
			   * Fixed |:BackTwitter| behavior when timeline
			     window is hidden by user.
			   * Handle SocketError exception in Ruby code.
	0.4.6 : 2010-02-05 * Added option to hide header in timeline buffer.
			     |TwitVim-hide-header|
	0.4.5 : 2009-12-20 * Prompt for login info if not configured.
			     |:SetLoginTwitter| |:ResetLoginTwitter|
			   * Reintroduced old-style retweet via
			     |twitvim_old_retweet|.
	0.4.4 : 2009-12-13 * Upgraded bit.ly API support to version 2.0.1
			     with configurable user login and key.
			   * Added support for Zima. |:Zima|
			   * Fixed :BackTwitter behavior when browsing
			     multiple lists.
			   * Added support for displaying retweets in
			     friends timeline.
			   * Use Twitter Retweet API to retweet.
			   * Added commands to display retweets to you or
			     by you. |:RetweetedToMeTwitter|
			     |:RetweetedByMeTwitter|
	0.4.3 : 2009-11-27 * Fixed some minor breakage in LongURL support.
			   * Added |:ListTwitter|
			   * Omit author's name from the list when doing a
			     reply to all. |TwitVim-reply-all|
	0.4.2 : 2009-06-22 * Bugfix: Reset syntax items in Twitter window.
			   * Bugfix: Show progress message before querying
			     for in-reply-to tweet.
			   * Added reply to all feature. |TwitVim-reply-all|
	0.4.1 : 2009-03-30 * Fixed a problem with usernames and search terms
			     that begin with digits.
	0.4.0 : 2009-03-09 * Added |:SendDMTwitter| to send direct messages
			     through API without relying on the "d user ..."
			     syntax.
			   * Modified Alt-D mapping in timeline to use
			     the :SendDMTwitter code.
			   * Added |:BackTwitter| and |:ForwardTwitter|
			     commands, Ctrl-O and Ctrl-I mappings to move back
			     and forth in the timeline stack.
			   * Improvements in window handling. TwitVim commands
			     will restore the cursor to the original window
			     when possible.
			   * Wrote some notes on using TwitVim with Twitter
			     SSL API.
			   * Added mapping to show predecessor tweet for an
			     @-reply. |TwitVim-inreplyto|
			   * Added mapping to delete a tweet or message.
			     |TwitVim-delete|
			   * Added commands and mappings to refresh the
			     timeline and load the next or previous page.
			     |TwitVim-refresh|, |TwitVim-next|,
			     |TwitVim-previous|.
	0.3.5 : 2009-01-30 * Added support for pagination and page length to
			     :SearchTwitter.
			   * Shortened default retweet prefix to "RT".
	0.3.4 : 2008-11-11 * Added |twitvim_count| option to allow user to
			     configure the number of tweets returned by
			     :FriendsTwitter and :UserTwitter.
	0.3.3 : 2008-10-06 * Added support for Cligs. |:Cligs|
	                   * Fixed a problem with not being able to unset
			     the proxy if using Tcl http.
	0.3.2 : 2008-09-30 * Added command to display rate limit info.
			     |:RateLimitTwitter|
			   * Improved error reporting for :UserTwitter.
			   * Added command and mapping to display user
			     profile information. |:ProfileTwitter|
			     |TwitVim-Leader-p|
			   * Added command for updating location.
			     |:LocationTwitter|
			   * Added support for tr.im. |:Trim|
			   * Fixed error reporting in Tcl http code.
	0.3.1 : 2008-09-18 * Added support for LongURL. |TwitVim-LongURL|
			   * Added support for posting multibyte/Unicode
			     tweets in cURL mode.
			   * Remove newlines from text before retweeting.
	0.3.0 : 2008-09-12 * Added support for http networking through Vim's
			     Perl, Python, Ruby, and Tcl interfaces, as
			     alternatives to cURL. |TwitVim-non-cURL|
			   * Removed UrlTea support.
	0.2.24 : 2008-08-28 * Added retweet feature. See |TwitVim-retweet|
	0.2.23 : 2008-08-25 * Support in_reply_to_status_id parameter.
			    * Added tip on line length in statusline.
			    * Report browser launch errors.
			    * Set syntax highlighting on every timeline refresh.
	0.2.22 : 2008-08-13 * Rewrote time conversion code in Vim script
			      so we don't need Perl or Python any more.
			    * Do not URL-encode digits 0 to 9.
	0.2.21 : 2008-08-12 * Added tips section to documentation.
			    * Use create_or_reuse instead of create in UrlBorg
			      API so that it will always generate the same
			      short URL for the same long URL.
			    * Added support for highlighting #hashtags and
			      jumping to Twitter Searches for #hashtags.
			    * Added Python code to convert Twitter timestamps
			      to local time and simplify them.
	0.2.20 : 2008-07-24 * Switched from Summize to Twitter Search.
			      |:SearchTwitter|
	0.2.19 : 2008-07-23 * Added support for non-Twitter servers
			      implementing the Twitter API. This is for
			      identi.ca support. See |twitvim-identi.ca|.
	0.2.18 : 2008-07-14 * Added support for urlBorg API. |:UrlBorg|
	0.2.17 : 2008-07-11 * Added command to show DM Sent Timeline.
	                      |:DMSentTwitter|
			    * Added support for pagination in Friends, User,
			      Replies, DM, and DM Sent timelines.
			    * Added support for bit.ly API and is.gd API.
			      |:BitLy| |:IsGd|
	0.2.16 : 2008-05-16 * Removed quotes around browser launch URL.
			    * Escape ! character in browser launch URL.
	0.2.15 : 2008-05-13 * Extend :UserTwitter and :FriendsTwitter to show
			      another user's timeline if argument supplied.
			    * Extend Alt-G mapping to jump to another user's
			      timeline if invoked over @user or user:
			    * Escape special Vim shell characters in URL when
			      launching web browser.
	0.2.14 : 2008-05-12 * Added support for Summize search API.
	0.2.13 : 2008-05-07 * Added mappings to launch web browser on URLs in
			      timeline.
	0.2.12 : 2008-05-05 * Allow user to specify Twitter login info and
			      proxy login info preencoded in base64.
			      |twitvim_login_b64| |twitvim_proxy_login_b64|
	0.2.11 : 2008-05-02 * Scroll to top in timeline window after adding
			      an update line.
			    * Add <Leader>r and <Leader>d mappings as
			      alternative to Alt-R and Alt-D because the
			      latter are not valid key combos under Cygwin.
	0.2.10 : 2008-04-25 * Shortened snipurl.com to snipr.com
			    * Added support for proxy authentication.
			      |twitvim_proxy_login|
			    * Handle Perl module load failure. Not that I
			      expect those modules to ever be missing.
	0.2.9 : 2008-04-23 * Added some status messages.
			   * Added menu items under Plugin menu.
			   * Allow Ctrl-T as an alternative to Alt-T to avoid
			     conflict with the menu bar.
			   * Added support for UrlTea API.
			   * Generalize URL encoding to all non-alpha chars.
	0.2.8 : 2008-04-22 * Encode URLs sent to URL-shortening services.
	0.2.7 : 2008-04-21 * Add support for TinyURL API. |:TinyURL|
			   * Add quick direct message feature.
			     |TwitVim-direct-message|
	0.2.6 : 2008-04-15 * Delete Twitter buffer to the blackhole register
			     to avoid stepping on registers unnecessarily.
			   * Quote login and proxy arguments before sending to
			     cURL.
			   * Added support for SnipURL API and Metamark API.
			     |:Snipurl| |:Metamark|
	0.2.5 : 2008-04-14 * Escape the "+" character in sent tweets.
			   * Added Perl code to convert Twitter timestamps to
			     local time and simplify them.
			   * Fix for timestamp highlight when the "|"
			     character appears in a tweet.
	0.2.4 : 2008-04-13 * Use <q-args> in Tweetburner commands.
			   * Improve XML parsing so that order of elements
			     does not matter.
			   * Changed T mapping to Alt-T to avoid overriding
			     the |T| command.
	0.2.3 : 2008-04-12 * Added more Tweetburner commands.
	0.2.2 : 2008-04-11 * Added quick reply feature.
			   * Added Tweetburner support. |:Tweetburner|
			   * Changed client ident to "from twitvim".
	0.2.1 : 2008-04-10 * Bug fix for Chinese characters in timeline.
			     Thanks to Leiyue.
			   * Scroll up to newest tweet after refreshing
			     timeline.
			   * Changed Twitter window name to avoid unsafe
			     special characters and clashes with file names.
	0.2.0 : 2008-04-09 * Added views for public, friends, user timelines,
			     replies, and direct messages. 
			   * Automatically insert user's posts into
			     public, friends, or user timeline, if visible.
			   * Added syntax highlighting for timeline view.
	0.1.2 : 2008-04-03 * Make plugin conform to guidelines in
    			    |write-plugin|.
			   * Add help documentation.
	0.1.1 : 2008-04-01 * Add error reporting for cURL problems.
	0.1   : 2008-03-28 * Initial release.


==============================================================================
8. TwitVim Credits					*TwitVim-credits*

	Thanks to Travis Jeffery, the author of the original VimTwitter script
	(vimscript #2124), who came up with the idea of running cURL from Vim
	to access the Twitter API.

	Techniques for managing the Twitter buffer were adapted from the NERD
	Tree plugin (vimscript #1658) by Marty Grenfell.


==============================================================================
vim:tw=78:ts=8:ft=help:norl:
