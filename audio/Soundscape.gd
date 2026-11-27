extends RefCounted

const RATE := 22050

static func ambient() -> AudioStreamWAV:
	# Integer cycles over eight seconds keep the loop seamless.
	var frames := RATE * 8
	var pcm := PackedByteArray()
	pcm.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / RATE
		var swell := 0.65 + 0.35 * cos(TAU * t / 8.0)
		var wave := sin(TAU * 55.0 * t) * 0.055
		wave += sin(TAU * 82.5 * t) * 0.035
		wave += sin(TAU * 110.0 * t) * 0.025 * swell
		wave += sin(TAU * 165.0 * t) * 0.012 * (1.0 - swell * 0.5)
		wave += sin(TAU * 220.0 * t) * 0.008 * (0.5 + 0.5 * sin(TAU * t / 4.0))
		pcm.encode_s16(i * 2, int(clampf(wave, -1.0, 1.0) * 32767.0))
	var stream := make_stream(pcm)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frames
	return stream

static func chime(notes: Array, note_length: float, spacing: float, gain: float = 0.28) -> AudioStreamWAV:
	var frames := int((note_length + spacing * (notes.size() - 1)) * RATE)
	var pcm := PackedByteArray()
	pcm.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / RATE
		var wave := 0.0
		for n in range(notes.size()):
			var local_t := t - float(n) * spacing
			if local_t < 0.0 or local_t >= note_length:
				continue
			var envelope := minf(local_t / 0.012, 1.0) * pow(1.0 - local_t / note_length, 2.0)
			var hz: float = float(notes[n])
			wave += (sin(TAU * hz * local_t) + 0.16 * sin(TAU * hz * 2.0 * local_t)) * envelope * gain
		pcm.encode_s16(i * 2, int(clampf(wave, -1.0, 1.0) * 32767.0))
	return make_stream(pcm)

static func make_stream(pcm: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = pcm
	return stream
