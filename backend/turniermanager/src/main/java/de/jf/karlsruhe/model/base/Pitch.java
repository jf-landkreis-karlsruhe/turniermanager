package de.jf.karlsruhe.model.base;

import java.util.List;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

@Entity
public class Pitch {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String name;

	@OneToMany
	private List<AgeGroup> agegroup;

	public Pitch() {
	}

	public Pitch(Long id, String name, List<AgeGroup> agegroup) {
		this.id = id;
		this.name = name;
		this.agegroup = agegroup;
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

	public List<AgeGroup> getAgegroup() {
		return agegroup;
	}

	public void setAgegroup(List<AgeGroup> agegroup) {
		this.agegroup = agegroup;
	}

}
