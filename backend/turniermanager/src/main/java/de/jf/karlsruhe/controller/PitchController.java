package de.jf.karlsruhe.controller;

import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfWriter;
import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.Pitch;
import de.jf.karlsruhe.model.repos.GameRepository;
import de.jf.karlsruhe.model.repos.PitchRepository;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.awt.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/turniersetup/pitches")
@RequiredArgsConstructor
public class PitchController {

    private final PitchRepository pitchRepository;
    private final GameRepository gameRepository;

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

    @GetMapping(value = "/result-card/{id}", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> getResultCards(@PathVariable UUID id) {
        List<GameDTO> games = new ArrayList<>();
        Optional<Pitch> optionalPitch = pitchRepository.findById(id);

        if (optionalPitch.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Pitch pitch = optionalPitch.get();
        List<Game> byPitchId = gameRepository.findByPitchId(pitch.getId());
        if(byPitchId.isEmpty())return ResponseEntity.noContent().build();
        byPitchId.forEach(game -> {
            games.add(new GameDTO(game.getTeamA().getName(), game.getTeamB().getName(), pitch.getName(), game.getGameNumber()));
        });

        try {
            ByteArrayOutputStream out = createPdf(games);
            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=spielfeld" + id + ".pdf");
            return ResponseEntity.ok().headers(headers).body(out.toByteArray());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    private ByteArrayOutputStream createPdf(List<GameDTO> games) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter writer = PdfWriter.getInstance(document, out);
            writer.setCloseStream(false);
            document.open();

            Font font = new Font(
                    BaseFont.createFont(BaseFont.HELVETICA_BOLD, BaseFont.CP1252, BaseFont.NOT_EMBEDDED),
                    20F,
                    Font.BOLD,
                    Color.BLACK
            );

            for (GameDTO game : games) {
                Paragraph header = new Paragraph("Platz: " + game.fieldNumber + "    Spiel: " + game.matchNumber, font);
                header.setAlignment(Element.ALIGN_CENTER);
                document.add(header);
                document.add(new Paragraph("\n"));

                Table table = new Table(2);
                table.setWidth(100);
                table.addCell(createCell(game.team1));
                table.addCell(createCell(game.team2));
                table.addCell(createCell(game.team2));
                table.addCell(createCell(game.team1));
                document.add(table);
                document.add(new Paragraph("\n"));

                document.add(new Paragraph("Endergebnis:", font));
                document.add(new Paragraph(game.team1 + ": ________________"));
                document.add(new Paragraph(game.team2 + ": ________________"));

                document.newPage();
            }

            document.close();
            return out;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static Cell createCell(String text) {
        Paragraph paragraph = new Paragraph(text);
        paragraph.setAlignment(Element.ALIGN_CENTER);
        Cell cell = new Cell(paragraph);
        cell.setBorder(0);
        return cell;
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public class GameDTO {
        String team1;
        String team2;
        String fieldNumber;
        long matchNumber;
    }
}