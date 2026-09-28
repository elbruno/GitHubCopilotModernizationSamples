# Pricing and contract (synthetic)

Use decimal. Subtotal = unit price * quantity. Partner at quantity >= 3:
discount = Round(subtotal * 0.10m, 2, AwayFromZero); otherwise 0.
Net = subtotal - discount. Shipping = net >= 250 ? 0 : 12. Total = net + shipping.

| Type | Price | Quantity | Subtotal | Discount | Shipping | Total |
| --- | --- | --- | --- | --- | --- | --- |
| standard | 100 | 2 | 200 | 0 | 12 | 212 |
| partner | 100 | 2 | 200 | 0 | 12 | 212 |
| partner | 100 | 3 | 300 | 30 | 0 | 270 |
| partner | 33.35 | 3 | 100.05 | 10.01 | 12 | 102.04 |
| standard | 250 | 1 | 250 | 0 | 0 | 250 |
| standard | 249.99 | 1 | 249.99 | 0 | 12 | 261.99 |
| partner | 90 | 3 | 270 | 27 | 12 | 255 |

Success response has exactly `order_id`, `customer_type`, `subtotal`,
`discount`, `shipping`, `total`, and `review_note`. Never return ID/email.
Keep `review_note` explicitly null when unset. Enum values are `standard`
and `partner` strings, not 0/1. Monetary fields are numbers; property order,
whitespace and decimal trailing zeros do not matter.

Required input fields: `order_id`, `customer_id`, `customer_email`,
`customer_type`, `unit_price`, `quantity`, `correlation_id`. Exact case;
unknown and duplicate properties fail. Price: 0..1,000,000 with at most two
nonzero decimal places; quantity: integer 1..10,000. No numeric strings.
Nonblank string maxima: order 64, customer ID 128, email 256, correlation 128.
Types must be exactly `standard` or `partner`.

One object, <= 16,384 decoded characters, depth <= 8. Preserve support for
comments and trailing commas. Other Newtonsoft-only non-JSON syntax is not
supported. Preserve file, stdin, `-`, and `--help` entry points.
Exit 0 success/help, 2 invalid input, 3 I/O failure, 64 usage; fixed safe
stderr messages and empty stdout on errors. No taxes or currency conversion.
