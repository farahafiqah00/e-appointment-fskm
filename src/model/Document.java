package model;

/** Represents an uploaded supporting document attached to a nomination. */
public class Document {
    private int id;
    private Integer nominationId;
    private Integer uploadedBy;
    private String filename;
    private String filepath;
    private String fileType;

    public Document() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Integer getNominationId() { return nominationId; }
    public void setNominationId(Integer nominationId) { this.nominationId = nominationId; }
    public Integer getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(Integer uploadedBy) { this.uploadedBy = uploadedBy; }
    public String getFilename() { return filename; }
    public void setFilename(String filename) { this.filename = filename; }
    public String getFilepath() { return filepath; }
    public void setFilepath(String filepath) { this.filepath = filepath; }
    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }
}
