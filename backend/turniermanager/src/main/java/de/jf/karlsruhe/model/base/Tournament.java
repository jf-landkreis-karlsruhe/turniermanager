package de.jf.karlsruhe.model.base;

import de.jf.karlsruhe.model.game.GameSettings;
import jakarta.persistence.*;
import lombok.*;

import org.hibernate.annotations.GenericGenerator;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tournament {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    private UUID id;

    private String name;

    @OneToMany(mappedBy = "tournament", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude // Verhindert rekursive Schleifen in toString()
    @EqualsAndHashCode.Exclude // Beziehung wird von Equals/HashCode ausgeschlossen
    private List<Round> rounds;

    @OneToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JoinColumn(name = "game_settings_id", referencedColumnName = "id")
    private GameSettings gameSettings;

    public void addRound(Round round) {
        if (this.rounds == null) {
            this.rounds = new ArrayList<>();
        }
        this.rounds.add(round);
    }

}