package model;

import java.sql.Timestamp;

/** Represents an external examiner nominated to assess a postgraduate thesis. */
public class ExternalExaminer {
    private int id;
    private String name;
    private String affiliation;
    private String email;
    private String phone;
    private Integer universityId;
    private Integer countryId;
    private String status;
    private Timestamp createdAt;

    // Extended fields for nomination form
    private String title;
    private String gender;
    private String nationality;
    private String icPassport;
    private String faculty;
    private String country;
    private String specialization;
    private String qualification;
    private String position;

    // 4-level research hierarchy IDs
    private Integer specializationId;
    private Integer expertiseId;
    private Integer divisionId;
    private Integer areaId;

    public ExternalExaminer() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAffiliation() { return affiliation; }
    public void setAffiliation(String affiliation) { this.affiliation = affiliation; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public Integer getUniversityId() { return universityId; }
    public void setUniversityId(Integer universityId) { this.universityId = universityId; }
    public Integer getCountryId() { return countryId; }
    public void setCountryId(Integer countryId) { this.countryId = countryId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getNationality() { return nationality; }
    public void setNationality(String nationality) { this.nationality = nationality; }
    public String getIcPassport() { return icPassport; }
    public void setIcPassport(String icPassport) { this.icPassport = icPassport; }
    public String getFaculty() { return faculty; }
    public void setFaculty(String faculty) { this.faculty = faculty; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }
    public String getQualification() { return qualification; }
    public void setQualification(String qualification) { this.qualification = qualification; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public Integer getSpecializationId() { return specializationId; }
    public void setSpecializationId(Integer specializationId) { this.specializationId = specializationId; }
    public Integer getExpertiseId() { return expertiseId; }
    public void setExpertiseId(Integer expertiseId) { this.expertiseId = expertiseId; }
    public Integer getDivisionId() { return divisionId; }
    public void setDivisionId(Integer divisionId) { this.divisionId = divisionId; }
    public Integer getAreaId() { return areaId; }
    public void setAreaId(Integer areaId) { this.areaId = areaId; }

    // Verification fields
    private String    verificationToken;
    private java.sql.Timestamp tokenExpiresAt;
    private boolean   infoConfirmed;
    private java.sql.Timestamp confirmedAt;
    private String    discrepancyNotes;

    public String getVerificationToken()                { return verificationToken; }
    public void setVerificationToken(String t)          { this.verificationToken = t; }
    public java.sql.Timestamp getTokenExpiresAt()       { return tokenExpiresAt; }
    public void setTokenExpiresAt(java.sql.Timestamp t) { this.tokenExpiresAt = t; }
    public boolean isInfoConfirmed()                    { return infoConfirmed; }
    public void setInfoConfirmed(boolean b)             { this.infoConfirmed = b; }
    public java.sql.Timestamp getConfirmedAt()          { return confirmedAt; }
    public void setConfirmedAt(java.sql.Timestamp t)    { this.confirmedAt = t; }
    public String getDiscrepancyNotes()                 { return discrepancyNotes; }
    public void setDiscrepancyNotes(String s)           { this.discrepancyNotes = s; }
}
