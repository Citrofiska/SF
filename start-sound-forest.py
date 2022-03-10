import os
import time
import sys
import socket

serial_ports = ['142410'] # EXPAND LIST OF ARDUINO SERIAL PORT ADDRESSES I.E. ['14241', '41321', '12321']
serial_base = '/dev/tty.usbmodem'



# s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
# s.bind(("130.237.2.112", 8001))
# s.setblocking(False)
# s.close()



print('Starting Sound Forest Installation')


# try:    	
# 	data, adr = s.recvfrom(2048)
# 	print(data, data)
# except socket.error:
# 	print(socket.error)
# else:
# 	print("got message")

os.system('python sound-forest-osc-dmx.py &')

for i, addr in enumerate(serial_ports):
    os.system('python sound-forest-arduino-osc.py ' + serial_base + addr + ' ' + str(i) + ' &')

os.system('open /Applications/SuperCollider/SuperCollider.app &')
