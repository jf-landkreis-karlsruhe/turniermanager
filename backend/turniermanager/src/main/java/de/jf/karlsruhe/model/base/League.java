package de.jf.karlsruhe.model.base;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;

import java.util.List;
import java.util.UUID;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class League {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    private UUID id;

    private String name;

    boolean isQualification;


    @ManyToOne
    @JoinColumn(name = "tournament_id", nullable = false)
    @ToString.Exclude // Verhindert rekursive Schleifen in toString()
    @EqualsAndHashCode.Exclude
    private Tournament tournament; // Zugehöriges Turnier

    @OneToMany(mappedBy = "league", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude // Verhindert rekursive Schleifen in toString()
    @EqualsAndHashCode.Exclude
    private List<Team> teams; // Teams in der Liga

    @ManyToOne
    @JoinColumn(name = "age_group_id") // Fremdschlüssel in der League-Tabelle
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private AgeGroup ageGroup; // Altersgruppe der Liga (optional)

    @ManyToOne
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Round round;

}