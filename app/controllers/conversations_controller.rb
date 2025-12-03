class ConversationsController < ApplicationController
  before_action :require_login
  before_action :set_conversation, only: [:show, :poll]

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
    unless conversation_participant?
      redirect_to conversations_path, alert: "You don't have access to this conversation."
      return
    end

    @messages = @conversation.messages
                             .includes(:user)
                             .order(created_at: :asc)
    @message = Message.new
  end

  # GET /conversations/:id/poll
  def poll
    unless conversation_participant?
      render json: { error: "Unauthorized" }, status: :forbidden
      return
    end

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
      redirect_to request.referrer || root_path, alert: "User not found."
      return
    end

    if other_user.id == current_user.id
      redirect_to request.referrer || root_path, alert: "You cannot start a conversation with yourself."
      return
    end

    @conversation = find_or_create_conversation(current_user.id, other_user.id)

    if @conversation.persisted?
      redirect_to conversation_path(@conversation), notice: "Conversation started."
    else
      redirect_to request.referrer || root_path, alert: "Unable to create conversation."
    end
  end

  private

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
      redirect_to login_path, alert: "You must be logged in to access conversations."
    end
  end
end