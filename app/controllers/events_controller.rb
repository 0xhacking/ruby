class EventsController < ApplicationController
	#before_action :set_event, :only=>[ :show, :edit, :update, :description]
	def index
		if params[:keyword]
			@events = Event.where(["name like ?", "%#{params[:keyword]}%"]).page(params[:page])
		else
			@events = Event.page(params[:page]).per(5)
		end
		
		respond_to do |format|
			format.html 
			format.xml {render :xml=> @events.to_xml}
			format.json {render :json=> @events.to_json}
			format.atom { @feed_title = "My event list"}
		end
	end

	def new 
		@event = Event.new
	end
	
	def create
		@event = Event.new(event_params)
		if @event.save
			flash[:notice] = "success"
			redirect_to events_url 
		else
			flash[:alert] = "failed"
			render :action=>:new
		end
	end


	
	def show 
		@event = Event.find(params[:id])
		Rails.logger.debug("event: #{@event_inspect}" )
		@page_title = @event.name
		respond_to do |format|
			format.html {@page_title=@event.name}
			format.xml 
			format.json {render :json=>{id:@event.id, name:@event.name}.to_json}
		end
	end


	def edit 
		@event = Event.find(params[:id])
	end

	def update
		@event = Event.find(params[:id])
		if @event.update(event_params)
			flash[:notice] = "success"
			redirect_to event_url(@event) 
		else
			flash[:alert] = "failed"
			render :action => :edit
		end
	end
	
	def destroy
		@event = Event.find(params[:id])
		@event.destroy
		flash[:alert] = "failed"
		redirect_to :action=>:index
	end
		
	def latest
		@events = Event.order("id desc").limit(3)
	end

	def bulk_delete
		Event.destroy_all
		redirect_to events_path
	end

	def bulk_update
		ids = Array(params[:ids])
		events = ids.map{ |i| Event.find_by_id(i)}.compact

		if params[:commit] == "Publish"
			events.each{ |e| e.update( :status=>"published" )}
		elsif params[:commit] == "Delete"
			events.each{|e| e.destory}
		end
		
		redirect_to events_url
	end

	def dashboard
		@event = Event.find(params[:id])
	end
	
	def join
		@event = Event.find(params[:id])
		Membership.find_or_create_by(:event=>@event, :user=>current_user)
		redirect_to :back
	end

	def withdraw
		@event = Event.find(params[:id])
		@membership = Membership.find_by(:event=>@event, :user=>current_user)
		@membership.destroy
		
		redirect_to :back

	end

	private 

	def set_event
		@event = Event.find(params[:id])
	end

	def event_params
		params.require(:event).permit( :name, :description, :category_id, :location_attributes =>[:id, :name, :_destroy], :group_ids=>[] )
	end
end
