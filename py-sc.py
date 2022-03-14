import pyOSC3 as po3
import socket
import osc_decoder

receive_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
receive_socket.bind(("192.168.31.26", 8000)) # receive data on computer
client = po3.OSCClient()
client.connect(('127.0.0.1', 57120))  # send data to supercollider server
msg = po3.OSCMessage()
out_msg = po3.OSCMessage()
out_msg.setAddress("/print")
msg.setAddress("/print")  # send message via this path
while True:
        data = receive_socket.recv(1024)
        msg = osc_decoder.decode(data)
        print(msg)
        print(msg[0][2])
        # out_msg = po3.OSCMessage(msg[0][2])
        out_msg.append(msg[0][2])
        client.send(out_msg)


"""
Corresponding SC script:

s.boot;
(

~folder_path = "XXX";
~audios = Array.new;
~folder = PathName.new(~folder_path);

~folder.entries.do({
	arg path;
	~audios = ~audios.add(Buffer.read(s, path.fullPath));
});

SynthDef(\playbuf, {
	arg amp=1, out=0, buf, rate=0.5,  trig=0, start=0, loop=1, da=2;
	var sig;
	sig = PlayBuf.ar(1, buf, rate, trig, start, loop, doneAction:da);
	//// channel has to be fixed as integer.
	//// buf: the index of the buffer to use.
	//// rate: the sample rate(negative means reading backwards)
	//// trig, start: enable playing the file from a specific time
	//// loop: play the audio in loop
	//// doneAction: free the buffer when it ends. Will be ignored if loop=1
	sig = sig * amp;
	Out.ar(out,sig!2);
}).add;

y = Synth.new(\playbuf, [\buf,~audios[4].bufnum]);
)

(
OSCFunc( { | msg, time, addr, port |
    var pyFreq;

    pyFreq = msg[1].asFloat;
    ( "freq is " + pyFreq ).postln;
    y.set( \amp, pyFreq );
}, "/print" );
)
"""