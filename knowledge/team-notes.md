# Fictional team notes

All names, conversations, customers, and policies here are synthetic.

**Maya, finance:** "A partner buying two items is still full price. At three,
take ten percent off the whole subtotal. Round the discount once, away from
zero at the midpoint. Shipping uses the discounted net, not the subtotal."

**Alex, integration:** "Our consumers expect `customer_type` as a lowercase
string, numbers for money, and `review_note: null` even when nobody wrote a
note. A nicer C# property name is not permission to change the wire."

**Sam, platform:** "Use the little `IAuditTrail` component. It only accepts a
safe correlation ID and total. Do not write business diagnostics to stdout."

**Jo, privacy review:** "A failed request is not permission to dump the request.
Test error paths with synthetic sentinels too. An email can appear in an
exception message just as easily as an ordinary log."

These behaviors already exist in the legacy source. Its two visible smoke
tests cover only a standard quote and a malformed request. The skill captures
the reasons and expands review criteria; it does not reveal unknowable code.
