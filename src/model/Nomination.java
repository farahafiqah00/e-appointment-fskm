package model;

import java.sql.Timestamp;
import java.util.List;

/** Represents an examiner nomination submitted by an academician for dean/admin review. */
public class Nomination {
    private int id;
    private Integer externalExaminerId;
    private int nominatorUserId;
    private String remarks;
    private String status;
    private Timestamp nominationDate;
    private Timestamp createdAt;

    // convenience fields
    private String  examinerName;
    private String  examinerAffiliation;
    private String  examinerEmail;
    private String  nominatorName;
    private String  candidateName;
    private boolean examinerConfirmed;
    private String  discrepancyNotes;

    public Nomination() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Integer getExternalExaminerId() { return externalExaminerId; }
    public void setExternalExaminerId(Integer externalExaminerId) { this.externalExaminerId = externalExaminerId; }
    public int getNominatorUserId() { return nominatorUserId; }
    public void setNominatorUserId(int nominatorUserId) { this.nominatorUserId = nominatorUserId; }
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getNominationDate() { return nominationDate; }
    public void setNominationDate(Timestamp nominationDate) { this.nominationDate = nominationDate; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public String getExaminerName() { return examinerName; }
    public void setExaminerName(String examinerName) { this.examinerName = examinerName; }
    public String getExaminerAffiliation() { return examinerAffiliation; }
    public void setExaminerAffiliation(String examinerAffiliation) { this.examinerAffiliation = examinerAffiliation; }
    public String getExaminerEmail() { return examinerEmail; }
    public void setExaminerEmail(String examinerEmail) { this.examinerEmail = examinerEmail; }
    public String getNominatorName() { return nominatorName; }
    public void setNominatorName(String nominatorName) { this.nominatorName = nominatorName; }
    public String getCandidateName() { return candidateName; }
    public void setCandidateName(String candidateName) { this.candidateName = candidateName; }
    public boolean isExaminerConfirmed() { return examinerConfirmed; }
    public void setExaminerConfirmed(boolean examinerConfirmed) { this.examinerConfirmed = examinerConfirmed; }
    public String getDiscrepancyNotes() { return discrepancyNotes; }
    public void setDiscrepancyNotes(String discrepancyNotes) { this.discrepancyNotes = discrepancyNotes; }
}
