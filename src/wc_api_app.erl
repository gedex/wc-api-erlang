-module(wc_api_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    wc_api_sup:start_link().

stop(_State) ->
    ok.
