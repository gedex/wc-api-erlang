%% -*- erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et

%% wc_api: WooCommerce REST API v3 Client
%%
%% The MIT License
%%
%% Copyright (c) 2015 Akeda Bagus <admin@gedex.web.id>
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% ----------------------------------------------------------------------------

%% @doc
%% WooCommerce REST API v3 Client.
-module(wc_api).

-export([create_client/3, create_client/4,
         get/2, get/3,
         post/3,
         put/3,
         delete/2, delete/3,
         test/0,
         test_print/1
         ]).

-compile(export_all).
-include("wc_api.hrl").

-json({resp_error, {string, "code"}, {string, "message"}}).
-json({resp_errors, {list, "errors", [{type, resp_error}]}}).
-json({resp_delete, {string, "message"}}).
-json({coupon, {number, "id"},
               {string, "code"},
               {string, "type"},
               {string, "created_at"},
               {string, "updated_at"},
               {string, "amount"},
               {boolean, "individual_use"},
               {list, "product_ids"},
               {list, "exclude_product_ids"},
               {number, "usage_limit"},
               {number, "usage_limit_per_user"},
               {number, "limit_usage_to_x_items"},
               {number, "usage_count"},
               {string, "expiry_date"},
               {boolean, "enable_free_shipping"},
               {list, "product_category_ids"},
               {list, "exclude_product_category_ids"},
               {boolean, "exclude_sale_items"},
               {string, "minimum_amount"},
               {string, "maximum_amount"},
               {list, "customer_emails", [{post_decode, {?MODULE, to_list_of_strings}}]},
               {string, "description"}
               }).
-json({coupon_wrapper, {record, "coupon", [{type, coupon}]}}).
-json({coupons, {list, "coupons", [{type, coupon}]}}).
-json({customer, {number, "id"},
                 {string, "created_at"},
                 {string, "email"},
                 {skip, "password"},
                 {string, "last_name"},
                 {string, "first_name"},
                 {string, "username"},
                 {number, "last_order_id"},
                 {string, "last_order_date"},
                 {number, "orders_count"},
                 {number, "total_spent"},
                 {string, "avatar_url"},
                 {record, "billing_address", [{type, customer_billing_address}]},
                 {record, "shipping_address", [{type, customer_shipping_address}]}
                 }).
-json({customer_wrapper, {record, "customer", [{type, customer}]}}).
-json({customers, {list, "customers", [{type, customer}]}}).

-export_type([client/0,
              coupon/0,
              customer/0
              ]).
-opaque client() :: #client{}.
-opaque coupon() :: #coupon{}.
-opaque customer() :: #customer{}.

%% ----------------------------------------------------------------------------
%% API Functions.
%% ----------------------------------------------------------------------------

%% @doc   Create a client for connecting to WooCommerce REST API.
%% @equiv create(string(), string(), string(), [])
create_client(Url, ConsumerKey, ConsumerSecret) ->
    create_client(Url, ConsumerKey, ConsumerSecret, [{version, ?WC_DEFAULT_API_VER}]).

%% @doc  Create a client for connecting to WooCommerce REST API.
%%       <pre>Opts::proplist()</pre> is the options to be passed to <pre>ibrowse:send_req</pre>.
%% @spec create(string(), string(), string(), Opts::proplist()) -> {ok,client()}|{error, term()}
create_client(Url0, ConsumerKey, ConsumerSecret, Opts) when is_list(Url0),
                                                            is_list(ConsumerKey),
                                                            is_list(ConsumerSecret),
                                                            is_list(Opts) ->
    %% Make sure Url always prefixed with http/https scheme.
    Url = case string:substr(Url0, 1, 4) of
              "http" -> Url0;
              _      -> "http://" ++ Url0
          end,
    IsSSL = case string:str(Url, "https://") > 0 of
                true  -> {is_ssl, true};
                false -> {is_ssl, false}
            end,
    #client{url=Url, consumer_key=ConsumerKey, consumer_secret=ConsumerSecret, options=[IsSSL|Opts]}.

