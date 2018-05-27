class EmailAttachmentUploader
  constructor: ->
    @uploadFileSelected()

  hideAndDisableFileField: ->
    $("form.with_email_attachment .loading-pic").removeClass("hide")    
    $("form.with_email_attachment input:submit").prop("disabled", true)
    $("form.with_email_attachment #add-email-attachment input:file").prop("disabled", true)
    $("form.with_email_attachment #add-email-attachment input:file").addClass("hide")

  showAndEnableFileField: ->
    $("form.with_email_attachment .loading-pic").addClass("hide")    
    $("form.with_email_attachment input:submit").prop("disabled", false)
    $("form.with_email_attachment #add-email-attachment input:file").prop("disabled", false)
    $("form.with_email_attachment #add-email-attachment input:file").removeClass("hide")

  uploadFileSelected: ->

    $("#fileupload").fileupload
      dataType: "json"

      add: (e, data) =>
        file  = data.files[0]
        regex = new RegExp(".*\.(jpg|jpeg|png|doc|docx|pages|pdf|numbers|csv|txt|xlsx|xls)$", 'i')

        if file.name.match(regex) || file.type.match(regex)
          @hideAndDisableFileField()
          data.submit()                   
        else
          alert("You must upload a word doc, excel, numbers, txt, csv, pdf, pages, jpg, jpeg, or png.")
    
      done: (e, data) =>
        if data.result.success is true
          id = data.result.email_attachment.id
          file_name = data.result.email_attachment.name          

          $("form.with_email_attachment .attachable_id").val(id)      
          
          $("form.with_email_attachment .loading-pic").addClass("hide")
          $("form.with_email_attachment input:submit").prop("disabled", false)

          $("form.with_email_attachment #add-email-attachment").append("<p class=\"file_name\"><span class=\"left state rMargin file\">file icon</span>#{file_name}</p>")
          $("form.with_email_attachment #add-email-attachment").prepend("<a href=\"/manage/email_attachments/#{id}\" data-method=\"delete\" data-type=\"json\" data-remote=\"true\" class=\"removeAttachment right\">remove</a>")

          $("form.with_email_attachment a.removeAttachment").click () ->
            $("form.with_email_attachment #add-email-attachment input:file").prop("disabled", false)
            $("form.with_email_attachment #add-email-attachment input:file").removeClass("hide")
            $("form.with_email_attachment #add-email-attachment p.file_name").remove()
            $("form.with_email_attachment #add-email-attachment a.removeAttachment").remove()
            $("form.with_email_attachment .attachable_id").val("")
        else
          alert("Make sure your file is under 5mbs and is the correct format")
          @showAndEnableFileField()

window.EmailAttachmentUploader = EmailAttachmentUploader