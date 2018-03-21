package io.pivotal.pcf.sme.ers.server.repo;

import io.pivotal.pcf.sme.ers.server.model.Attendee;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;

@RepositoryRestResource(collectionResourceRel = "attendees", path = "attendees")
public interface AttendeeRepository extends JpaRepository<Attendee, Long> {
	
    //@RestResource(exported = false)
	//Page<Attendee> findAll(Pageable pageable);

//    @RestResource(exported = false)
//    Attendee findById(Long id);

    @RestResource(path = "name", rel = "name")
    Page<Attendee> findByFirstNameIgnoreCase(@Param("q") String firstName, Pageable pageable);

    @RestResource(path = "nameContains", rel = "nameContains")
    Page<Attendee> findByFirstNameContainsIgnoreCase(@Param("q") String firstName, Pageable pageable);

    @RestResource(path = "state", rel = "state")
    Page<Attendee> findByStateIgnoreCase(@Param("q") String state, Pageable pageable);

    @RestResource(path = "zipCode", rel = "zipCode")
    Page<Attendee> findByZipCode(@Param("q") String postalCode, Pageable pageable);

}
