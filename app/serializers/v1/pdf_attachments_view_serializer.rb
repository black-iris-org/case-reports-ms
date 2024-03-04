class V1::PdfAttachmentsViewSerializer < ApplicationSerializer
  fields :only_pdf_attachments, :created_by, :id, :user_id
end