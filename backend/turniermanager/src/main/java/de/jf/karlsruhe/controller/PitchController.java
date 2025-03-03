package de.jf.karlsruhe.controller;

import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfWriter;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.repos.PitchRepository;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.awt.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
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

    @ResponseBody
    @GetMapping(value = {"/result-card/{id}"}, produces = {"application/pdf"})
    public ByteArrayOutputStream getResultCards(@PathVariable UUID id, HttpServletResponse response ) {
        response.addHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment;filename=spielfeld" + id +".pdf");
        List<Game> games = List.of(
            new Game("Langensteinbach 1", "Langensteinbach 2", 1, 1),
            new Game("Ettlingen", "Karlsruhe", 2, 2)
        );
        return createPdf(games);
    }

    private ByteArrayOutputStream createPdf(List<Game> games) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            // PDF-Dokument und Writer erstellen
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setCloseStream(false);
            document.open();


            // Überschrift: Spielfeld & Spielnummer
            Font font = new Font(
                    BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, BaseFont.NOT_EMBEDDED),
                    20F,
                    Font.BOLD,
                    Color.BLACK
            );

            for (Game game : games) {

                Paragraph header = new Paragraph("Platz: " + game.fieldNumber + "    Spiel: " + game.matchNumber, font);
                header.setAlignment(Element.ALIGN_CENTER);
                document.add(header);

                // Abstand
                document.add(new Paragraph("\n"));

                // Tabelle für Mannschaftsnamen
                Table table = new Table(2); // 2 Spalten
                table.setWidth(100);

                // Mannschaftsnamen hinzufügen
                table.addCell(createCell(game.team1));
                table.addCell(createCell(game.team2));
                table.addCell(createCell(game.team2));
                table.addCell(createCell(game.team1));

                document.add(table);

                // Abstand
                document.add(new Paragraph("\n"));

                // Endergebnis-Bereich
                document.add(new Paragraph("Endergebnis:", font));
                document.add(new Paragraph(game.team1 + ": ________________"));
                document.add(new Paragraph(game.team2 + ": ________________"));

                document.newPage();
            }

            // PDF-Dokument schließen
            document.close();
            return out;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    // Hilfsfunktion: Tabellenzelle erstellen (ohne Rahmen, zentriert)
    private static Cell createCell(String text) {
        Paragraph paragraph = new Paragraph(text);
        paragraph.setAlignment(Element.ALIGN_CENTER);

        Cell cell = new Cell(paragraph);
        cell.setBorder(0);
        return cell;
    }

    // create inner class for PitchData
    public class Game {
        String team1;
        String team2;
        int fieldNumber;
        int matchNumber;

        public Game(String team1, String team2, int fieldNumber, int matchNumber) {
            this.team1 = team1;
            this.team2 = team2;
            this.fieldNumber = fieldNumber;
            this.matchNumber = matchNumber;
        }
    }
}