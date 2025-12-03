class MessagesController < ApplicationController
  before_action :require_login
  before_action :set_conversation

  # POST /conversations/:conversation_id/messages
  def create
    unless conversation_participant?
      redirect_to conversations_path, alert: "You don't have access to this conversation."
      return
    end

    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), notice: "Message sent." }
        format.turbo_stream
        format.json { render json: @message, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          @messages = @conversation.messages.includes(:user).order(created_at: :asc)
          flash.now[:alert] = "Message could not be sent."
          render 'conversations/show', status: :unprocessable_entity
        end
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
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
      redirect_to login_path, alert: "You must be logged in."
    end
  end
end