import serial
import OSC

def set_dmx(channel, value):
    dmx_data[channel] = chr(value)
    
def send_dmx():
    ser.write(DMX_OPEN + DMX_INTENSITY + (''.join(dmx_data)) + DMX_CLOSE)

def osc_handler(addr, tags, data, client_address):
    offset = 0
    print(addr, data)
    if addr.endswith('g'):
        offset = 1
    elif addr.endswith('b'):
        offset = 2
    elif addr.endswith('w'):
        offset = 3

    try:    
        set_dmx(((int(addr[7]) - 1 ) * 6) + 1 + offset, data[0])
        send_dmx()
    except:
        print('badness', addr, tags, data, client_address)


sendindex = 0

DMX_OPEN = chr(126)
DMX_CLOSE = chr(231)
DMX_INTENSITY = chr(6) + chr(1) + chr(2)
DMX_INIT1 = chr(03) + chr(02) + chr(0) + chr(0) + chr(0)
DMX_INIT2 = chr(10) + chr(02) + chr(0) + chr(0) + chr(0)

ser = serial.Serial('/dev/tty.usbserial-ENYXTI9L')
ser.write(DMX_OPEN + DMX_INIT1 + DMX_CLOSE)
ser.write(DMX_OPEN + DMX_INIT2 + DMX_CLOSE)
dmx_data = [chr(0)] * 513
    
osc_server = OSC.OSCServer(('localhost', 9000))
#osc_server = OSC.ThreadingOSCServer(('localhost', 9999))
#osc_server = OSC.ForkingOSCServer(('localhost', 9999))
osc_server.addMsgHandler('default', osc_handler)
osc_server.serve_forever()

