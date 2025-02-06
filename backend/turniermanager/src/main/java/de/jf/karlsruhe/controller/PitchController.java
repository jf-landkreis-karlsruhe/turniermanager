package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.service.PitchService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/turniersetup")
public class PitchController {

	private final PitchService pitchService;

	@Autowired
	public PitchController(PitchService pitchService) {
		this.pitchService = pitchService;
	}

	// ERSTELLEN eines einzelnen Pitch
	@PostMapping("/pitch")
	public ResponseEntity<Pitch> createPitch(@RequestBody Pitch pitch) {
		Pitch savedPitch = pitchService.createPitch(pitch);
		return ResponseEntity.ok(savedPitch);
	}

	// ERSTELLEN mehrerer Pitches
	@PostMapping("/pitches")
	public ResponseEntity<List<Pitch>> createMultiplePitches(@RequestBody List<Pitch> pitches) {
		List<Pitch> savedPitches = pitchService.createMultiplePitches(pitches);
		return ResponseEntity.ok(savedPitches);
	}

	// LÖSCHEN eines Pitch nach ID
	@DeleteMapping("/pitch/{id}")
	public ResponseEntity<Void> deletePitch(@PathVariable Long id) {
		pitchService.deletePitch(id);
		return ResponseEntity.ok().build();
	}

	// LADEN aller Pitches
	@GetMapping("/pitches")
	public ResponseEntity<List<Pitch>> getAllPitches() {
		List<Pitch> pitches = pitchService.getAllPitches();
		return ResponseEntity.ok(pitches);
	}

	// LADEN eines einzelnen Pitch nach ID
	@GetMapping("/pitch/{id}")
	public ResponseEntity<Pitch> getPitchById(@PathVariable Long id) {
		Pitch pitch = pitchService.getPitchById(id);
		return ResponseEntity.ok(pitch);
	}
}