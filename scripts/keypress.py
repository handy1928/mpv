from pynput.keyboard import Key, Controller
import sys

keyboard = Controller()

if sys.argv[1] == "next_episode":
    keyboard.press(Key.right)
    keyboard.release(Key.right)
elif sys.argv[1] == "previous_episode":
    keyboard.press(Key.left)
    keyboard.release(Key.left)