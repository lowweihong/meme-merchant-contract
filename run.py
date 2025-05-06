from process_image import generate_image
from upload_to_ipfs import upload_to_ipfs
from update_metadata import update_metadata

from web3 import Web3
from solcx import compile_source, install_solc
import solcx
from solcx import compile_source
import math
from time import sleep
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
chainId=1337
exploit_address = ''#TODO: Place the deployed address from deploy.ipynb here
private_key = ''#TODO: Place your secret key here
account = w3.eth.account.from_key(private_key)
YOURPK = account.address

solcx.install_solc('0.5.17')
gas_limit = 8000000

with open("ShibaPayment.sol") as f:
    contract_source = f.read()
compiled_sol = compile_source(contract_source, solc_version="0.5.17")
contract_interface = compiled_sol[f'<stdin>:ShibaPayment']
abi = contract_interface['abi']
contract = w3.eth.contract(abi=contract_interface['abi'],
                           bytecode=contract_interface['bin'])

deployed_contract = w3.eth.contract(address=exploit_address, abi=contract_interface['abi'])


def process_user_payments(user_address):
    # Get total payments for this user
    payment_count = deployed_contract.functions.userPaymentCount(user_address).call()
    
    for index in range(payment_count):
        try:
            # Get payment details for each index
            payment = deployed_contract.functions.userPayments(user_address, index).call()
            sender, fee, tokenId, status, url = payment
            if status == 0:
                print(f"\nProcessing {payment_count} payments for user {user_address}")
                print()
                print(f"\nPayment {index + 1}:")
                print(f"Sender: {sender}")
                print(f"Fee: {fee}")
                print(f"TokenId: {tokenId.hex()}")
                print(f"status: {status}")
                print(f"url: {url}")
                
                # Here you can add your IPFS upload and metadata update logic
                image_path = generate_image('', tokenId.hex(), sender)
                ipfs_hash = upload_to_ipfs(image_path)
                metadata_ipfs_hash = update_metadata(tokenId.hex(), ipfs_hash, sender, '', fee)
                image_url = f"https://indigo-rapid-swan-980.mypinata.cloud/ipfs/{ipfs_hash}"

                # Update URL on-chain
                url_tx = deployed_contract.functions.updatePaymentUrl(
                    user_address,
                    index,
                    image_url
                ).build_transaction({
                    'from': account.address,
                    'gas': gas_limit,
                    'nonce': w3.eth.get_transaction_count(account.address),
                    'gasPrice': math.floor(w3.eth.gas_price * 1.2),
                    'chainId': chainId
                })
                
                signed_tx = w3.eth.account.sign_transaction(url_tx, private_key)
                tx_hash = w3.eth.send_raw_transaction(signed_tx.raw_transaction)
                tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

                updatePaymentStatus = deployed_contract.functions.updatePaymentStatus(user_address, index, 1).build_transaction({
                    'from': account.address,
                    'gas': gas_limit,
                    'nonce': w3.eth.get_transaction_count(account.address),
                    'gasPrice': math.floor(w3.eth.gas_price*1.2),
                    'chainId': chainId,
                })
                # Sign and send update transaction
                signed_tx = w3.eth.account.sign_transaction(updatePaymentStatus, private_key)
                raw_tx = getattr(signed_tx, 'rawTransaction', None) or getattr(signed_tx, 'raw_transaction')
                tx_hash = w3.eth.send_raw_transaction(raw_tx)
                tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
                print(f"Update transaction hash: {tx_hash.hex()}")
                print(f"Update transaction receipt: {tx_receipt}")
                print("Payment status updated successfully.")
            else:
                print("Nothing to process")
            
        except Exception as e:
            print(f"Error processing payment {index} for user {user_address}: {e}")

# Get all users who have made payments
def process_all_users():
    # Get user count
    user_count = deployed_contract.functions.getUserCount().call({'from': YOURPK})
    print(f"Total users: {user_count}")
    
    # Process each user's payments
    for i in range(user_count):
        try:
            user_address = deployed_contract.functions.allUsers(i).call({'from': YOURPK})
            # print(f"\nProcessing user {i + 1}/{user_count}: {user_address}")
            process_user_payments(user_address)
        except Exception as e:
            print(f"Error processing user {i}: {e}")
        
if __name__ == "__main__":
    while True:
        # Run the processing
        process_all_users()
        sleep(5)
