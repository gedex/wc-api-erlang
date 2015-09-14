-define(CLIENT_VER, "v0.1.0").
-define(WC_DEFAULT_API_VER, "v3").
-define(HTTP_METHODS, [{get, "GET"},
                       {post, "POST"},
                       {put, "PUT"},
                       {delete, "DELETE"}
                       ]).

% Client.
-record(client,
        {
            url             :: string(),
            consumer_key    :: string(),
            consumer_secret :: string(),
            options         :: string()
        }).

% Response representing error.
-record(resp_error,
        {
            code    :: string(),
            message :: string()
        }).

% List of errors in a response.
-record(resp_errors,
        {
            errors :: list(#resp_error{})
        }).

% Response representing message after DELETE request.
-record(resp_delete,
        {
            message :: string()
        }).

% Response representing count.
-record(resp_count,
        {
            count :: number()
        }).

% Coupon
-record(coupon,
        {
            id                              :: number(),
            code                            :: string(),
            type="fixed_cart"               :: string(),
            created_at                      :: string(),
            updated_at                      :: string(),
            amount                          :: string(),
            individual_use                  :: boolean(),
            product_ids=[]                  :: list(number()),
            exclude_product_ids=[]          :: list(number()),
            usage_limit                     :: number(),
            usage_limit_per_user            :: number(),
            limit_usage_to_x_items          :: number(),
            usage_count=0                   :: number(),
            expiry_date                     :: string(),
            enable_free_shipping            :: boolean(),
            product_category_ids=[]         :: list(number()),
            exclude_product_category_ids=[] :: list(number()),
            exclude_sale_items              :: boolean(),
            minimum_amount                  :: string(),
            maximum_amount                  :: string(),
            customer_emails=[]              :: list(string()),
            description                     :: string()
        }).

% Single Coupon Wrapper.
-record(coupon_wrapper,
        {
            coupon :: #coupon{}
        }).

% List of Coupons.
-record(coupons,
        {
            coupons :: list(#coupon{} | #resp_error{})
        }).

% Customer Shipping Address
-record(customer_shipping_address,
        {
            first_name :: string(),
            last_name  :: string(),
            company    :: string(),
            address_1  :: string(),
            address_2  :: string(),
            city       :: string(),
            state      :: string(),
            postcode   :: string(),
            country    :: string()
        }).

% Customer Billing Address
-record(customer_billing_address,
        {
            first_name :: string(),
            last_name  :: string(),
            company    :: string(),
            address_1  :: string(),
            address_2  :: string(),
            city       :: string(),
            state      :: string(),
            postcode   :: string(),
            country    :: string(),
            email      :: string(),
            phone      :: string()
        }).

% Customer
-record(customer,
        {
            id               :: number(),
            created_at       :: string(),
            email            :: string(),
            password=""      :: string(),
            first_name       :: string(),
            last_name        :: string(),
            username         :: string(),
            last_order_id    :: number(),
            last_order_date  :: string(),
            orders_count     :: number(),
            total_spent      :: string(),
            avatar_url       :: string(),
            billing_address  :: #customer_billing_address{},
            shipping_address :: #customer_shipping_address{}
        }).

% Single Customer Wrapper.
-record(customer_wrapper,
        {
            customer :: #customer{}
        }).

% List of Customers.
-record(customers,
        {
            customers :: list(#customer{})
        }).

% Product Attribute.
-record(product_attribute,
        {
            id           :: number(),
            name         :: string(),
            slug         :: string(),
            type         :: string(),
            order_by     :: string(),
            has_archives :: boolean()
        }).

% Single Product Attribute Wrapper.
-record(product_attribute_wrapper,
        {
            product_attribute :: #product_attribute{}
        }).

% List of Product Attributes.
-record(product_attributes,
        {
            product_attributes :: list(#product_attribute{})
        }).

% Product Dimension.
-record(product_dimension,
        {
            length :: string(),
            width  :: string(),
            height :: string(),
            unit   :: string()
        }).

% Product Image.
-record(product_image,
        {
            id         :: number(),
            created_at :: string(),
            updated_at :: string(),
            src        :: string(),
            title      :: string(),
            alt        :: string(),
            position   :: number()
        }).

% Product Download.
-record(product_download,
        {
            id   :: string(),
            name :: string(),
            file :: string()
        }).

% Product Variation.
-record(product_variation,
        {
            id                    :: number(),
            created_at            :: string(),
            updated_at            :: string(),
            downloadable          :: boolean(),
            virtual               :: boolean(),
            permalink             :: string(),
            sku                   :: string(),
            price                 :: number(),
            regular_price         :: number(),
            sale_price            :: number(),
            sale_price_dates_from :: string(),
            sale_price_dates_to   :: string(),
            taxable               :: boolean(),
            tax_status            :: string(),
            tax_class             :: string(),
            managing_stock        :: boolean(),
            stock_quantity        :: number(),
            in_stock              :: boolean(),
            backordered           :: boolean(),
            purchaseable          :: boolean(),
            visible               :: boolean(),
            on_sale               :: boolean(),
            weight                :: string(),
            dimensions            :: #product_dimension{},
            shipping_class        :: string(),
            shipping_class_id     :: number(),
            images                :: list(#product_image{}),
            attributes            :: list(#product_attribute{}),
            downloads             :: list(#product_download{}),
            download_limit        :: number(),
            download_expiry       :: number()
        }).

% Product Default Attribute.
-record(product_default_attribute,
        {
            name   :: string(),
            slug   :: string(),
            option :: string()
        }).

% Product Category.
-record(product_category,
        {
            id          :: number(),
            name        :: string(),
            slug        :: string(),
            parent      :: number(),
            description :: string(),
            display     :: string(),
            image       :: string(),
            count       :: boolean()
        }).

% Single Product Category Wrapper.
-record(product_category_wrapper,
        {
            product_category :: #product_category{}
        }).

% List of Product Categories.
-record(product_categories,
        {
            product_categories :: list(#product_category{})
        }).

% Product Review.
-record(product_review,
        {
            id             :: number(),
            created_at     :: string(),
            rating         :: string(),
            reviewer_name  :: string(),
            reviewer_email :: string(),
            verified       :: boolean()
        }).

% List of Product Reviews.
-record(product_reviews,
        {
            product_reviews :: list(#product_review{})
        }).

% Product
-record(product,
        {
            title                         :: string(),
            id                            :: number(),
            created_at                    :: string(),
            updated_at                    :: string(),
            type                          :: string(),
            status                        :: string(),
            downloadable                  :: boolean(),
            virtual                       :: boolean(),
            permalink                     :: string(),
            sku                           :: string(),
            price                         :: number(),
            regular_price                 :: number(),
            sale_price                    :: number(),
            sale_price_dates_from         :: string(),
            sale_price_dates_to           :: string(),
            price_html                    :: string(),
            taxable                       :: boolean(),
            tax_status                    :: string(),
            tax_class                     :: string(),
            managing_stock                :: boolean(),
            stock_quantity                :: number(),
            in_stock                      :: boolean(),
            backorders_allowed            :: boolean(),
            backordered                   :: boolean(),
            backorders                    :: boolean(),
            sold_individually             :: boolean(),
            purchaseable                  :: boolean(),
            featured                      :: boolean(),
            visible                       :: boolean(),
            catalog_visibility            :: string(),
            on_sale                       :: boolean(),
            weight                        :: string(),
            dimensions                    :: #product_dimension{},
            shipping_required             :: boolean(),
            shipping_taxable              :: boolean(),
            shipping_class                :: string(),
            shipping_class_id             :: number(),
            description                   :: string(),
            enable_html_description       :: boolean(),
            short_description             :: string(),
            enable_html_short_description :: boolean(),
            reviews_allowed               :: boolean(),
            average_rating                :: string(),
            rating_count                  :: number(),
            related_ids                   :: list(number()),
            upsell_ids                    :: list(number()),
            cross_sell_ids                :: list(number()),
            parent_id                     :: number(),
            categories                    :: list(string()),
            tags                          :: list(term()),
            images                        :: list(#product_image{}),
            featured_src                  :: string(),
            attributes                    :: list(#product_attribute{}),
            default_attributes            :: list(#product_default_attribute{}),
            downloads                     :: list(#product_download{}),
            download_limit                :: number(),
            download_expiry               :: number(),
            download_type                 :: string(),
            purchase_note                 :: string(),
            total_sales                   :: number(),
            variations                    :: list(#product_variation{}),
            parent                        :: list(term()),
            product_url                   :: string(),
            button_text                   :: string()
        }).

% Single Product Wrapper.
-record(product_wrapper,
        {
            product :: #product{}
        }).

% List of Products.
-record(products,
        {
            products :: list(#product{})
        }).

% Order Fee Line.
-record(order_fee_line,
        {
            id        :: number(),
            title     :: string(),
            taxable   :: boolean(),
            tax_class :: string(),
            total     :: number(),
            total_tax :: number()
        }).

% Order Tax Line.
-record(order_tax_line,
        {
            id       :: number(),
            rate_id  :: number(),
            code     :: string(),
            title    :: string(),
            total    :: number(),
            compound :: boolean()
        }).


% Order Shipping Line.
-record(order_shipping_line,
        {
            id           :: number(),
            method_id    :: string(),
            method_title :: string(),
            total        :: number()
        }).

% Order Coupon Line.
-record(order_coupon_line,
        {
            id     :: number(),
            code   :: string(),
            amount :: number()
        }).

% Order Payment Details.
-record(order_payment_details,
        {
            method_id    :: string(),
            method_title :: string(),
            paid         :: boolean()
        }).

% Order Line Item Meta.
-record(order_line_item_meta,
        {
            key   :: string(),
            label :: string(),
            value :: string()
        }).

% Order Line Item.
-record(order_line_item,
        {
            id           :: number(),
            subtotal     :: number(),
            subtotal_tax :: number(),
            total        :: number(),
            total_tax    :: number(),
            price        :: number(),
            quantity     :: number(),
            tax_class    :: string(),
            name         :: string(),
            product_id   :: number(),
            sku          :: string(),
            meta         :: list(#order_line_item_meta{})
        }).

% Order Note.
-record(order_note,
        {
            id            :: number(),
            created_at    :: string(),
            note          :: string(),
            customer_note :: boolean()
        }).

% Single Order Note Wrapper.
-record(order_note_wrapper,
        {
            order_note :: #order_note{}
        }).

% List of Order Notes.
-record(order_notes,
        {
            order_notes :: list(#order_note{})
        }).

% Order Refund.
-record(order_refund,
        {
            id         :: number(),
            created_at :: string(),
            amount     :: number(),
            reason     :: string(),
            line_items :: list(#order_line_item{})
        }).

% Single Order Refund Wrapper.
-record(order_refund_wrapper,
        {
            order_refund :: #order_refund{}
        }).

% List of Order Refunds.
-record(order_refunds,
        {
            order_refunds :: list(#order_refund{})
        }).

% Order.
-record(order,
        {
            id                        :: number(),
            order_number              :: number(),
            created_at                :: string(),
            updated_at                :: string(),
            completed_at              :: string(),
            status                    :: string(),
            currency                  :: string(),
            total                     :: number(),
            subtotal                  :: number(),
            total_line_items_quantity :: number(),
            total_tax                 :: number(),
            total_shipping            :: number(),
            cart_tax                  :: number(),
            shipping_tax              :: number(),
            total_discount            :: number(),
            shipping_methods          :: string(),
            payment_details           :: #order_payment_details{},
            billing_address           :: #customer_billing_address{},
            shipping_address          :: #customer_shipping_address{},
            note                      :: string(),
            customer_ip               :: string(),
            customer_user_agent       :: string(),
            customer_id               :: number(),
            view_order_url            :: string(),
            line_items                :: list(#order_line_item{}),
            shipping_lines            :: list(#order_shipping_line{}),
            tax_lines                 :: list(#order_tax_line{}),
            fee_lines                 :: list(#order_fee_line{}),
            coupon_lines              :: list(#order_coupon_line{}),
            customer                  :: #customer{}
        }).

% Single Order Wrapper.
-record(order_wrapper,
        {
            order :: #order{}
        }).

% List of Orders.
-record(orders,
        {
            orders :: list(#order{})
        }).

% List of Reports
-record(list_reports,
        {
            reports :: list(string())
        }).

% Top Sellers Item
-record(top_sellers_report_item,
        {
            title      :: string(),
            product_id :: number(),
            quantity   :: number()
        }).

% Top Sellers Report
-record(top_sellers_report,
        {
            top_sellers :: list(#top_sellers_report_item{})
        }).

% Sales Report
-record(sales_report,
        {
            total_sales       :: number(),
            average_sales     :: number(),
            total_orders      :: number(),
            total_items       :: number(),
            total_tax         :: number(),
            total_shipping    :: number(),
            total_discount    :: number(),
            totals_grouped_by :: string(),
            totals            :: term(),
            total_customers   :: number()
        }).

% Wrapper for Sales Report.
-record(sales_report_wrapper,
        {
            sales :: #sales_report{}
        }).

% Webhook
-record(webhook,
        {
            id           :: number(),
            name         :: string(),
            status       :: string(),
            topic        :: string(),
            resource     :: string(),
            event        :: string(),
            hooks        :: list(string()),
            delivery_url :: string(),
            created_at   :: string(),
            updated_at   :: string()
        }).

% Single Webhook Wrapper.
-record(webhook_wrapper,
        {
            webhook :: #webhook{}
        }).

% List of Webhooks.
-record(webhooks,
        {
            webhooks :: list(#webhook{})
        }).

% Webhook Delivery
-record(webhook_delivery,
        {
            id               :: number(),
            duration         :: number(),
            summary          :: string(),
            request_method   :: string(),
            request_url      :: string(),
            request_headers  :: term(),
            request_body     :: string(),
            response_code    :: string(),
            response_message :: string(),
            response_headers :: term(),
            response_body    :: string(),
            created_at       :: string()
        }).

% Single Webhook Delivery Wrapper.
-record(webhook_delivery_wrapper,
        {
            webhook_delivery :: #webhook_delivery{}
        }).

% List of Webhook Deliveries.
-record(webhook_deliveries,
        {
            webhook_deliveries :: list(#webhook_delivery{})
        }).
