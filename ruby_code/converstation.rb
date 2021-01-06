class Conversation < ActiveRecord::Base
    belongs_to :employer
    belongs_to :student
    has_many :employees, through: :employer
    belongs_to :creator, class_name: 'User', foreign_key: 'initiated_by'
    has_many :messages, inverse_of: :conversation
  
    validates :employer, presence: true, uniqueness: { scope: :student, message: "conversation already exists between users" }
    validates :student, presence: true, approved_student: true
    validates :creator, presence: true, approved_user: true
    validate :student_or_employee_of_employer
    
    
    
    private
      def self.unread_messages_count(user)
        if user.student?
          to_return = self.select("SUM(messages.read is 'f' AND sent_by != #{user.id}) as unread_message_count").joins(:messages)
        elsif user.employee
          to_return = self.select("SUM(messages.read is 'f' AND students.id IS NOT NULL) as unread_message_count").joins(:messages => :sender)
                     .joins('LEFT OUTER JOIN students ON users.id = students.user_id')
        else
          return self.none
        end
        to_return.select('count(messages.id) as message_count').group('conversations.id')
      end
      def student_or_employee_of_employer
        if errors.empty?
          if creator.employee?
            return errors.add(:creator, "must be an employee of the employer") if creator.employer.id != employer_id
          elsif !creator.student? 
            # This should only catch admins, unapproved admins, and any new user roles
            return errors.add(:creator, "only students and employees can create conversations")
          end
            
        end
      end
  end
  