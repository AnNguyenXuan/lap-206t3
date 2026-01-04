import random
import string

def load_payloads(file_path):
    """Load payloads from file"""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            return [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        return []

def generate_domain_payload(min_len=3, max_len=20):
    """Generate random domain payload"""
    length = random.randint(min_len, max_len)
    chars = string.ascii_lowercase + string.digits + '-.'
    return ''.join(random.choice(chars) for _ in range(length))

def generate_search_payload(min_len=5, max_len=30):
    """Generate random search payload"""
    length = random.randint(min_len, max_len)
    chars = string.ascii_letters + ' '
    return ''.join(random.choice(chars) for _ in range(length))

def generate_random_payload(payload_type):
    """Generate payload based on type"""
    if payload_type == 'domain':
        return generate_domain_payload()
    elif payload_type == 'search':
        return generate_search_payload()
    elif payload_type == 'xss':
        return random.choice(load_payloads('xss-payloads.txt') or ['test'])
    elif payload_type == 'sqli':
        return random.choice(load_payloads('sqli-payloads.txt') or ['test'])
    return ''