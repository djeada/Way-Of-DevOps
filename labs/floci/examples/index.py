"""Lab 06: stateless order validator. Demo data only."""
import json

def handler(event, context):
    order = event if isinstance(event, dict) else json.loads(event)
    product = str(order.get("product", "")).strip()
    qty = order.get("quantity")
    if not product or not isinstance(qty, int) or isinstance(qty, bool) or qty <= 0:
        return {"accepted": False, "reason": "invalid product or quantity"}
    return {"accepted": True, "product": product, "quantity": qty}
