WooCommerce REST API - Erlang Client
====================================

Erlang client for WooCommerce REST API.

_Under heavy development. Not ready yet._

## Quick Start

```
git clone git://github.com/gedex/wc-api-erlang
cd wc-api-erlang
make
```

First, start up an Erlang shell with the path to `wc-api-erlang` and all
dependencies included, the start sasl and ibrowse:

```
erl -pa path/to/wc-api-erlang/ebin path/to/wc-api-erlang/deps/*/ebin
Eshell V6.2  (abort with ^G)
1> [ ok = application:start(A) || A <- [sasl, ibrowse]  ].
```

Next, create your client:

```
2> Url = "https://local.wordpress.dev",
2> CK = "ck_4c55fd532db0743d9b7a5e2ad3231d2b6d1e32a0",
2> CS = "cs_e11d1944891290318d21dd5320d34248bd91c223",
2> C = wc_api:create_client(Url, CK, CS).
{client,"https://local.wordpress.dev",
        "ck_4c55fd532db0743d9b7a5e2ad3231d2b6d1e32a0",
        "cs_e11d1944891290318d21dd5320d34248bd91c223",
        [{is_ssl,true},{version,"v3"}]}
```

Pass the client to `wc_api:get/2`, `wc_api:get/3`, `wc_api:post/3`, `wc_api:put/3`, `wc_api:delete/2`, or `wc_api:delete/3` as first argument. Here's an example:

```
%% Get list of coupons.
3> {ok, Coupons} = get(C, "coupons").
{ok,[{coupon,140,"coupon-from-erlang-a","fixed_cart",
             "2015-09-14T03:05:14Z","2015-09-14T03:05:14Z","0.00",false,
             [],[],undefined,undefined,0,0,undefined,false,[],[],false,
             "0.00","0.00",[],[]},
     {coupon,138,"test","fixed_cart","2015-09-14T03:05:14Z",
             "2015-09-14T03:05:14Z","0.00",false,[],[],undefined,
             undefined,0,0,undefined,false,[],[],false,"0.00","0.00",[],
             []},
     {coupon,126,"test-new-coupn","fixed_cart",
             "2015-09-09T12:45:02Z","2015-09-09T12:45:02Z","0.00",false,
             [],[],undefined,undefined,0,0,undefined,false,[],[],false,
             "0.00","0.00",[],[]},
     {coupon,105,"test coupon #4","fixed_cart",
             "2015-09-07T19:06:21Z","2015-09-07T19:06:55Z","100.00",
             false,[],[],undefined,undefined,0,1,undefined,false,[],[],
             false,"0.00","0.00",[],[]},
     {coupon,103,"test coupon #2","percent",
             "2015-09-07T19:02:47Z","2015-09-07T19:03:08Z","25.00",false,
             [],[],undefined,undefined,0,3,"2015-10-31T00:00:00Z",false,
             [],[],false,"0.00","0.00",[],...},
     {coupon,102,"test coupon #1","fixed_cart",
             "2015-09-07T19:02:28Z","2015-09-07T19:02:28Z","100000.00",
             false,[],[],undefined,undefined,0,0,"2015-10-31T00:00:00Z",
             false,[],[],false,"0.00",
             [...],...}]}
```

## Examples

```
% Include records.
rr(wc_api).

% Coupons
get(C, "coupons").
get(C, "coupons/1").
get(C, "coupons/code/coupon-code").
NewCoupon = #coupon{code="test-new-coupon"}.
post(C, "coupons", NewCoupon).
EditCoupon = NewCoupon#coupon{type="percent", amount=75}.
put(C, "coupons/2", EditCoupon).
delete(C, "coupons/2")
```
