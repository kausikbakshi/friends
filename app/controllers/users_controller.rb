class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'application', :except => [:new]
  #layout 'application'
  # render new.rhtml


  def home
    @user = User.find(current_user.id)


    @posts = Post.all(:order => "created_at DESC",:conditions => {:receiver_id => current_user.id})
     respond_to do |format|
       format.html
     end


  end


  def index                                                                      # listing all users
    @friends = current_user.friends
#    @users = User.find(:all, :conditions => ["id != ? and ",current_user.id,])
    @users = User.find(:all, :conditions => ["id != ?" ,current_user.id])
  end


  def edit                                                                          #editing a user
    @user = User.find(params[:id])
  end



  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
             redirect_to home_users_path
#      render(:update) do |page|
#        page.replace_html 'mm', :text => "Picture Change successfully!"
#      end
      #user_path(:id=>current_user.id)
    else
      render :action => "edit"
    end
  end

  # adding a user to friend list
  def add_as_friend
    for fid in params[:friend_ids]
      @friend = Friend.find(:first, :conditions => {:friend_id => fid, :user_id => current_user.id})
      if @friend.blank?
        newfriend = Friend.new
        newfriend.user_id = current_user.id
        newfriend.friend_id = fid
        newfriend.save
      end
    end
    flash[:notice] = "You was successfully added this friend"
    redirect_to home_users_path
  end


  def view_friends                                                             #to view friendlist of current user
    @friends = current_user.friends


  end

  def new
    @user = User.new
  end

  def create
    
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    UserMailer::deliver_mailinfo(@user)
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session

      self.current_user = @user # !! now logged in
      redirect_to '/users/home'

      #|||||||redirect_back_or_default('/')
      #||||||flash[:notice] = "Thanks for signing up!"
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  # remove from friends list
  def destroyed
    for fid in params[:friend_ids]
      @friend = Friend.find(:first, :conditions => {:friend_id => fid, :user_id => current_user.id})
      @friend.destroy
    end
    redirect_to view_friends_users_path
  end



  def update_picture
   @user = current_user

    puts "Test =========== #{params[:user][:picture]}"
    #if current_user.update_attributes(params[:user])
     if @user.update_attributes(params[:user])
      p "Here picture will be updated!"
      redirect_to home_users_path
#      render(:update) do |page|
#        page.replace_html 'middleform', :text => "Picture Change successfully!"
#      end
     else
       p "Fails"
    end


  end
def onlyshow
  @user = User.find(params[:id])                      #display others profile

  @posts = Post.all(:order => "created_at DESC",:conditions => {:receiver_id => @user.id})
     respond_to do |format|
       format.html
     end
end






def create_comment

#     @post = Post.create(:message => params[:message],:conditions =>{:sender_id=>current_user.id})
      @post = Post.new(:message => params[:message],:sender_id => current_user.id,:receiver_id => params[:post][:receiver_id])
      @post.save
         redirect_to onlyshow_users_path(:id => params[:post][:receiver_id])




   end


end
