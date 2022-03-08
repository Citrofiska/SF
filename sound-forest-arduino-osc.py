import serial
import OSC
import sys

port = serial.Serial(sys.argv[1], 115200)
client = OSC.OSCClient()
client.connect(('localhost', 9001))
addr = '/string' + sys.argv[2] + '/distance'


while True:
    line = port.readline()
    try:
        message = OSC.OSCMessage()
        message.setAddress(addr)
        message.append(int(line))
        client.send(message)
    except:
        print('No one is listening...')
        #sys.exit()