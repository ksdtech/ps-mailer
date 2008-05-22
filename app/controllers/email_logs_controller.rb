class EmailLogsController < ApplicationController
  # GET /email_logs
  # GET /email_logs.xml
  def index
    @email_logs = EmailLog.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @email_logs }
    end
  end

  # GET /email_logs/1.xml
  def show
    @email_log = EmailLog.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @email_log }
    end
  end
end
