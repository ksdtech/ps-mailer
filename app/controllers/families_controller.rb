class FamiliesController < ApplicationController
  # GET /families
  # GET /families.xml
  def index
    incl = nil
    joins = nil
    conds = nil
    if params[:incomplete]
      incl = :students
      conds = ['students.reg_complete<>1']
    elsif params[:nostudents]
      joins = 'LEFT JOIN family_students ON family_students.family_id=families.id'
      conds = ['family_students.family_id IS NULL']
    elsif params[:noemails]
      joins = 'LEFT JOIN email_addresses ON email_addresses.family_id=families.id'
      conds = ['email_addresses.family_id IS NULL']
    elsif params[:alpha] 
      conds = ['last_name LIKE ?', "#{params[:alpha]}\%" ] 
    end
    @families = Family.paginate(:include => incl, :joins => joins, 
      :conditions => conds, :order => 'families.last_name',
      :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @families }
    end
  end

  # GET /families/1/notify?template=reg_form_invite
  def notify
    @family = Family.find(params[:id])
    templ = params[:template] || :reg_form_invite
    fc = @family.queue_mail(templ)
    if fc.nil?
      flash[:notice] = "No mail queued"
    else
      flash[:notice] = "#{fc.emails.count} emails queued"
    end
    redirect_to(family_url(@family))
  end

  # GET /families/notify_incomplete?template=reg_form_reminder_1
  def notify_incomplete
    @family = Family.find_incomplete
    templ = params[:template] || :reg_form_reminder_1
    fc = @family.queue_mail(templ)
    if fc.nil?
      flash[:notice] = "No mail queued"
    else
      flash[:notice] = "#{fc.emails.count} emails queued"
    end
    redirect_to(family_url(@family))
  end


  # GET /families/1
  # GET /families/1.xml
  def show
    @family = Family.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @family }
    end
  end

  # GET /families/new
  # GET /families/new.xml
  def new
    @family = Family.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @family }
    end
  end

  # GET /families/1/edit
  def edit
    @family = Family.find(params[:id])
  end

  # POST /families
  # POST /families.xml
  def create
    @family = Family.new(params[:family])

    respond_to do |format|
      if @family.save
        flash[:notice] = 'Family was successfully created.'
        format.html { redirect_to(@family) }
        format.xml  { render :xml => @family, :status => :created, :location => @family }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /families/1
  # PUT /families/1.xml
  def update
    @family = Family.find(params[:id])

    respond_to do |format|
      if @family.update_attributes(params[:family])
        flash[:notice] = 'Family was successfully updated.'
        format.html { redirect_to(@family) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /families/1
  # DELETE /families/1.xml
  def destroy
    @family = Family.find(params[:id])
    @family.destroy

    respond_to do |format|
      format.html { redirect_to(families_url) }
      format.xml  { head :ok }
    end
  end
end
