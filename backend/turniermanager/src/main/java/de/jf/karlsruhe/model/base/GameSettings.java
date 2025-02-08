package de.jf.karlsruhe.model.game;

import de.jf.karlsruhe.model.base.Tournament;
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
public class GameSettings {

	@Id
	@GeneratedValue(generator = "UUID")
	@GenericGenerator(
			name = "UUID",
			strategy = "org.hibernate.id.UUIDGenerator"
	)
	private UUID id;

	private LocalDateTime startTime;
	private int breakTime;
	private int playTime;

	private int greatBreakTime;
	private LocalDateTime greatBreakStartTime;

	// Beziehung zu Tournament (One-to-One)
	@OneToOne(mappedBy = "gameSettings", cascade = CascadeType.ALL)
	@ToString.Exclude // Verhindert rekursive Schleifen in toString()
	@EqualsAndHashCode.Exclude // Beziehung wird von Equals/HashCode ausgeschlossen
	private Tournament tournament;
}