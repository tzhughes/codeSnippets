

# create a class named Item with a price and a weight
class Item:
    def __init__(self, price, weight):
        self.price = price
        self.weight = weight

    def __str__(self):
        return f"Item: price={self.price}, weight={self.weight}"


# Parse minutes and seconds from a string in the format "MM:SS"
def parse_time(time_str):
    
    minutes, seconds = time_str.split(":")
    minutes.isdigit() and seconds.isdigit()
    return int(minutes), int(seconds)  

myString = "one two three"
print(myString.upper())
# Check that a string respects the format "MM:SS"


__init__
__str__
__len__

