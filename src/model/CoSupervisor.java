package model;

/** Represents a co-supervisor linked to a nomination; may be internal staff or an external academic. */
public class CoSupervisor {

    private int     id;
    private String  cosvType = "external"; // "internal" | "external"
    private Integer internalStaffId;
    private String  name;
    private String  universityName;
    private String  faculty;
    private String  programme;
    private String  country;
    private String  email;

    public CoSupervisor() {}

    public int getId()                   { return id; }
    public void setId(int id)            { this.id = id; }

    public String getCosvType()          { return cosvType; }
    public void setCosvType(String t)    { this.cosvType = (t != null) ? t : "external"; }

    public Integer getInternalStaffId()             { return internalStaffId; }
    public void setInternalStaffId(Integer sid)     { this.internalStaffId = sid; }

    public String getName()              { return name; }
    public void setName(String name)     { this.name = name; }

    public String getUniversityName()                { return universityName; }
    public void setUniversityName(String u)          { this.universityName = u; }

    public String getFaculty()           { return faculty; }
    public void setFaculty(String f)     { this.faculty = f; }

    public String getProgramme()         { return programme; }
    public void setProgramme(String p)   { this.programme = p; }

    public String getCountry()           { return country; }
    public void setCountry(String c)     { this.country = c; }

    public String getEmail()             { return email; }
    public void setEmail(String e)       { this.email = e; }

    /** Comma-separated affiliation line used in UI tags. */
    public String getDisplayAffiliation() {
        StringBuilder sb = new StringBuilder();
        if (universityName != null && !universityName.isEmpty()) sb.append(universityName);
        if (faculty != null && !faculty.isEmpty()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(faculty);
        }
        return sb.toString();
    }
}
