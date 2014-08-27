stringOfAllTheCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ `.,;:'+"'"+'"?!0123456789'
stringsToGlyphs = {}

zeroPadder = (number,zerosToFill) ->
  numberAsString = number+''
  while numberAsString.length < zerosToFill
    numberAsString = '0'+numberAsString
  return numberAsString

stringIndex = 0
while stringIndex < stringOfAllTheCharacters.length
  stringsToGlyphs[stringOfAllTheCharacters[stringIndex]] = new Image()
  stringsToGlyphs[stringOfAllTheCharacters[stringIndex]].src = 'w'+zeroPadder(stringIndex,4)+'.PNG'
  stringIndex++



demoSineParameters = amplitude:1, duration:44100, tone:800



