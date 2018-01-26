" ==============================================================
" TwitVim - Post to Twitter from Vim
" Based on Twitter Vim script by Travis Jeffery <eatsleepgolf@gmail.com>
"
" Version: 0.9.1
" License: Vim license. See :help license
" Language: Vim script
" Maintainer: Po Shan Cheah <morton@mortonfox.com>
" Created: March 28, 2008
" Last updated: September 4, 2015
"
" GetLatestVimScripts: 2204 1 twitvim.vim
" ==============================================================

" Load this module only once.
if exists('g:loaded_twitvim')
    finish
endif
let g:loaded_twitvim = '0.9.1 2015-09-04'

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

if get(g:, 'twitvim_enable_menu', 1)
  nnoremenu Plugin.TwitVim.Post\ from\ cmdline :call twitvim#CmdLine_Twitter('', 0)<cr>
endif

" Post current line to Twitter.
if !exists(":CPosttoTwitter")
    command CPosttoTwitter :call twitvim#post_twitter(getline('.'), 0)
endif

if get(g:, 'twitvim_enable_menu', 1)
  nnoremenu Plugin.TwitVim.Post\ current\ line :call twitvim#post_twitter(getline('.'), 0)<cr>
endif

" Post entire buffer to Twitter.
if !exists(":BPosttoTwitter")
    command BPosttoTwitter :call twitvim#post_twitter(join(getline(1, "$"), "\n"), 0)
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

if get(g:, 'twitvim_enable_menu', 1)
  vmenu Plugin.TwitVim.Post\ selection <Plug>TwitvimVisual
endif

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

if get(g:, 'twitvim_enable_menu', 1)
  nnoremenu Plugin.TwitVim.-Sep1- :
  nnoremenu Plugin.TwitVim.&Friends\ Timeline :call twitvim#get_timeline("friends", '', 1, 0)<cr>
  nnoremenu Plugin.TwitVim.&User\ Timeline :call twitvim#get_timeline("user", '', 1, 0)<cr>
  nnoremenu Plugin.TwitVim.&Mentions\ Timeline :call twitvim#get_timeline("replies", '', 1, 0)<cr>
  nnoremenu Plugin.TwitVim.&Direct\ Messages :call twitvim#Direct_Messages("dmrecv", 1, 0)<cr>
  nnoremenu Plugin.TwitVim.Direct\ Messages\ &Sent :call twitvim#Direct_Messages("dmsent", 1, 0)<cr>

  nnoremenu Plugin.TwitVim.Retweeted\ &By\ Me :call twitvim#get_timeline("retweeted_by_me", '', 1, 0)<cr>
  nnoremenu Plugin.TwitVim.Retweeted\ &To\ Me :call twitvim#get_timeline("retweeted_to_me", '', 1, 0)<cr>
  nnoremenu Plugin.TwitVim.Fa&vorites :call twitvim#get_timeline("favorites", '', 1, 0)<cr>
endif

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

if get(g:, 'twitvim_enable_menu', 1)
  nnoremenu Plugin.TwitVim.-Sep2- :
  nnoremenu Plugin.TwitVim.Set\ Twitter\ Login :call twitvim#prompt_twitvim_login()<cr>
  nnoremenu Plugin.TwitVim.Reset\ Twitter\ Login :call twitvim#reset_twitvim_login()<cr>
endif

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

if !exists(":MuteTwitter")
    command -nargs=1 MuteTwitter :call twitvim#mute_user(<q-args>, 0)
endif
if !exists(":UnmuteTwitter")
    command -nargs=1 UnmuteTwitter :call twitvim#mute_user(<q-args>, 1)
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

nnoremap <plug>(twitvim-PosttoTwitter) :call twitvim#CmdLine_Twitter('', 0)<cr>

let &cpo = s:save_cpo
finish

" vim:set tw=0 et:
