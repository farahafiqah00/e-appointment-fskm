package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/** Represents a postgraduate student candidate registered for a viva examination. */
public class Candidate {
    private int id;
    private String studentId;
    private String fullName;
    private String program;        // plain text fallback
    private Integer programId;     // FK to program table
    private String programName;    // loaded via JOIN
    private String programLevel;   // 'PhD' or 'Master' from program.level
    private String thesisTitle;
    private String supervisorName;
    private Integer supervisorId;  // FK to academic_staff (nullable)
    private List<CoSupervisor> coSupervisors = new ArrayList<>();
    private String contactEmail;
    private String nationality;
    private String status;
    private Timestamp createdAt;

    public Candidate() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }

    public Integer getProgramId() { return programId; }
    public void setProgramId(Integer programId) { this.programId = programId; }

    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }

    public String getProgramLevel() { return programLevel; }
    public void setProgramLevel(String programLevel) { this.programLevel = programLevel; }

    public String getThesisTitle() { return thesisTitle; }
    public void setThesisTitle(String thesisTitle) { this.thesisTitle = thesisTitle; }

    public String getSupervisorName() { return supervisorName; }
    public void setSupervisorName(String supervisorName) { this.supervisorName = supervisorName; }

    public Integer getSupervisorId() { return supervisorId; }
    public void setSupervisorId(Integer supervisorId) { this.supervisorId = supervisorId; }

    public List<CoSupervisor> getCoSupervisors() { return coSupervisors; }
    public void setCoSupervisors(List<CoSupervisor> coSupervisors) { this.coSupervisors = coSupervisors != null ? coSupervisors : new ArrayList<>(); }

    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }

    public String getNationality() { return nationality; }
    public void setNationality(String nationality) { this.nationality = nationality; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    /** Returns the best display name for programme: programName if available, else program text. */
    public String getDisplayProgram() {
        return (programName != null && !programName.isEmpty()) ? programName : (program != null ? program : "");
    }
}
