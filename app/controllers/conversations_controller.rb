class ConversationsController < ApplicationController
  before_action :require_login
  before_action :set_conversation, only: [:show, :poll]
  before_action :authorize_participant!, only: [:show, :poll]

  def authorize_participant!
    unless conversation_participant?
      respond_to do |format|
        format.html { redirect_to conversations_path, alert: "You do not have access to this conversation." }
        format.json { render json: { error: "Unauthorized" }, status: :forbidden }
      end
    end
  end


  # GET /conversations
  def index
    @conversations = Conversation.where(
      "participant_one_id = ? OR participant_two_id = ?", 
      current_user.id, 
      current_user.id
    ).includes(:participant_one, :participant_two, :messages)
     .order(created_at: :desc)
  end

  # GET /conversations/:id
  def show
    @messages = @conversation.messages
                             .includes(:user)
                             .order(created_at: :asc)
    @message = Message.new
  end

  # GET /conversations/:id/poll
  def poll
    since = params[:since].present? ? Time.zone.parse(params[:since]) : 1.hour.ago

    new_messages = @conversation.messages
                                .where('created_at > ?', since)
                                .includes(:user)
                                .order(created_at: :asc)

    render json: {
      messages: new_messages.map { |msg| message_json(msg) },
      last_checked: Time.current.iso8601
    }
  end


  # POST /conversations
  def create
    other_user = User.find_by(id: params[:user_id])
    
    unless other_user
      redirect_to request.referrer || dashboard_path, alert: "User not found."
      return
    end

    if other_user.id == current_user.id
      redirect_to request.referrer || dashboard_path, alert: "You cannot start a conversation with yourself."
      return
    end

    unless users_are_matched?(current_user, other_user)
      redirect_to request.referrer || dashboard_path, alert: "You must be matched to send messages"
      return
    end

    @conversation = find_or_create_conversation(current_user.id, other_user.id)

    if @conversation.persisted?
      redirect_to conversation_path(@conversation), notice: "Conversation started."
    else
      redirect_to request.referrer || dashboard_path, alert: "Unable to create conversation."
    end
  end

  private

  def users_are_matched?(user1, user2)
    Match.where('(user_id = ? AND matched_user_id = ?) OR (user_id = ? AND matched_user_id = ?)',
                      user1.id, user2.id, user2.id, user1.id)
              .exists?
  end

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def conversation_participant?
    @conversation.participant_one_id == current_user.id || 
    @conversation.participant_two_id == current_user.id
  end

  def find_or_create_conversation(user_one_id, user_two_id)
    sorted_ids = [user_one_id, user_two_id].sort
    
    Conversation.find_or_create_by(
      participant_one_id: sorted_ids[0],
      participant_two_id: sorted_ids[1]
    )
  end

  def message_json(message)
    {
      id: message.id,
      body: message.body,
      created_at: message.created_at.strftime("%b %d, %I:%M %p"),
      user_id: message.user_id,
      user_name: message.user.display_name,
      is_current_user: message.user_id == current_user.id
    }
  end

  def require_login
    unless current_user
      redirect_to auth_login_path, alert: "You must be logged in to access conversations."
    end
  end
end