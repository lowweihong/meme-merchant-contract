import json
import os
from upload_to_ipfs import upload_to_ipfs
from datetime import datetime
import hashlib

def update_metadata(token_id, image_ipfs_hash, buyer, prompt, payment_amount):
    # First create metadata file with token_id
    metadata = {
        "name": f"CS8803 Shiba HODLer #{token_id}",
        "description": (
            f"Your unique Dogecoin Shiba Inu shines in the CS8803 Spring 2025 blockchain world! "
            f"Minted with {payment_amount / 10**18} ETH. "
            f"This Shiba HODLs to the Moon!"
        ),
        "image": f"https://ipfs.io/ipfs/{image_ipfs_hash}",
        "attributes": [
            {"trait_type": "Token ID", "value": token_id},
            {"trait_type": "Mint Date", "value": datetime.utcnow().strftime("%Y-%m-%d")},
            {"trait_type": "Payment Amount", "value": str(payment_amount)},
            {"trait_type": "Prompt", "value": prompt}
        ]
    }

    os.makedirs("metadata", exist_ok=True)
    metadata_path = f"metadata/token_{token_id}.json"
    with open(metadata_path, "w") as f:
        json.dump(metadata, f, indent=2)

    try:
        metadata_ipfs_hash = upload_to_ipfs(metadata_path)
        return metadata_ipfs_hash
    except Exception as e:
        print(f"Metadata upload error: {e}")
        raise