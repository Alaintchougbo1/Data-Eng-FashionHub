import json, random, uuid, time, sys
from datetime import datetime, timedelta

def event(customer_id:int, product_ids:list[str]):
    return {
        "event_id": str(uuid.uuid4()),
        "ts": (datetime.utcnow() - timedelta(seconds=random.randint(1, 3600*24*7))).isoformat()+"Z",
        "user": {"id": customer_id, "country": random.choice(["US","FR","DE","GB","ES","IT","CA","BR","AU","JP","IN"])},
        "session": {"id": str(uuid.uuid4()), "ref": random.choice(["ads","organic","email"]) },
        "actions": [
            {"type":"view","product_id": random.choice(product_ids)},
            {"type":"add_to_cart","product_id": random.choice(product_ids), "qty": random.randint(1,3)}
        ],
        "device": {"ua":"Mozilla/5.0","os": random.choice(["ios","android","web"])}
    }

if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv)>1 else 1000
    product_ids = [str(i) for i in range(1,501)]
    for i in range(n):
        print(json.dumps(event(random.randint(1,5000), product_ids)))
