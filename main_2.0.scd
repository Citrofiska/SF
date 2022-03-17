s.plotTree;

// remember to run normal_startup.scd

////////////////////////// INITIAL SETTINGS ////////////////////////
~ip = "192.168.137.135"; // router_ip : "192.168.0.109"
~sample_path = "/Users/ljudskogen/Xu_Anna/samples/";
~phone_port = 8001;

~dmx = NetAddr.new("127.0.0.1", 9000);    // create the NetAddr
~arduino = NetAddr.new("127.0.0.1", 9001);    // create the NetAddr
~phone = NetAddr.new(~ip, ~phone_port);
// Reset colors to zero
~dmx.sendMsg("/string1/r", 0);
~dmx.sendMsg("/string1/g", 0);
~dmx.sendMsg("/string1/b", 0);
~dmx.sendMsg("/string1/w", 0);

///////////// OscController TO DMX /////////////////////////////////
OSCFunc({|msg|
	r = msg[1].linlin(0,1,0,255).asInt.postln;
	~dmx.sendMsg("/string1/r", r);
}, '/oscControl/slider1', recvPort:~phone_port);

OSCFunc({|msg|
	g = msg[1].linlin(0,1,0,255).asInt.postln;
	~dmx.sendMsg("/string1/g", g);
}, '/oscControl/slider2', recvPort:~phone_port);

OSCFunc({|msg|
	b = msg[1].linlin(0,1,0,255).asInt.postln;
	~dmx.sendMsg("/string1/b", b);
}, '/oscControl/slider3', recvPort:~phone_port);

OSCFunc({|msg|
	w = msg[1].linlin(0,1,0,255).asInt.postln;
	~dmx.sendMsg("/string1/w", w);
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
	// changed from 1--> 2 stereo
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, trig, start, loop);
	//// channel has to be fixed as integer.
	//// buf: the index of the buffer to use.
	//// rate: the sample rate(negative means reading backwards)
	//// trig, start: enable playing the file from a specific time
	//// loop: play the audio in loop
	//// doneAction: free the buffer when it ends. Will be ignored if loop=1
	sig = sig * amp;
	Out.ar(out,sig!2);
}).add;

//////////////////// onset settings /////////////////////////
OSCFunc({|msg|
	~onset = msg[3].value;
	if(~onset > 0.0, {
		~a0.free;
	    ~a1.free;
		~a2.free;
		~a3.free;
		~a4.free;
		~a5.free;
		~a6.free;
		~a7.free;
		~a8.free;
		~a9.free;
		~a10.free;
		~a11.free;
		~a12.free;
		~a13.free;
		~a14.free;
		~a15.free;
		~a16.free;
		~a17.free;
		~a18.free;
		~a19.free;
		~a20.free;
		~a21.free;
		~a22.free;
		~a23.free;
		~a24.free;
		~dmx.sendMsg("/string1/r", 0);
        ~dmx.sendMsg("/string1/g", 0);
        ~dmx.sendMsg("/string1/b", 0);
        ~dmx.sendMsg("/string1/w", 0);
	});
}, '/onset');

////////////// button to trigger audio samples ////////////////////////
OSCFunc({|msg|
	if(msg[1] == 1.0, {
		~a0.free;
	    ~a1.free;
		~a2.free;
		~a3.free;
		~a4.free;
		~a5.free;
		~a6.free;
		~a7.free;
		~a8.free;
		~a9.free;
		~a10.free;
		~a11.free;
		~a12.free;
		~a13.free;
		~a14.free;
		~a15.free;
		~a16.free;
		~a17.free;
		~a18.free;
		~a19.free;
		~a20.free;
		~a21.free;
		~a22.free;
		~a23.free;
		~a24.free;
	});
}, '/oscControl/freeAll', recvPort:~phone_port); //////////// freeAll

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a0 = Synth.new(\playbuf, [\buf,~audios[0].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a0.free;
	});
}, '/oscControl/default', recvPort:~phone_port); //////////// default

///////// button 1-24 ///
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


OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a11 = Synth.new(\playbuf, [\buf,~audios[11].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a11.free;
	});
}, '/oscControl/gridToggle11', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a12 = Synth.new(\playbuf, [\buf,~audios[12].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a12.free;
	});
}, '/oscControl/gridToggle12', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a13 = Synth.new(\playbuf, [\buf,~audios[13].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a13.free;
	});
}, '/oscControl/gridToggle13', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a14 = Synth.new(\playbuf, [\buf,~audios[14].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a14.free;
	});
}, '/oscControl/gridToggle14', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a15 = Synth.new(\playbuf, [\buf,~audios[15].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a15.free;
	});
}, '/oscControl/gridToggle15', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a16 = Synth.new(\playbuf, [\buf,~audios[16].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a16.free;
	});
}, '/oscControl/gridToggle16', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a17 = Synth.new(\playbuf, [\buf,~audios[17].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a17.free;
	});
}, '/oscControl/gridToggle17', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a18 = Synth.new(\playbuf, [\buf,~audios[18].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a18.free;
	});
}, '/oscControl/gridToggle18', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a19 = Synth.new(\playbuf, [\buf,~audios[19].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a19.free;
	});
}, '/oscControl/gridToggle19', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a20 = Synth.new(\playbuf, [\buf,~audios[20].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a20.free;
	});
}, '/oscControl/gridToggle20', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a21 = Synth.new(\playbuf, [\buf,~audios[21].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a21.free;
	});
}, '/oscControl/gridToggle21', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a22 = Synth.new(\playbuf, [\buf,~audios[22].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a22.free;
	});
}, '/oscControl/gridToggle22', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a23 = Synth.new(\playbuf, [\buf,~audios[23].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a23.free;
	});
}, '/oscControl/gridToggle23', recvPort:~phone_port);

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    ~a24 = Synth.new(\playbuf, [\buf,~audios[24].bufnum])
	});
	if(msg[1] == 0.0, {
	    ~a24.free;
	});
}, '/oscControl/gridToggle24', recvPort:~phone_port);\
