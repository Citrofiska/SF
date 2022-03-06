s.boot;
s.plotTree;

/////// first argument: ip address of that app
/////// second argument: port that app is listening on
/////// If don't send data to that app, the following is not needed
(
~computer = NetAddr.new("192.168.31.26", 57120);
~ipad = NetAddr.new("192.168.31.55", 8000) ;
~phone = NetAddr.new("192.168.31.166", 8001) ;
)

thisProcess.openUDPPort(9000); // Open a new UDP port for a second device. will return true or false.
thisProcess.openPorts; // returns all open ports (Default port is 57120)

///////////////////////////////////// An example of synth ////////////////////////////////////////////////
(
SynthDef("bubbles", { |out|
	arg para1=40,para2=4,para3=7;
    var f, sound;
    f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([para3, 7.23], 0, 3, para1)).midicps; // glissando function
    sound = CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, para2); // echoing sine wave
    Out.ar(out, sound);
}).add;
)

///////////////////// read audio files from a folder /////////////////////////////////
(

~folder_path = "D:/Audio/genres_original/jazz/";
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

////x = Synth.new(\playbuf, [\buf,~audios[0].bufnum]);
y = Synth.new(\playbuf, [\buf,~audios[4].bufnum]);
)

////////////////////////////// receive osc /////////////////////////////

////// On ipad/phone, first match the computer's IP address and port to send data
(
OSCdef(\ipad, {|msg|
	///////msg.postln;
	y.set(\rate, msg[1]);
},'/syntien/try/1/slider1',  ///////// osc path of the incoming data
recvPort:57120).enable;  ///// listen to ipad through port 57120
)

(
OSCdef(\phone, {|msg|
	///////msg.postln;
	y.set(\amp, msg[1]);
},'/oscControl/slider1',  ///////// osc path of the incoming data
recvPort:9000).enable;  ///// listen to phone through port 9000
)

//////////////// record sounds ////////////////////

s.recHeaderFormat = "wav";  // to save wav format recordings
s.record;
s.stopRecording;
Platform.recordingsDir; // get the recording directory

/////////////// stop the OSC receiver /////////////////
OSCdef(\ipad).disable;
OSCdef(\phone).disable;

