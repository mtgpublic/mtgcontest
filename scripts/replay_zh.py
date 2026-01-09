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
    login = input("请输入您的登录名(login)：").strip()
    password = getpass.getpass("请输入您的密码(password)：")

    try:
        resp = requests.post(
            SIGN_IN_URL,
            data={"login": login, "password": password},
            timeout=30,
        )
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        print(red(f"登录请求失败：{e}"))
        input("按回车键退出...")
        return 0

    if data.get("status") != "success":
        print(red(f"登录失败！错误信息：{data.get('message', '未知错误')}"))
        input("按回车键退出...")
        return 0

    print("登录成功！")
    sessionid = data.get("sessionid", "")
    replayid = input("请输入 Replay ID：").strip()

    try:
        rresp = requests.post(
            GET_REPLAY_URL,
            data={"replayid": replayid, "sessionid": sessionid},
            timeout=30,
        )
        rresp.raise_for_status()
        rdata = rresp.json()
    except Exception as e:
        print(red(f"获取 Replay 请求失败：{e}"))
        input("按回车键退出...")
        return 0

    if rdata.get("status") != "success":
        print(red(f"获取 Replay 失败！错误信息：{rdata.get('message', '未知错误')}"))
        input("按回车键退出...")
        return 0

    replay = str(rdata.get("replay", ""))
    prefix = replay[:64]
    print(f"Replay 前{len(prefix)}字符：{prefix}")

    filename = f"{replayid}.txt"
    try:
        with open(filename, "w", encoding="utf-8") as f:
            f.write(replay)
        print(f"Replay 已保存到文件：{filename}")
    except Exception as e:
        print(red(f"保存文件失败：{e}"))

    if copy_to_clipboard(replay):
        print("Replay 已复制到剪贴板。")
    else:
        print(red("复制到剪贴板失败（可安装 pyperclip 启用剪贴板功能）。"))

    input("按回车键退出...")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())