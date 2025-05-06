import os
import requests
from dotenv import load_dotenv
import json

def upload_to_ipfs(file_path):
    load_dotenv()
    PINATA_API_KEY = os.getenv("PINATA_API_KEY")
    PINATA_SECRET_API_KEY = os.getenv("PINATA_SECRET_API_KEY")
    if not PINATA_API_KEY or not PINATA_SECRET_API_KEY:
        raise Exception("Pinata API keys missing")
    
    url = "https://api.pinata.cloud/pinning/pinFileToIPFS"
    headers = {
        "pinata_api_key": PINATA_API_KEY,
        "pinata_secret_api_key": PINATA_SECRET_API_KEY
    }
    
    # Get the tokenId from filename (assuming filename format: token_<tokenId>.*)
    token_id = os.path.basename(file_path).split('_')[1].split('.')[0]
    
    # Add metadata to pin request to influence IPFS hash
    pinata_options = {
        "pinataMetadata": {
            "name": f"token_{token_id}",
            "keyvalues": {
                "tokenId": token_id
            }
        }
    }
    
    with open(file_path, "rb") as file:
        files = {
            "file": (os.path.basename(file_path), file),
            "pinataOptions": (None, json.dumps(pinata_options), "application/json")
        }
        response = requests.post(url, headers=headers, files=files)
        response.raise_for_status()
        ipfs_hash = response.json()["IpfsHash"]
        return ipfs_hash