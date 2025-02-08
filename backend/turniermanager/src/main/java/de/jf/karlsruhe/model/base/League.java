package de.jf.karlsruhe.model.base;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.GenericGenerator;

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

    @ManyToOne
    @JoinColumn(name = "tournament_id", nullable = false)
    @ToString.Exclude // Verhindert rekursive Schleifen in toString()
    @EqualsAndHashCode.Exclude
    private Tournament tournament; // Zugehöriges Turnier

}