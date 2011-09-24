class UserMailer < ActionMailer::Base
  def mailinfo(user)
   # setup_email(user)
   @recipients = user.email.strip
   @subject='hhhhhhhhhhhhh'
   @body={
     :user =>user
   }
  end

end
