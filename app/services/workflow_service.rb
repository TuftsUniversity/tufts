class WorkflowService
  attr_reader :object, :user

  def initialize(object, user_id = nil)
    @object = object
    @user = User.find(user_id) if user_id
  end

  private

    def destroy_published_version!
      destroy_if_exists PidUtils.to_published(object.pid)
    end

    def destroy_draft_version!
      destroy_if_exists PidUtils.to_draft(object.pid)
    end

    def destroy_if_exists(pid)
      if object.class.exists?(pid)
        object.class.find(pid).destroy
      end
    end

    def audit(what)
      user_label = user ? user.user_key : 'unknown'
      AuditLogService.log(user_label, object.pid, what)
    end
end
