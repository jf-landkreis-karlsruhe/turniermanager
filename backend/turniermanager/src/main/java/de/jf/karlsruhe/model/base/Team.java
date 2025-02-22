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
public class Team {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator"
    )
    private UUID id;

    private String name;

    // Beziehung zu einer Altersgruppe
    @ManyToOne
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private AgeGroup ageGroup;

    @ManyToMany(mappedBy = "teams")  // Rückbeziehung, da "teams" in League die Many-to-Many-Seite ist
    @ToString.Exclude
    private List<League> leagues;

}