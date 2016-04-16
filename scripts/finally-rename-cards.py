import os


base_dir = "/home/paul/elm/set/images/cards"

def changeBase(n, b):
  "Returns a string."
  if n < b:
    return str(n)
  else:
    r = n % b
    q = n / b
    return changeBase(q, b) + str(r)


# Get all the png filenames
fileNames = os.listdir(base_dir)
# Strip off ".png"
fileNumbers = [name[:-4] for name in fileNames]
# Convert each number to ternary
ternary = [changeBase(int(n), 3) for n in fileNumbers]
# Left-pad each ternary number with 0's
ternaryStrings = [s.rjust(4, '0') for s in ternary]


properties = [
  ['red', 'green', 'purple'],
  ['one', 'two', 'three'],
  ['diamond', 'oval', 'squiggle'],
  ['solid', 'striped', 'open']
]

for n in range(len(fileNames)):
  attributes = [0] * 4
  for i in range(4):
    attributes[i] = properties[i][int(ternaryStrings[n][i])]
  newName = '-'.join(attributes) + ".png"
  os.rename(base_dir + "/" + fileNames[n],
            base_dir + "/" + newName)
  

