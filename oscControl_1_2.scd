////////////////////////// ONSETS DETECTION ////////////////////////
s.boot;
s.plotTree;

// remember to run normal_startup.scd

////////////////////////// INITIAL SETTINGS ////////////////////////

~ip = "192.168.0.109"; //"192.168.0.109"
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

/// OSCFunc.trace(false)

///onset or onsets?
OSCFunc({|msg| ~onset = msg[3].value.postln; ~onset;}, '/onset'); //onset

//arduino sensor data
~ping = 0;
OSCFunc({|msg| ~ping = msg[1].value; }, '/string0/distance', recvPort:9001);

//
// // contact mic data
// ~onset = 0;
//OSCFunc({|msg| ~onset = msg[3].value.postln;}, '/onsets'); //onsets
//

//
// Task({
// 	inf.do({
// 		if(~onset > 0, {
// 			~onset.postln;
// 			/*
//
// 			*/
//
// 		});
// 		0.01.wait;
// 	});
// }).start;


///////////// OscController TO DMX /////////////////////////////////
OSCFunc({|msg|
	r = msg[1].linlin(0,1,0,255).asInt.postln;
	~dmx.sendMsg("/string1/r", r);
}, '/oscControl/slider1', recvPort:~phone_port);

OSCFunc({|msg|
	g = msg[1].linlin(0,1,0,255).asInt;
	~dmx.sendMsg("/string1/g", g);
}, '/oscControl/slider2', recvPort:~phone_port);

OSCFunc({|msg|
	b = msg[1].linlin(0,1,0,255).asInt;
	~dmx.sendMsg("/string1/b", b);
}, '/oscControl/slider3', recvPort:~phone_port);

OSCFunc({|msg|

	~dmx.sendMsg("/string1/w", msg[1].linlin(0,1,0,255).asInt);
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




////////////// button to trigger audio samples ////////////////////////

OSCFunc({|msg|
	if(msg[1] == 1.0, {
	    s.freeAll
	});
}, '/oscControl/freeAll', recvPort:~phone_port);


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



///////////////

~ip = "192.168.0.3"; //"192.168.0.109"
//~sample_path = "/Users/ljudskogen/Xu_Anna/samples/";
~phone_port = 8001;
~phone = NetAddr.new(~ip, ~phone_port);
///////////////////////// THIS WOULD HOPEFULLY REPLACE THE HARDCODED STUFF

~sample_path = "/Users/annaanna/KTH/Sound_DT2300/project/samples/DONE/";
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


~nbrToggles = 4;
~synths = Array.fill(~nbrToggles, {arg i; ('/oscControl/gridToggle'++i).postln});
~actives = Array.fill(~nbrToggles, {arg i; 1 }).postln;

 i= 1;
OSCFunc({|msg|
	x = msg[1].postln;
	//~actives[i]
	if(x == 1.0 && ~actives[i] == 1, {
~synths[i] = Synth.new(\playbuf, [\buf,~audios[i].bufnum]).postln;
		~actives[i] == 0;
});
if(msg[1] == 0.0, {
		~synths[i].free;
		~actives[i] == 1;
});
}, '/oscControl/gridToggle'++i, recvPort:~phone_port);


//while
~nbrToggles = 14;
OSCFunc({|msg|
	if(~onset > 0, {	(
i = 0;
while ( { i < ~nbrToggles }, { i = i + 1; '~a'++i.free });
)})}, '/onset');


// for
~nbrToggles = 14;
OSCFunc({|msg|
	if(~onset > 0, {	(
for (0, ~nbrToggles-1, { arg i; '~a'++i.free.postln });
)}
)}, '/onset');