%% @doc Do GET request to WooCommerce REST API endpoints.
%%
%% @spec get(client(), string()) -> {ok, list()|coupon()}|{error, term()}
get(Client, Endpoint) ->
    get(Client, Endpoint, []).
%% @spec get(client(), string(), proplist()) -> {ok, list()|coupon()}|{error, term()}
get(Client, Endpoint, QS) when is_list(QS) ->
    api(Client, Endpoint, get, QS, empty).

%% @doc Do POST request to WooCommerce REST API endpoints.
%%
%% @spec post(client(), string(), term()) -> {ok, term()}|{error, term()}
post(Client, Endpoint, Data) ->
    api(Client, Endpoint, post, [], Data).

%% @doc Do PUT request to WooCoomerce REST API endpoints.
%%
%% @spec put(client(), string(), term()) -> {ok, term()}|{error, term()}
put(Client, Endpoint, Data) ->
    api(Client, Endpoint, put, [], Data).

%% @doc Do DELETE request to WooCommerce REST API endpoints.
%%
%% @spec delete(client(), string()) -> {ok, term()}|{error, term()}
delete(Client, Endpoint) ->
    delete(Client, Endpoint, []).

%% @doc Do DELETE request to WooCommerce REST API endpoints.
%% @spec delete(client(), string(), proplist()) -> {ok, term()}|{error, term()}
delete(Client, Endpoint, QS) ->
    api(Client, Endpoint, delete, QS, empty).

test() ->
    [ ok = application:start(A) || A <- [sasl, ibrowse] ],
    Url = "http://local.wordpress.dev",
    CK = "ck_4c55fd532db0743d9b7a5e2ad3231d2b6d1e32a0",
    CS = "cs_e11d1944891290318d21dd5320d34248bd91c223",
    C = create_client(Url, CK, CS),
    test_print(C),

    Url2 = "https://local.wordpress.dev",
    C2 = create_client(Url2, CK, CS),
    %test_print(C2),
    ok.

