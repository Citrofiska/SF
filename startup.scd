var gui, loopBack;

gui = Dictionary.new;
loopBack = NetAddr.new("127.0.0.1", 9999);

(
Server.local.options.numOutputBusChannels = 4;
// channels [0, 1] are the floor actuators
// channel [2] is the ceiling speaker
);
////////////////////////// THE CONNECTIONS //////////////////////////////////
(
~dmx = NetAddr.new("127.0.0.1", 9000);    // create the NetAddr
~arduino = NetAddr.new("127.0.0.1", 9001);    // create the NetAddr
// Reset colors to zero
~dmx.sendMsg("/string1/r", 0);
~dmx.sendMsg("/string1/g", 0);
~dmx.sendMsg("/string1/b", 0);
~dmx.sendMsg("/string1/w", 0);
);


Server.default.waitForBoot({
	(
~drone = Buffer.read(s, "/Users/ljudskogen/Desktop/sound-forest-DEMO/cp_drone.wav");
~busenv = Bus.audio(s, 1);
SynthDef(\impulse, {arg freq = 5000, rel = 0.01, level = 1;
	var
	imp = LFPulse.ar(5000),
	env = EnvGen.kr(Env.perc(0, rel), 1, level, doneAction:2);

	Out.ar(~busenv, imp*env)
}).send(s);
//
SynthDef(\internal_fb, {arg fb = 1.07, lag = 0.5, windowsize, wipe = 0.1, freq, r_inf, r_sup, mul = 1, spread = 1, center = 0;
	var in, feedback, out, output1, chain, out2, rms, control, envfol_in, pan;
	feedback = LocalIn.ar(1)*fb;
	in = In.ar(~busenv, 1);
	out = LeakDC.ar(feedback + in);
	output1 = BPF.ar(out, LFNoise2.ar(freq).range(r_inf, r_sup), 0.9, 1);
	chain = FFT(LocalBuf(windowsize, 1), output1);
	chain = PV_BinScramble(chain, wipe, 1);
	output1 = IFFT(chain);
	LocalOut.ar(output1);
	out2 = FreeVerb.ar(output1);
	rms = RunningSum.rms(Amplitude.ar(out2)).clip(0, 1);
	control = 1-(rms.lag2(lag));
	envfol_in = Lag3.ar(rms, lag);
	//pan = Pan2.ar(output1, LFNoise1.ar(1).range(-1, 1), control*mul);
	pan = output1*control*mul;

	Out.ar(2, pan); //output only on the ceiling speaker
}).send(s);
//
//
SynthDef(\bass, {arg rel = 1, level = 1;
	var
	noise = LPF.ar(BrownNoise.ar, 20),
	env = EnvGen.kr(Env.perc(0, rel), 1, level, doneAction:2);

	Out.ar([0, 1], noise*env); //output only on the floor
}).send(s);
//
//
SynthDef(\play, {
	arg red_start = 0, max = 0.2, delay = 0.2, decay = 1, pitchRatio = 1, freq_filter = 20, pos = 0, level = 1;
	var
	play = PlayBuf.ar(2, ~drone.bufnum, 1, loop:1),
	pitch_white = Lag.kr(delay, 0.5),
	comb = CombC.ar(play, max, delay, decay),
	shift = PitchShift.ar(comb, 0.3, pitchRatio),
	blue = (LFNoise1.kr(1.7).linlin(0, 1, 50, 120)),
	green = (LFNoise1.kr(1.3).linlin(0, 1, 50, 120)),
	red = (red_start - Sweep.kr(Changed.kr(red_start), 50)).clip(0, 255),
	panning = Pan2.ar(FreeVerb.ar(comb, 0.6, 1), pos, Lag.kr(level, 0.2));

	SendReply.kr(Impulse.kr(60), '/white', red);
	SendReply.kr(Impulse.kr(60), '/red', red);
	SendReply.kr(Impulse.kr(60), '/blue', blue);
	SendReply.kr(Impulse.kr(60), '/green', green);

	Out.ar(0, panning);  //output only on the floor
}).send(s)
);
	SynthDef.new(\analysis, {
		arg threshold = 0.01, relaxTime = 0.1;  //threshold = 0.35, relaxTime = 5.0;
		var buffer, input, chain,
		onsets, amplitude, frequency, hasFrequency, spectralFlatness, spectralCentroid;

		buffer = LocalBuf.new(1024, 1);
		input = SoundIn.ar([0]);

		amplitude = (Amplitude.ar(input, 0.001, 0.5) ).clip(0, 1);
		chain = FFT(buffer, input);
		onsets = Onsets.kr(chain, threshold, 'complex', relaxTime);
		#frequency, hasFrequency = Pitch.kr(input, 440, 10, 10000);

		chain = FFT(buffer, input);
		spectralFlatness = SpecFlatness.kr(chain);

		chain = FFT(buffer, input);
		spectralCentroid = SpecCentroid.kr(chain);

		SendReply.kr(onsets, '/onset', amplitude);
		SendReply.kr(Impulse.kr(100), '/onsets', onsets); //<<<--------
		SendReply.kr(
			Impulse.kr(60),
			'/dataStream',
			[
				amplitude,
				spectralFlatness,
				spectralCentroid,
				hasFrequency,
				frequency
			]
		);

		//Out.ar(0, ((EnvGen.ar(Env.perc(0, 0.1), onsets) * 0.2 * SinOsc.ar(800)))! 2);
	}).add;

	Server.default.sync;

	Synth.new(\analysis);

////////////////////////// THE DEMO //////////////////////////////////
(
~play = Synth(\play, [\level, 0.2]);
f = Synth(\internal_fb, [\fb, 0.9, \windowsize, 4096, \freq, 1, \r_inf, 100, \r_sup, 600, \mul, 3]);
//
//
OSCFunc({|msg| ~dmx.sendMsg("/string1/r", (msg[3].value).asInt); }, '/red');
OSCFunc({|msg| ~dmx.sendMsg("/string1/w", (msg[3].value).asInt); }, '/white');
OSCFunc({|msg| ~dmx.sendMsg("/string1/b", (msg[3].value).asInt); }, '/blue');
OSCFunc({|msg| ~dmx.sendMsg("/string1/g", (msg[3].value).asInt); }, '/green');
//
//
~ping = 0;
OSCFunc({|msg| ~ping = msg[1].value; }, '/string0/distance', recvPort:9001);
//
//
~onset = 0;
OSCFunc({|msg| ~onset = msg[3].value;}, '/onsets'); //onsets
//
//
Task({
	inf.do({
		if(~onset > 0, {
			~onset.postln;
			("Sensor value:"++~ping).postln;
			if(~ping > 75, {
				~play.set(\delay, rrand(0.2, 0.5), \red_start, 255 + rrand(0, 0.4)); //escamotage in order to reset the trig
				Synth(\bass, [\rel, 2.5, \level, 1.8]);
				f.set(\r_inf, 500, \r_sup, 1000);
				Synth(\impulse);
			});
			if((~ping > 40) && (~ping <= 75), {
				~play.set(\delay, rrand(0.1, 0.2), \red_start, 160 + rrand(0, 0.4));
				Synth(\bass, [\rel, 2.5, \level, 1.8]);
				f.set(\r_inf, 1000, \r_sup, 5000);
				Synth(\impulse);

			});
			if((~ping > 0) && (~ping <= 40), {
				~play.set(\delay, rrand(0.04, 0.1), \red_start, 80 + rrand(0, 0.4));
				Synth(\bass, [\rel, 2.5, \level, 1.8]);
				f.set(\r_inf, 5000, \r_sup, 1e4);
				Synth(\impulse);

			});
		});
		0.01.wait;
	});
}).start;
//
//
);



});

