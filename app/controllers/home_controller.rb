require 'people_search'

class HomeController < ActionController::Base
  protect_from_forgery
  layout "application"
  
   def index   
   	session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + '/home/callback')
		@auth_url =  session[:oauth].url_for_oauth_code(:permissions=>"read_stream") 	
		puts session.to_s + "<<< session"

  	respond_to do |format|
			 format.html {  }
		 end
  end

	def callback
  	if params[:code]
  		# acknowledge code and get access token from FB
		  session[:access_token] = session[:oauth].get_access_token(params[:code])
		end		

		 # auth established, now do a graph call:
		  
		@api = Koala::Facebook::API.new(session[:access_token])
		begin
			@graph_data2 = @api.get_object("/me/friends", "fields"=>"name,location,first_name,last_name,picture,birthday")
			
			@graph_data2.each do |friend|
			place = friend["location"] && friend["location"]["name"].to_s.delete('^A-Za-z0-9_,')
  		fname = friend["first_name"] && friend["first_name"].to_s.delete('^A-Za-z0-9_')
  		lname = friend["last_name"] && friend["last_name"].to_s.delete('^A-Za-z0-9_')
      friend['wp'] = PeopleSearch.person_search(fname, lname, place.to_s)
      end


		rescue Exception=>ex
    end
		
  
 		respond_to do |format|
		 format.html {   }			 
		end
		
	
	end
end

