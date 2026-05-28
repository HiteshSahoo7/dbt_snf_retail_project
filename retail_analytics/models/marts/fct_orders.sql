{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['order_id','order_item_id']
        
    )
}}

with orders as (
    select * from {{ ref('stg_sales_planning__orders') }}
),

order_items as (
    select * from {{ ref('stg_sales_planning__order_items') }}
),

final as (
    select o.order_id,
    i.order_item_id,
    i.product_id,
    o.customer_id,
    o.order_date,
    i.quantity,
    o.sales_emp_id,
    o.order_status,
    i.discount_percent
    from orders o left join order_items i ON o.order_id = i.order_id
)

select * from final 
{% if is_incremental() %}
    where order_date >= (select max(order_date) from {{this}})

{% endif %}
order by order_date desc
