class ConversationsController < ApplicationController
    before_action :authenticate_user!
    before_action :allow_roles_employee_student!, only: [:index, :create]
    before_action :allow_roles_admin!, except: [:index, :create] # keep this here as default if any are added
  
    # GET /conversations
    # GET /conversations.json
    def index
      if current_user.employee?
        @conversations = Conversation.where(employer_id: current_user.employer.id)
      elsif current_user.student?
        @conversations = Conversation.where(student_id: current_user.student.id)
      else
        return @conversations = Conversation.none
      end
      @conversations = @conversations.unread_messages_count(current_user).select('conversations.*')
    end
  
    # POST /messages
    # POST /messages.json
    def create
      if current_user.employee?
        conversation_hash = { employer_id: current_user.employer.id, student_id: Student.find_profile_path(conversation_params[:profile_path]).id }
      elsif current_user.student?
        conversation_hash = { employer_id: Employer.find_profile_path(conversation_params[:profile_path]).id, student_id: current_user.student.id }
      end
      @conversation = Conversation.find_or_initialize_by(conversation_hash) do |c|
        c.initiated_by = current_user.id
      end
      @conversation.messages.new(message_params)
  
      respond_to do |format|
        if @conversation.save
          notice = 'Message was successfully sent.'
          format.html { redirect_to conversation_messages_path(@conversation), notice: notice }
          format.json { render json: { notice: notice, conversation: @conversation, messages: @conversation.messages}, status: :created }
        else
          format.html { redirect_to :back }
          conversation_errors = @conversation.errors.full_messages.to_sentence
          message_errors = @conversation.messages.map { |message| message.errors.full_messages.to_sentence }.reject(&:empty?).join(', ')
          format.json { render json: { conversation: conversation_errors, messages: message_errors }, status: :unprocessable_entity }
        end
      end
    end
  
  #  # DELETE /conversations/1
  #  # DELETE /conversations/1.json
  #  def destroy
  #    @conversation.destroy
  #    respond_to do |format|
  #      format.html { redirect_to conversations_url, notice: 'Conversation was successfully destroyed.' }
  #      format.json { head :no_content }
  #    end
  #  end
  
    private
      # Never trust parameters from the scary internet, only allow the white list through.
      def conversation_params
        params.require(:conversation).permit(:profile_path) # This can be student or employer profile path
      end
      def message_params
        params.require(:message).permit(:body).update({ sent_by: current_user.id, read: false })
      end
  end
  