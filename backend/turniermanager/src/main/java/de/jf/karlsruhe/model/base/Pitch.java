package de.jf.karlsruhe.model.base;

import java.util.List;

import jakarta.persistence.*;

@Entity
public class Pitch {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String name;

	public List<AgeGroup> getAgeGroups() {
		return ageGroups;
	}

	public void setAgeGroups(List<AgeGroup> ageGroups) {
		this.ageGroups = ageGroups;
	}

	@ManyToMany
	private List<AgeGroup> ageGroups;

	public Pitch() {
	}

	public Pitch(Long id, String name, List<AgeGroup> ageGroups) {
		this.id = id;
		this.name = name;
		this.ageGroups = ageGroups;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

}
