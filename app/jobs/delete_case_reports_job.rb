class DeleteCaseReportsJob < ApplicationJob
  queue_as :default

  def perform(datacenter_id, user)

    CaseReport.where(datacenter_id: datacenter_id, deleted: nil).find_each(batch_size: 1) do |report|
      WipeSensitiveData.new(user).wipe_one(report)
      sleep(0.1)
    end
  end
end
