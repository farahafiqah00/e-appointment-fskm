package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/** Represents a viva appointment, linking a candidate to a scheduled panel and letter workflow. */
public class VivaAppointment {
    private int id;
    private int candidateId;
    private Integer nominationId;
    private Timestamp scheduledAt;
    private String venue;
    private int durationMinutes;
    private String status;
    private Timestamp createdAt;

    // convenience fields
    private String candidateName;
    private String candidateProgram;
    private String candidateProgramMS;    // Malay program name from program.name_ms (null if not set)
    private String candidateProgramLevel; // "PhD" or "Master" from program.level
    private String candidateStudentId;
    private String candidateVivaStatus;
    private String thesisTitle;
    private String supervisorName;
    private Integer supervisorUserId;

    // panel role fields (single-value, populated by findAllWithRoles for list views)
    private String chairpersonName;
    private String recorderName;
    private String internalExaminerName;
    private String externalExaminerName;
    // panel role IDs (single-value, for backward compatibility)
    private Integer chairpersonId;
    private Integer recorderId;
    private Integer internalExaminerId;
    private Integer externalExaminerId;

    // multi-examiner support (populated by findById)
    private List<java.util.Map<String,Object>> panelMembers = new ArrayList<>();
    private java.util.Map<String,Object> letterApproval;

    public VivaAppointment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }
    public Integer getNominationId() { return nominationId; }
    public void setNominationId(Integer nominationId) { this.nominationId = nominationId; }
    public Timestamp getScheduledAt() { return scheduledAt; }
    public void setScheduledAt(Timestamp scheduledAt) { this.scheduledAt = scheduledAt; }
    public String getVenue() { return venue; }
    public void setVenue(String venue) { this.venue = venue; }
    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int durationMinutes) { this.durationMinutes = durationMinutes; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getCandidateName() { return candidateName; }
    public void setCandidateName(String candidateName) { this.candidateName = candidateName; }
    public String getCandidateProgram() { return candidateProgram; }
    public void setCandidateProgram(String candidateProgram) { this.candidateProgram = candidateProgram; }
    public String getCandidateProgramMS() { return candidateProgramMS; }
    public void setCandidateProgramMS(String candidateProgramMS) { this.candidateProgramMS = candidateProgramMS; }
    public String getCandidateProgramLevel() { return candidateProgramLevel; }
    public void setCandidateProgramLevel(String l) { this.candidateProgramLevel = l; }
    public String getCandidateStudentId() { return candidateStudentId; }
    public void setCandidateStudentId(String candidateStudentId) { this.candidateStudentId = candidateStudentId; }
    public String getCandidateVivaStatus() { return candidateVivaStatus; }
    public void setCandidateVivaStatus(String candidateVivaStatus) { this.candidateVivaStatus = candidateVivaStatus; }
    public String getThesisTitle() { return thesisTitle; }
    public void setThesisTitle(String thesisTitle) { this.thesisTitle = thesisTitle; }
    public String getSupervisorName() { return supervisorName; }
    public void setSupervisorName(String supervisorName) { this.supervisorName = supervisorName; }
    public Integer getSupervisorUserId() { return supervisorUserId; }
    public void setSupervisorUserId(Integer supervisorUserId) { this.supervisorUserId = supervisorUserId; }

    public String getChairpersonName() { return chairpersonName; }
    public void setChairpersonName(String chairpersonName) { this.chairpersonName = chairpersonName; }
    public String getRecorderName() { return recorderName; }
    public void setRecorderName(String recorderName) { this.recorderName = recorderName; }
    public String getInternalExaminerName() { return internalExaminerName; }
    public void setInternalExaminerName(String internalExaminerName) { this.internalExaminerName = internalExaminerName; }
    public String getExternalExaminerName() { return externalExaminerName; }
    public void setExternalExaminerName(String externalExaminerName) { this.externalExaminerName = externalExaminerName; }
    public Integer getChairpersonId() { return chairpersonId; }
    public void setChairpersonId(Integer chairpersonId) { this.chairpersonId = chairpersonId; }
    public Integer getRecorderId() { return recorderId; }
    public void setRecorderId(Integer recorderId) { this.recorderId = recorderId; }
    public Integer getInternalExaminerId() { return internalExaminerId; }
    public void setInternalExaminerId(Integer internalExaminerId) { this.internalExaminerId = internalExaminerId; }
    public Integer getExternalExaminerId() { return externalExaminerId; }
    public void setExternalExaminerId(Integer externalExaminerId) { this.externalExaminerId = externalExaminerId; }

    public List<java.util.Map<String,Object>> getPanelMembers() { return panelMembers; }
    public void setPanelMembers(List<java.util.Map<String,Object>> panelMembers) {
        this.panelMembers = panelMembers != null ? panelMembers : new ArrayList<>();
    }

    public java.util.Map<String,Object> getLetterApproval() { return letterApproval; }
    public void setLetterApproval(java.util.Map<String,Object> letterApproval) { this.letterApproval = letterApproval; }
}
