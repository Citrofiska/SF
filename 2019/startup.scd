(
var gui, loopBack;

gui = Dictionary.new;
loopBack = NetAddr.new("127.0.0.1", 9999);

Server.default.waitForBoot({
	SynthDef.new(\analysis, {
		arg threshold = 0.35, relaxTime = 5.0;
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
					"Spectral Centorid",
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
)