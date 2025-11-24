import AVFoundation
import Numerics
import SPFKBase
@testable import SPFKLoudness
import SPFKLoudnessC
import SPFKTesting
import Testing

@Suite(.tags(.file))
final class LoudnessTests: BinTestCase {
    @Test func testMeasureLoudness() async throws {
        let url = TestBundleResources.shared.tabla_wav

        let loudness = try await Loudness.analyze(url: url)

        let range = try #require(loudness.loudnessRange)

        #expect(loudness.lufs == -24.1)
        #expect(range == 1.4275153988048004)
        #expect(loudness.truePeak == -0.1)
    }

    @Test func testLoopAudio() async throws {
        let url = TestBundleResources.shared.cowbell_wav
        let audioFile1 = try AVAudioFile(forReading: url)

        // original file duration
        #expect(audioFile1.duration == 2.0000226757369615)

        let output = bin.appendingPathComponent("cowbell_20.wav", conformingTo: .wav)

        // loop it for 20 seconds
        let tmpfile = try await AudioTools.createLoopedAudio(input: url, output: output, minimumDuration: 20)

        let audioFile2 = try AVAudioFile(forReading: tmpfile)

        #expect(audioFile2.duration.isApproximatelyEqual(to: 20, absoluteTolerance: 0.001))
    }

    @Test func testMeasureLoudnessShortFile() async throws {
        let url = TestBundleResources.shared.cowbell_wav

        let loudness = try await Loudness.analyze(url: url)

        #expect(loudness.lufs == -29.5)
    }

    @Test func testAverageLoudness() async throws {
        let targetLevel: Double = -23

        let urls = [TestBundleResources.shared.mp3_id3, TestBundleResources.shared.tabla_wav, TestBundleResources.shared.cowbell_wav]

        var values = [LoudnessDescription]()

        for url in urls {
            guard let value = try? await Loudness.analyze(url: url) else { continue }

            values.append(value)

            Log.debug("Change to target is", targetLevel - (value.lufs ?? 0))
        }

        let lufs = try #require(LoudnessDescription.averageLoudness(from: values).lufs)

        Log.debug("🔊 values:", values)
        Log.debug("🔊 average:", lufs)

        #expect(
            lufs.isApproximatelyEqual(to: -25.26, relativeTolerance: 0.001)
        )
    }
}
