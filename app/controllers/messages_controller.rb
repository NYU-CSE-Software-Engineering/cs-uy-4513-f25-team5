class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_conversation
  
  # POST /conversations/:conversation_id/messages
  def create
    unless conversation_participant?
      redirect_to conversations_path, alert: "You do not have access to this conversation."
      return
    end

    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to conversation_path(@conversation), notice: "Message sent."
    else
      @messages = @conversation.messages.includes(:user).order(created_at: :asc)
      flash.now[:alert] = "Message could not be sent."
      render 'conversations/show', status: :unprocessable_content
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def conversation_participant?
    @conversation.participant_one_id == current_user.id || 
    @conversation.participant_two_id == current_user.id
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def require_login
    unless current_user
      redirect_to auth_login_path, alert: "You must be logged in."
      return
    end
  end
end