////////////////////////// INITIAL SETTINGS ////////////////////////
s.boot;
s.plotTree;

~ip = "192.168.0.108"; //"192.168.0.109"
~sample_path = "/Users/ljudskogen/Xu_Anna/samples/";



~phone_port = 8001;

~dmx = NetAddr.new("127.0.0.1", 9000);    // create the NetAddr
~phone = NetAddr.new(~ip, ~phone_port);
// Reset colors to zero
~dmx.sendMsg("/string1/r", 0);
~dmx.sendMsg("/string1/g", 0);
~dmx.sendMsg("/string1/b", 0);
~dmx.sendMsg("/string1/w", 0);

/// OSCFunc.trace(false)



OSCFunc({|msg| ~onset = msg[3].value; ~onset.postln;}, '/onset'); //onsets


///////////// OscController TO DMX /////////////////////////////////
OSCFunc({|msg|
	///x = msg[1].linlin(0,1,0,255).asInt.postln;
	~dmx.sendMsg("/string1/r", msg[1].linlin(0,1,0,255).asInt);
}, '/oscControl/slider1', recvPort:~phone_port);

OSCFunc({|msg|
	~dmx.sendMsg("/string1/g", msg[1].linlin(0,1,0,255).asInt).postln;
}, '/oscControl/slider2', rcvPort:~phone_port);

OSCFunc({|msg|
	~dmx.sendMsg("/string1/b", msg[1].linlin(0,1,0,255).asInt).postln;
}, '/oscControl/slider3', recvPort:~phone_port);

OSCFunc({|msg|
	~dmx.sendMsg("/string1/w", msg[1].linlin(0,1,0,255).asInt).postln;
}, '/oscControl/slider4', recvPort:~phone_port);

////////////////// read audio files from a folder ////////////////////
~audios = Array.new;
~folder = PathName.new(~sample_path);
~folder.entries.do({
	arg path;
	~audios = ~audios.add(Buffer.read(s, path.fullPath));
});

SynthDef(\playbuf, {
	arg amp=1, out=1, buf, rate=1,  trig=0, start=0, loop=1, da=2;
	var sig;
	sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, trig, start, loop, doneAction:da);
	//// channel has to be fixed as integer.
	//// buf: the index of the buffer to use.
	//// rate: the sample rate(negative means reading backwards)
	//// trig, start: enable playing the file from a specific time
	//// loop: play the audio in loop
	//// doneAction: free the buffer when it ends. Will be ignored if loop=1
	sig = sig * amp;
	Out.ar(out,sig!2);
}).add;
////////////// button to trigger audio samples ////////////////////////
OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a0 = Synth.new(\playbuf, [\buf,~audios[0].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a0.free;
	});
}, '/oscControl/default', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    s.freeAll
	});
}, '/oscControl/freeAll', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a1 = Synth.new(\playbuf, [\buf,~audios[1].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a1.free;
	});
}, '/oscControl/gridToggle1', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a2 = Synth.new(\playbuf, [\buf,~audios[2].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a2.free;
	});
}, '/oscControl/gridToggle2', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a3 = Synth.new(\playbuf, [\buf,~audios[3].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a3.free;
	});
}, '/oscControl/gridToggle3', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a4 = Synth.new(\playbuf, [\buf,~audios[4].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a4.free;
	});
}, '/oscControl/gridToggle4', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a5 = Synth.new(\playbuf, [\buf,~audios[5].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a5.free;
	});
}, '/oscControl/gridToggle5', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a6 = Synth.new(\playbuf, [\buf,~audios[6].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a6.free;
	});
}, '/oscControl/gridToggle6', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a7 = Synth.new(\playbuf, [\buf,~audios[7].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a7.free;
	});
}, '/oscControl/gridToggle7', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a8 = Synth.new(\playbuf, [\buf,~audios[8].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a8.free;
	});
}, '/oscControl/gridToggle8', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a9 = Synth.new(\playbuf, [\buf,~audios[9].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a9.free;
	});
}, '/oscControl/gridToggle9', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a10 = Synth.new(\playbuf, [\buf,~audios[10].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a10.free;
	});
}, '/oscControl/gridToggle10', recvPort:~phone_port);

