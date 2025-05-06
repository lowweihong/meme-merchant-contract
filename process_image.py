import requests
import os
from PIL import Image
from io import BytesIO
from PIL import Image, ImageDraw, ImageFont

def generate_image(prompt, token_id, sender_address, crop=False, watermark=False):
    """
    Generate a customized Doge meme image using memegen.link API and crop bottom
    
    Args:
        prompt (str): User's input text
        token_id (str): Unique token identifier
        sender_address (str): User's wallet address
    
    Returns:
        str: Path to the generated image file
    """
    try:
        # Clean up prompt for URL (replace spaces and special characters)
        # cleaned_prompt = prompt.replace(' ', '_').replace('?', '~q').replace('#', '~h')
        
        # # Create shortened address for watermark
        # short_address = f"{sender_address[:6]}...{sender_address[-4:]}"
        
        # # Format bottom text with address and token ID
        # bottom_text = f"HODLer_{short_address}__{token_id[:8]}"
        
        # # Construct API URL
        # url = f"https://api.memegen.link/images/doge/Buzzcoin/{cleaned_prompt}.png"

        res = requests.get('https://meme-api.com/gimme/cryptocurrencymemes')
        # Download the meme
        url = res.json()["url"]
        # user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        # urllib.request.urlopen(urllib.request.Request(meme_url, headers={"User-Agent": user_agent}))
        
        # Make request to API
        response = requests.get(url, stream=True)
        response.raise_for_status()

        # Create images directory if it doesn't exist
        os.makedirs("images", exist_ok=True)
        
        # Save cropped image with token ID
        image_path = f"images/token_{token_id[:8]}.png"
        # Open image with Pillow
        img = Image.open(BytesIO(response.content))

        if crop:
            # Calculate crop dimensions (remove bottom 10%)
            width, height = img.size
            crop_height = int(height * 0.92)  # Keep 90% of height
            img = img.crop((0, 0, width, crop_height))
            
            # Add watermark
            draw = ImageDraw.Draw(img)

        if watermark:
            # Try to use a system font, fallback to default if not found
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
            except:
                font = ImageFont.load_default()
            
            # Create watermark text
            watermark = f"HODLer: {sender_address[:6]}...{sender_address[-4:]}"
            
            # Get text size
            text_bbox = draw.textbbox((0, 0), watermark, font=font)
            text_width = text_bbox[2] - text_bbox[0]
            text_height = text_bbox[3] - text_bbox[1]
            
            # Calculate position (bottom right with padding)
            padding = 10
            x =padding# width - text_width - padding
            y =padding# crop_height - text_height - padding
            
            # Add semi-transparent background for better readability
            draw.rectangle(
                [(x - 5, y - 5), (x + text_width + 5, y + text_height + 5)],
                fill=(255, 255, 255, 128)
            )
            
            # Draw text
            draw.text((x, y), watermark, font=font, fill=(0, 0, 0, 255))
            print(f"Image generated with watermark: {image_path}")
        
        # Save image with watermark
        image_path = f"images/token_{token_id[:8]}.png"
        img.save(image_path, "PNG")
        
        return image_path
        
    except Exception as e:
        print(f"Error generating/cropping image: {e}")
        raise


# Test the function
test_prompt = "Such Web3 Much Wow"
test_token_id = "44e50dbc1473fa8702d1924ec017af1b6f4d40670c74887452d6dd74ec3b4010"
test_address = "0x229839FE6ACE6FcC674DF168C85E84D2fd0f4693"

try:
    image_path = generate_image(test_prompt, test_token_id, test_address)
    print(f"Test successful! Cropped image saved to: {image_path}")
except Exception as e:
    print(f"Test failed: {e}")
