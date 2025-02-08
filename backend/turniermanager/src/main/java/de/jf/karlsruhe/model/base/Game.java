package de.jf.karlsruhe.model.base;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Game {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    private UUID id;

    private LocalDateTime startTime;
    private int teamAScore;
    private int teamBScore;

    @ManyToOne
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Pitch pitch;

    @ManyToOne
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Team teamA;

    @ManyToOne
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Team teamB;

    @ManyToOne
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Round round;
}