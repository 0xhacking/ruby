class EventsController < ApplicationController
	#before_action :set_event, :only=>[ :show, :edit, :update, :description]
	def index
		@events = Event.page(params[:page]).per(5)
		
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

	private 

	def set_event
		@event = Event.find(params[:id])
	end

	def event_params
		params.require(:event).permit(:name, :description)
	end
end
