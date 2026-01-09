import getpass
import requests

SIGN_IN_URL = "https://infinitode.prineside.com/?m=api&a=signIn&v=208"
GET_REPLAY_URL = "https://infinitode.prineside.com/?m=api&a=getReplay&v=208"


def red(msg: str) -> str:
    return f"\033[31m{msg}\033[0m"


def copy_to_clipboard(text: str) -> bool:
    try:
        import pyperclip  # type: ignore

        pyperclip.copy(text)
        return True
    except Exception:
        return False


def main() -> int:
    login = input("Enter your login: ").strip()
    password = getpass.getpass("Enter your password: ")

    try:
        resp = requests.post(
            SIGN_IN_URL,
            data={"login": login, "password": password},
            timeout=30,
        )
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        print(red(f"Sign-in request failed: {e}"))
        input("Press Enter to exit...")
        return 0

    if data.get("status") != "success":
        print(red(f"Sign-in failed: {data.get('message', 'Unknown error')}"))
        input("Press Enter to exit...")
        return 0

    print("Sign-in successful.")
    sessionid = data.get("sessionid", "")
    replayid = input("Enter Replay ID: ").strip()

    try:
        rresp = requests.post(
            GET_REPLAY_URL,
            data={"replayid": replayid, "sessionid": sessionid},
            timeout=30,
        )
        rresp.raise_for_status()
        rdata = rresp.json()
    except Exception as e:
        print(red(f"GetReplay request failed: {e}"))
        input("Press Enter to exit...")
        return 0

    if rdata.get("status") != "success":
        print(red(f"GetReplay failed: {rdata.get('message', 'Unknown error')}"))
        input("Press Enter to exit...")
        return 0

    replay = str(rdata.get("replay", ""))
    prefix = replay[:64]
    print(f"Replay first {len(prefix)} chars: {prefix}")

    filename = f"{replayid}.txt"
    try:
        with open(filename, "w", encoding="utf-8") as f:
            f.write(replay)
        print(f"Replay saved to: {filename}")
    except Exception as e:
        print(red(f"Failed to save file: {e}"))

    if copy_to_clipboard(replay):
        print("Replay copied to clipboard.")
    else:
        print(red("Failed to copy to clipboard (install pyperclip to enable clipboard support)."))

    input("Press Enter to exit...")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())