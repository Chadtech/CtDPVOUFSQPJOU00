fs = require('fs')
http = require('http')
url = require('url')

server = http.createServer((request, response)->
  console.log 'connection'
  console.log 'Path Name', url.parse(request.url).pathname
  response.writeHead(200, {'Content-Type': 'text/html'})
  response.write('hello world')
  response.end())

server.listen(8001)



buildFile = (fileName, channels) ->
  manipulatedChannels = channels
  sameLength = true
  
  # The channels all have to be the same lenth, check to see if thats the case before proceeding
  unalteredChannel = 0

  while unalteredChannel < manipulatedChannels.length
    relativeChannel = 0

    while relativeChannel < (manipulatedChannels.length - channel)
      sameLength = false  if manipulatedChannels[channel].length isnt manipulatedChannels[relativeChannel + channel].length
      relativeChannel++
    unalteredChannel++
  unless sameLength
    longestChannelsLength = 0
    
    # If the channels are not all the same length, establish what the longest channel is
    channel = 0

    while channel < manipulatedChannels.length
      longestChannelsLength = manipulatedChannels[channel].length  if manipulatedChannels[channel].length > longestChannelsLength
      channel++
    
    # Add a duration of "silence" to each channel in the amount necessary to bring it to the length of the longest channel 
    channel = 0

    while channel < manipulatedChannels.length
      
      # The internet told me to do this, but it looks so messy:     manipulatedChannels[channel].concat(Array(manipulatedChannels[channel].length-longestChannelsLength).join('0').split('').map(parseFloat));
      sampleDif = 0

      while sampleDif < (longestChannelsLength - manipulatedChannels[channel].length)
        manipulatedChannels[channel].push 0
        channel++
      channel++
  
  # Make an Array, so that the audio samples can be aggregated in the standard way wave files are (For each sample i in channels a, b, and c, the sample order goes a(i),b(i),c(i),a(i+1),b(i+1),c(i+1), ... )
  channelAudio = []
  sample = 0

  while sample < manipulatedChannels[0].length
    channel = 0

    while channel < manipulatedChannels.length
      valueToAdd = 0
      if manipulatedChannels[channel][sample] < 0
        valueToAdd = manipulatedChannels[channel][sample] + 65536
      else
        valueToAdd = manipulatedChannels[channel][sample]
      channelAudio.push(valueToAdd) % 256
      channelAudio.push Math.floor(valueToAdd / 256)
      channel++
    sample++
  
  # Make an array containing all the header information, like sample rate, the size of the file, the samples themselves etc
  header = []
  header = header.concat([ # 'RIFF' in decimal
    82
    73
    70
    70
  ])
  thisWavFileSize = (manipulatedChannels[0].length * 2 * manipulatedChannels.length) + 36
  wavFileSizeZE = thisWavFileSize % 256
  wavFileSizeON = Math.floor(thisWavFileSize / 256) % 256
  wavFileSizeTW = Math.floor(thisWavFileSize / 65536) % 256
  wavFileSizeTH = Math.floor(thisWavFileSize / 16777216) % 256
  header = header.concat([ # This is the size of the file
    wavFileSizeZE
    wavFileSizeON
    wavFileSizeTW
    wavFileSizeTH
  ])
  header = header.concat([ # 'WAVE' in decimal
    87
    65
    86
    69
  ])
  header = header.concat([ # 'fmt[SQUARE]' in decimal
    102
    109
    116
    32
  ])
  header = header.concat([ # The size of the subchunk after this chunk of data
    16
    0
    0
    0
  ])
  header = header.concat([ # The second half of this datum is the number of channels
    1
    0
    manipulatedChannels.length % 256
    Math.floor(manipulatedChannels / 256)
  ])
  # The maximum number of channels is 65535
  header = header.concat([ # Sample Rate 44100.
    44100 % 256
    Math.floor(44100 / 256)
    0
    0
  ])
  byteRate = 44100 * manipulatedChannels.length * 2
  byteRateZE = byteRate % 256
  byteRateON = Math.floor(byteRate / 256) % 256
  byteRateTW = Math.floor(byteRate / 65536) % 256
  byteRateTH = Math.floor(byteRate / 16777216) % 256
  header = header.concat([
    byteRateZE
    byteRateON
    byteRateTW
    byteRateTH
  ])
  header = header.concat([ # The first half is the block align (2*number of channels), the second half is te bits per sample (16)
    manipulatedChannels.length * 2
    0
    16
    0
  ])
  header = header.concat([ # 'data' in decimal
    100
    97
    116
    97
  ])
  sampleDataSize = manipulatedChannels.length * manipulatedChannels[0].length * 2
  sampleDataSizeZE = sampleDataSize % 256
  sampleDataSizeON = Math.floor(sampleDataSize / 256) % 256
  sampleDataSizeTW = Math.floor(sampleDataSize / 65536) % 256
  sampleDataSizeTH = Math.floor(sampleDataSize / 16777216) % 256
  header = header.concat([
    sampleDataSizeZE
    sampleDataSizeON
    sampleDataSizeTW
    sampleDataSizeTH
  ])
  outputArray = header.concat(channelAudio)
  outputFile = new Buffer(outputArray)
  fs.writeFile fileName, outputFile

makeSine = (voiceParameters) ->
  amplitude = voiceParameters.amplitude * 32767 or 32767
  tone = voiceParameters.tone/44100
  outRay = []
  sample = 0
  while sample < voiceParameters.duration
    outRay.push amplitude * Math.sin(Math.PI * 2 * sample * tone)
    sample++
  return outRay