test_print(C) ->
    %%
    %% Test Coupon Endpoints.
    %%
    io:format("~s~n", ["GET coupons?foo=bar"]),
    io:format("~p~n~n", [get(C, "coupons?foo=bar")]),

    io:format("~s~n", ["GET coupons?foo=bar&q=v"]),
    io:format("~p~n~n", [get(C, "coupons?foo=bar", [{q, "v"}])]),

    io:format("~s~n", ["GET coupons/126"]),
    io:format("~p~n~n", [get(C, "coupons/126")]),

    io:format("~s~n", ["GET coupons/code/test-new-coupn"]),
    io:format("~p~n~n", [get(C, "coupons/code/test-new-coupn")]),

    io:format("~s~n", ["GET coupons/code/does_not_exist"]),
    io:format("~p~n~n", [get(C, "coupons/code/does_not_exist")]),

    io:format("~s~n", ["POST coupons; but code aleady exists"]),
    CouponExists = #coupon{code="test"},
    io:format("~p~n~n", [post(C, "coupons", CouponExists)]),

    io:format("~s~n", ["POST coupons"]),
    Coupon0 = #coupon{code="coupon-from-erlang-xxx"},
    RespPost = post(C, "coupons", Coupon0),
    case RespPost of
        {ok, Coupon} ->
            io:format("~p~n~n", [Coupon0]),
            io:format("~p~n~n", [Coupon]),

            CouponId = lists:flatten(io_lib:format("~p", [Coupon#coupon.id])),
            io:format("~s~s~n", ["PUT coupons/", CouponId]),
            CouponUpdate = Coupon#coupon{amount="75", type="percent"},
            io:format("~p~n~n", [put(C, "coupons/" ++ CouponId, CouponUpdate)]),

            io:format("~s~s~n", ["DELETE coupons/", CouponId]),
            io:format("~p~n~n", [delete(C, "coupons/" ++ CouponId)]),

            done_with_post_put_delete;
        Else ->
            io:format("~p~n~n", [Else])
    end,

    %%
    %% Test Customer Endpoints.
    %%
    io:format("~s~n", ["GET customers?foo=bar"]),
    io:format("~p~n~n", [get(C, "customers?foo=bar")]),

    io:format("~s~n", ["GET customers?foo=bar&q=v&role=customer"]),
    io:format("~p~n~n", [get(C, "customers?foo=bar", [{q, "v"}, {role, "customer"}])]),

    io:format("~s~n", ["GET customers/2"]),
    io:format("~p~n~n", [get(C, "customers/2")]),

    io:format("~s~n", ["GET customers/email/richie.kotzen@example.com"]),
    io:format("~p~n~n", [get(C, "customers/email/richie.kotzen@example.com")]),

    io:format("~s~n", ["GET customers/email/does_not_exist"]),
    io:format("~p~n~n", [get(C, "customers/email/does_not_exist")]),

    io:format("~s~n", ["POST customers; but email aleady exists"]),
    CustomerExists = #customer{email="richie.kotzen@example.com"},
    io:format("~p~n~n", [post(C, "customers", CustomerExists)]),

    io:format("~s~n", ["POST customers"]),
    Cust0 = #customer{email="customer-from-erlang@example.com", password="password"},
    RespPost2 = post(C, "customers", Cust0),
    case RespPost2 of
        {ok, Customer} ->
            io:format("~p~n~n", [Cust0]),
            io:format("~p~n~n", [Customer]),

            CustId = lists:flatten(io_lib:format("~p", [Customer#customer.id])),
            io:format("~s~s~n", ["PUT customers/", CustId]),
            CustUpdate = Customer#customer{first_name="erlang", last_name="awesome"},
            io:format("~p~n~n", [put(C, "customers/" ++ CustId, CustUpdate)]),

            io:format("~s~s~n", ["DELETE customers/", CustId]),
            io:format("~p~n~n", [delete(C, "customers/" ++ CustId)]),

            done_with_post_put_delete;
        Else2 ->
            io:format("~p~n~n", [Else2])
    end,

    ok.

%% ----------------------------------------------------------------------------
%% Private Functions.
%% ----------------------------------------------------------------------------

%% @equiv api(client(), string(), get, [], empty)
api(Client=#client{}, Endpoint) ->
    api(Client, Endpoint, get, [], empty).

%% @equiv api(client(), string(), get|post|put|delete, [], empty)
api(Client=#client{}, Endpoint, Method) ->
    api(Client, Endpoint, Method, [], empty).

%% @doc Make request to WooCoomerce REST API.
%%
%% @spec api(client(), string(), get|post|put|delete, [], term()) -> {ok, term()}
%%                                                                 | {error, term()}
api(Client=#client{}, Endpoint, Method, QS0, Data) -> 
    Url0 = make_url(Client, Endpoint),
    {BaseUrl, QS1} = base_and_qs(Url0),
    QS = lists:flatten(QS0, QS1),
    Url = case is_ssl(Client) of
            true  ->
                append_qs(BaseUrl, QS);
            false ->
                SignedParams = signed_params(Client, Method, BaseUrl, QS),
                oauth:uri(BaseUrl, SignedParams)
          end,
    PL = clean_path_list(Endpoint),
    EpType = pl_to_atom(PL),

    %% If JSON is valid, do request to REST API.
    ReqBody = request_body(EpType, Data),
    case ReqBody of
        {ok, Body} ->
            Headers = request_headers(Client),
            Resp = request(Method, Url, Headers, Body),
            case Resp of
                {ok, _} -> resp_to_term(PL, Method, Resp);
                _       -> Resp
            end;
        {error, _} ->
            ReqBody
    end.

%% @doc Do HTTP request.
%%
%% @spec request(get|post|put|delete, string(), proplist(), string()) -> term()
request(Method, Url, Headers, Body) ->
    case ibrowse:send_req(Url, Headers, Method, Body) of
        Resp={ok, Status, _, RespBody} ->
            StatusCode = list_to_integer(Status),
            Json = list_to_binary(RespBody),
            case StatusCode >= 200 andalso StatusCode < 400 of
                true  -> {ok, Json};
                false ->
                    case from_json(Json, resp_errors) of
                        {ok, RespErrors} ->
                            {error, RespErrors};
                        _ ->
                            {error, Resp}
                    end
            end;
        Error ->
            Error
    end.

%% @doc Get request headers for this client.
%%
%% @spec request_headers(client()) -> proplist()
request_headers(Client) ->
    AuthHeaders = case is_ssl(Client) of
                true  -> [{basic_auth, {
                            Client#client.consumer_key,
                            Client#client.consumer_secret
                          }}];
                false -> []
              end,

    %% TODO(gedex) Move to pre-compile def.
    Headers = [
        {"User-Agent", "WooCommerce API Client - Erlang " ++ ?CLIENT_VER},
        {"Content-Type", "application/json"},
        {"Accept", "application/json"}
        ],
    lists:flatten([Headers|AuthHeaders]).

%% @doc Encode data to JSON
%% @spec request_body(atom(), list()|term()) -> {ok, string()} | {error, term()}
request_body(EndpointType, Data) ->
    case Data of
        empty -> {ok, ""};
        _     -> json_encode(EndpointType, Data)
    end.

%% @doc Encode a given data (could be list of records or a single record) into
%%      its JSON representation.
%%
%% @spec json_encode(atom(), list() -> {ok, string()} | {error, term()}
json_encode(EndpointType, Data) when is_list(Data) ->
    W = wrap_list_data(EndpointType, Data),
    json_encode_wrapper(W);

%% @spec json_encode(atom(), term() -> {ok, string()} | {error, term()}
json_encode(EndpointType, Data) ->
    W = wrap_record_data(EndpointType, Data),
    json_encode_wrapper(W).

%% @doc Encode data wrapper.
%%
%% @spec json_encode_wrapper(term()) -> {ok, string()} | {error, term()}
json_encode_wrapper(W) ->
    case W of
        {error, _}    -> W;
        {ok, Wrapper} ->
            case to_json(Wrapper) of
                {ok, Json} -> {ok, Json};
                Else       -> Else
            end
    end.

%% @doc Wrap a list before JSON encoded.
%%
%% @spec wrap_list_data(atom(), list()) -> {ok, #coupons{} 
%%                                            | #customers{}
%%                                            | #orders{}
%%                                            | #products{}}
%%                                       | {error, invalid_data}
wrap_list_data(EndpointType, Data) ->
    case Data of
        [] -> {error, empty_data};
        _  ->
            case EndpointType of
                coupon   -> {ok, #coupons{coupons=Data}};
                customer -> {ok, #customers{customers=Data}};
                order    -> {ok, #orders{orders=Data}};
                product  -> {ok, #products{products=Data}};
                _        -> {error, invalid_data}
            end
    end.

%% @doc  Wrap a record before JSON encoded.
%% @spec wrap_record_data(atom(), #coupon{} | #customer{} | #order{} | #order_note
%%                              | #order_note{} | #order_refund{} | #product{}
%%                              | #product_attribute{}) ->
%%                              {ok, #coupon_wrapper{} | #customer_wrapper{}
%%                                 | #order_wrapper{} | #order_note_wrapper{}
%%                                 | #order_refund_wrapper{} | #product_wrapper{}
%%                                 | #product_attribute_wrapper{}}
%%                            | {error, invalid_data}
wrap_record_data(EndpointType, Data) ->
    case EndpointType of
        coupon ->
            {ok, #coupon_wrapper{coupon=Data}};
        customer ->
            {ok, #customer_wrapper{customer=Data}};
        order ->
            {ok, #order_wrapper{order=Data}};
        order_note ->
            {ok, #order_note_wrapper{order_note=Data}};
        order_refund ->
            {ok, #order_refund_wrapper{order_refund=Data}};
        product ->
            {ok, #product_wrapper{product=Data}};
        product_attribute -> 
            {ok, #product_attribute_wrapper{product_attribute=Data}};
        webhook ->
            {ok, #webhook_wrapper{webhook=Data}};
        _ ->
            {error, invalid_data}
    end.
 
resp_to_term(PathList, Method, Resp) ->
    case pl_to_atom(PathList) of
        coupon   -> resp_to_coupon(PathList, Method, Resp);
        customer -> resp_to_customer(PathList, Method, Resp);
        order    -> resp_to_order(PathList, Method, Resp);
        product  -> resp_to_product(PathList, Method, Resp);
        report   -> resp_to_report(PathList, Method, Resp);
        webhook  -> resp_to_webhook(PathList, Method, Resp);
        _        -> resp_to_index(Resp)
    end.

resp_to_coupon(PathList, Method, Resp) ->
    {ok, Json} = Resp,
    case is_resp_with_multi_record(coupon, PathList, Method) of
        true  ->
            case from_json(Json, coupons) of
                {ok, CL} ->
                    {ok, CL#coupons.coupons};
                Else ->
                    Else
            end;
        false ->
            case Method of
                delete ->
                    case from_json(Json, resp_delete) of
                        {ok, RespDelete} -> {ok, RespDelete#resp_delete.message};
                        Else             -> Else
                    end;
                _ ->
                    case from_json(Json, coupon_wrapper) of
                        {ok, CW} ->
                            {ok, CW#coupon_wrapper.coupon};
                        Else ->
                            Else
                    end
            end
    end.

resp_to_customer(PathList, Method, Resp) ->
    {ok, Json} = Resp,
    case is_resp_with_multi_record(customer, PathList, Method) of
        true  ->
            io:format("~p~n", [Json]),
            case from_json(Json, customers) of
                {ok, CL} ->
                    io:format("~p~n", [CL]),
                    {ok, CL#customers.customers};
                Else ->
                    Else
            end;
        false ->
            case Method of
                delete ->
                    case from_json(Json, resp_delete) of
                        {ok, RespDelete} -> {ok, RespDelete#resp_delete.message};
                        Else             -> Else
                    end;
                _ ->
                    case from_json(Json, customer_wrapper) of
                        {ok, CW} ->
                            {ok, CW#customer_wrapper.customer};
                        Else ->
                            Else
                    end
            end
    end.


resp_to_order(PathList, Method, Resp) ->
    {ok, Resp}.

resp_to_product(PathList, Method, Resp) ->
    {ok, Resp}.

resp_to_report(PathList, Method, Resp) ->
    {ok, Resp}.

resp_to_webhook(PathList, Method, Resp) ->
    {ok, Resp}.

resp_to_index(Resp) ->
    {ok, Resp}.

is_resp_with_multi_record(coupon, PathList, Method) ->
    case Method of
        get  -> length(PathList) =:= 1;
        post -> lists:last(PathList) =:= "bulk";
        _    -> false
    end;

is_resp_with_multi_record(customer, PathList, Method) ->
    case Method of
        get ->
            case length(PathList) =:= 1 of
                true  -> true;
                false ->
                    case lists:last(PathList) of
                        "orders"    -> true;
                        "downloads" -> true;
                        _           -> false
                    end
            end;
        post -> lists:last(PathList) =:= "bulk";
        _    -> false
    end;

is_resp_with_multi_record(order, PathList, Method) ->
    case Method of
        get ->
            case length(PathList) =:= 1 of
                true  -> true;
                false ->
                    case lists:last(PathList) of
                        "notes"   -> true;
                        "refunds" -> true;
                        _         -> false
                    end
            end;
        post -> lists:last(PathList) =:= "bulk";
        _    -> false
    end;

is_resp_with_multi_record(product, PathList, Method) ->
    case Method of
        get ->
            case length(PathList) =:= 1 of
                true  -> true;
                false ->
                    case lists:last(PathList) of
                        "attributes"       -> true;
                        "categories"       -> true;
                        "tags"             -> true;
                        "orders"           -> true;
                        "reviews"          -> true;
                        "shipping_classes" -> true;
                        _                  -> false
                    end
            end;
        post -> lists:last(PathList) =:= "bulk";
        _    -> false
    end;

is_resp_with_multi_record(report, PathList, Method) ->
    length(PathList) =:= 1;

is_resp_with_multi_record(webhook, PathList, Method) ->
    case Method of
        get ->
            case length(PathList) =:= 1 of
                true  -> true;
                false ->
                    lists:last(PathList) =:= "deliveries"
            end;
        _ -> false
    end.

%% @doc Split endpoint path into list. Query string and hash are not considered.
%
%% @spec clean_path_list(string()) -> list()
clean_path_list(Endpoint) ->
    {Path, _, _} = mochiweb_util:urlsplit_path(Endpoint),
    PathList = string:tokens(Path, "/").

%% @doc Get signed parameters.
%% @spec signed_params(client(), atom(), string(), proplist()) -> proplist()
signed_params(Client, Method, Url, Params) ->
    oauth:sign(http_method_str(Method), Url, Params, consumer_tuple(Client), "", "").

%% @doc  HTTP Method atom to string.
%% @spec http_method_str(atom()) -> string()
http_method_str(Method) -> proplists:get_value(Method, ?HTTP_METHODS).

%% @doc  OAuth consumer tuple to be passed into oauth's functions.
%% @spec consumer_tuple(client()) -> tuple()
consumer_tuple(Client) ->
    {Client#client.consumer_key, Client#client.consumer_secret, hmac_sha1}.

%% @spec is_ssl(client()) -> atom()
is_ssl(Client) ->
    proplists:get_value(is_ssl, Client#client.options).

%% @doc  Build the URL for given client, endpoint, and query string.
%% @spec make_url(client(), string()) -> iolist()
make_url(Client=#client{}, Endpoint) -> 
    Url = case lists:suffix("/", Url2=Client#client.url) of
        true -> Url2;
        _    -> Url2 ++ "/"
    end,
    lists:flatten([
        Url, "wc-api/", proplists:get_value(version, Client#client.options), "/",
        Endpoint
        ]).

%% @doc  Extract base URL and list of QS from a URL.
%% @spec base_and_qs(string()) -> {string(), proplist()}
base_and_qs(Url) ->
    case http_uri:parse(Url) of
        {ok, {Scheme, UserInfo, Host, Port, Path, Query}} ->
            BaseUrl = make_base_url(Scheme, UserInfo, Host, Port, Path),
            QS = parse_qs(Query),
            {BaseUrl, QS};
        _ ->
            {Url, []}
    end.

%% @doc  Make base URL from parsed URL. This removes the query string.
%% @spec make_base_url(atom(), string(), string(), integer(), string()) -> string()
make_base_url(http, UserInfo, Host, 80, Acc) ->
    make_base_url(http, UserInfo, string:join([Host, Acc], ""));
make_base_url(https, UserInfo, Host, 443, Acc) ->
    make_base_url(https, UserInfo, string:join([Host, Acc], ""));
make_base_url(Scheme, UserInfo, Host, Port, Acc) ->
    make_base_url(Scheme, UserInfo, 
                  string:join([[Host, ":", integer_to_list(Port)], Acc], "")).

%% @spec make_base_url(atom(), list()|string(), list()) -> string()
make_base_url(Scheme, [], Acc) ->
    P = string:join([atom_to_list(Scheme), "://"], ""),
    string:join([P, Acc], "");
make_base_url(Scheme, UserInfo, Acc) ->
    P = string:join([atom_to_list(Scheme), ["://", UserInfo, "@"]], ""),
    string:join([P, Acc], "").

%% @spec parse_qs(string()) -> proplist()
parse_qs(QStr0) ->
    case QStr0 of
        [] -> [];
        _  ->
            QStr = string:substr(QStr0, 2),
            mochiweb_util:parse_qs(QStr)
    end.

%% @doc  Append QS proplist to full URL string.
%% @spec append_qs(string(), proplist()) -> iolist()
append_qs(Url, QS) ->
    case string:chr(Url, $?) > 0 of
        true  ->
            lists:flatten([Url, [["&", mochiweb_util:urlencode(QS)] || QS /= []]]);
        false ->
            lists:flatten([Url, [["?", mochiweb_util:urlencode(QS)] || QS /= []]])
    end.

%% @doc Path list to atom.
%%
%% @spec ep_to_atom(list()) -> atom()
pl_to_atom(PathList) ->
    case PathList of
        [] -> index;
        _  ->
            [H|_] = PathList,
            case H of
                "coupons"   -> coupon;
                "customers" -> ep_type_variation(customer, PathList);
                "orders"    -> ep_type_variation(order, PathList);
                "products"  -> ep_type_variation(product, PathList);
                "reports"   -> ep_type_variation(report, PathList);
                "webhooks"  -> ep_type_variation(webhook, PathList);
                _           -> unknown_endpoint
            end
    end.

%% @spec ep_type_variation(customer, list()) -> customer_order
%%                                            | customer_download
%%                                            | customer
ep_type_variation(customer, PathList) ->
    case lists:last(PathList) of
        "orders"    -> customer_order;
        "downloads" -> customer_download;
        _           -> customer
    end;

%% @spec ep_type_variation(order, list()) -> order_note
%%                                         | order_refund
%%                                         | order
ep_type_variation(order, PathList) ->
    HasNotes = fun(X) -> X =:= "notes" end,
    case lists:any(HasNotes, PathList) of
        true  -> order_note;
        false ->
            HasRefunds = fun(X) -> X =:= "refunds" end,
            case lists:any(HasRefunds, PathList) of
                true  -> order_refund;
                false -> order
            end
    end;

%% @spec ep_type_variation(product, list()) -> product_attribute
%%                                           | product_category
%%                                           | product_order
%%                                           | product_review
%%                                           | product
ep_type_variation(product, PathList) ->
    HasAttributes = fun(X) -> X =:= "attributes" end,
    case lists:any(HasAttributes, PathList) of
        true  -> product_attribute;
        false ->
            HasCategories = fun(X) -> X =:= "categories" end,
            case lists:any(HasCategories, PathList) of
                true  -> product_category;
                false ->
                    case lists:last(PathList) of
                        "orders"  -> product_order;
                        "reviews" -> product_review;
                        _         -> product
                    end
            end
    end;

%% @spec ep_type_variation(report, list()) -> report_sales
%%                                          | report_top_sellers
%%                                          | report
ep_type_variation(report, PathList) ->
    case lists:last(PathList) of
        "sales"       -> report_sales;
        "top_sellers" -> report_top_sellers;
        _             -> report
    end;

%% @spec ep_type_variation(webhook, list()) -> webhook
%%                                           | webhook_delivery
ep_type_variation(webhook, PathList) ->
    HasDeliveries = fun(X) -> X =:= "deliveries" end,
    case lists:any(HasDeliveries, PathList) of
        true  -> webhook_delivery;
        false -> webhook
    end;

ep_type_variation(_, _) -> unknown_endpoint.

%% @doc Convert list of binaries to list of strings. Used by to_json' post_decode.
%% @spec to_list_of_strings(list(binary())) -> list(string())
to_list_of_strings(L) -> lists:map(fun(X) -> binary_to_list(X) end, L).
