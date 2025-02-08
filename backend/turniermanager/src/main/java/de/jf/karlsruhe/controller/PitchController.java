package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.repos.PitchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/turniersetup/pitches")
@RequiredArgsConstructor
public class PitchController {

    private final PitchRepository pitchRepository;

    // Create a new Pitch
    @PostMapping
    public ResponseEntity<Pitch> createPitch(@RequestBody Pitch pitch) {
        Pitch savedPitch = pitchRepository.save(pitch);
        return ResponseEntity.ok(savedPitch);
    }

    // Read/Get a Pitch by ID
    @GetMapping("/{id}")
    public ResponseEntity<Pitch> getPitchById(@PathVariable UUID id) {
        Optional<Pitch> optionalPitch = pitchRepository.findById(id);
        return optionalPitch.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Read/Get all Pitches
    @GetMapping
    public ResponseEntity<List<Pitch>> getAllPitches() {
        List<Pitch> pitches = pitchRepository.findAll();
        return ResponseEntity.ok(pitches);
    }

    // Update a Pitch
    @PutMapping("/{id}")
    public ResponseEntity<Pitch> updatePitch(@PathVariable UUID id, @RequestBody Pitch pitchDetails) {
        Optional<Pitch> optionalPitch = pitchRepository.findById(id);

        if (optionalPitch.isPresent()) {
            Pitch existingPitch = optionalPitch.get();
            existingPitch.setName(pitchDetails.getName());
            existingPitch.setAgeGroups(pitchDetails.getAgeGroups());
            Pitch updatedPitch = pitchRepository.save(existingPitch);
            return ResponseEntity.ok(updatedPitch);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete a Pitch
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePitch(@PathVariable UUID id) {
        if (pitchRepository.existsById(id)) {
            pitchRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Bulk Insert Multiple Pitches
    @PostMapping("/bulk")
    public ResponseEntity<List<Pitch>> createMultiplePitches(@RequestBody List<Pitch> pitches) {
        List<Pitch> savedPitches = pitchRepository.saveAll(pitches);
        return ResponseEntity.ok(savedPitches);
    }
}