// GUI
{
	var window;
	window = Window.new("CONTACT MIC ANALYSIS").front;
	window.background = Color.new(0.15, 0.16, 0.16);

	gui[\onsetButton] = Button.new;
	gui[\onsetButton].states = [["", Color.black, Color.black], ["", Color.black, Color.new(1.0, 0.2, 0.2)]];
	gui[\onsetButton].canFocus = false;

	gui[\analysisSliders] = 9.collect({|i|
		var slider;
		slider = Slider.new;
		slider.orientation = \horizontal;
		slider.thumbSize = 1;
		slider.knobColor = Color.white;
		slider.background = Color.black;
		slider.fixedHeight = 20;
		slider;
	});

	gui[\analysisStaticTexts] = 9.collect({|i|
		var staticText;
		staticText = StaticText.new;
		staticText.string = "-";
		staticText.fixedWidth = 120;
		staticText.stringColor = Color.new(0.9, 0.9, 0.9);
		staticText.font = Font.new("Helvetica Neue", 12);
		staticText;
	});

	window.layout =
	VLayout.new(
		gui[\onsetButton],
		VLayout.new(
			*6.collect({|i|
				var view, label;
				view = View.new;
				label = StaticText.new;
				label.string = [
					"Amplitude",
					"Spectral Flatness",
					"Spectral Centroid",
					"Has Frequency",
					"Frequency",
					"MIDI Note Nr"
				][i];
				label.stringColor = Color.new(0.5, 0.5, 0.5);
				label.fixedWidth = 120;
				label.font = Font.new("Helvetica Neue", 12);

				view.layout = HLayout.new(label, gui[\analysisStaticTexts][i], gui[\analysisSliders][i]);
				view.layout.margins = 0;
				view;
			})
		)
	);
}.();

// OSC IO
{
	var loopBack;

	loopBack = NetAddr.new("127.0.0.1", 9001);
	// loopBack = NetAddr.new("127.0.0.1", 9999);

	OSCdef.new(\onset, {
		arg msg, time, addr, recvPort;

		[ msg[3], msg[3].ampdb].postln;
		loopBack.sendMsg("/string1/onset", msg[3], msg[3].ampdb);

		defer {
			gui[\onsetButton].value = 1;
			fork {
				0.1.yield;
				defer {
					gui[\onsetButton].value = 0;
				}
			}
		};

	}, '/onset');

	OSCdef.new(\dataStream, {
		arg msg, time, addr, recvPort;

		loopBack.sendMsg("/dataStream1", msg[3], msg[4], msg[5], msg[6], msg[7], msg[7].cpsmidi);

		defer {
			gui[\analysisSliders][0].value = msg[3];
			gui[\analysisSliders][1].value = msg[4];
			gui[\analysisSliders][2].value = msg[5] / 22000.0;
			gui[\analysisSliders][3].value = msg[6];
			gui[\analysisSliders][4].value = msg[7] / 22000.0;
			gui[\analysisSliders][5].value = msg[7].cpsmidi / 127.0;

			gui[\analysisStaticTexts][0].string = "" + msg[3].round(0.01);
			gui[\analysisStaticTexts][1].string = "" + msg[4].round(0.01);
			gui[\analysisStaticTexts][2].string = "" + msg[5].round(0.1);
			gui[\analysisStaticTexts][3].string = "" + msg[6].round(0.01);
			gui[\analysisStaticTexts][4].string = "" + msg[7].round(0.1);
			gui[\analysisStaticTexts][5].string = "" + msg[7].cpsmidi.round(0.01);
		}
	}, '/dataStream');

}.();
