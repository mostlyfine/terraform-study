from app import returnBackwardString
import unittest

class TestApp(unittest.TestCase):
    def test_return_backwards_string(self):
        random_string = "This is test string."
        random_string_reversed = ".gnirts tset si sihT"
        self.assertSetEqual(random_string_reversed, returnBackwardString(random_string))

if __name__ == "__main__":
    unittest.main()
