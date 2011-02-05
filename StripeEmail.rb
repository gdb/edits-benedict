require 'rubygems'
require 'gdocs4ruby'
require 'logger'
require 'mail'
require 'StripeStore'

# Class StripeEmail
# Stores data using pstore, initializes pad, and can be used to query pad
class StripeEmail
    @@log = Logger.new('edits-benedict.log')

	attr_accessor :from, :to, :subject, :body, :admin
	attr_reader :pad_id, :last_modified, :content, :created_at

    # Updates class variables last_modified and content
    def query_pad
        doc = GDocs4Ruby::Document.find(@service, { :id => @pad_id })
        @content = doc.get_content('txt')
        @last_modified = doc.updated
    end

    # Initialize class variables and populate etherpad
	def initialize(from, to, subject, body)
        @created_at = Time.new
        @from, @to, @subject, @body = from, to, subject, body

        # Initialize the GDocs4Ruby service and authenticate
        @service = GDocs4Ruby::Service.new()
        @service.authenticate('siddarth.bot@gmail.com', '')

        # Initialize Google doc
	    @pad_id = initialize_pad()

        # Store email in pstore
	    store()

        # Send the email to admin
	    send_admin_email()

        # Config
        @@config = YAML.load('edits-benedict.conf')
	    @admin = @@config['users']['admin']
	    @editors = @@config['users']['editors']
	end
	
    # Initialize a pad with @body
    def initialize_pad()
        @@log.debug "Initializing a new Google Document."
        doc = GDocs4Ruby::Document.new(@service)
        doc.title = "Email Review: #{@subject}"
        doc.content = @body
        doc.content_type = 'txt'
        doc.save
        # XXX: Here comes a small hack.
        pad_id = doc.id[9..-1]
        p pad_id
        p doc.get_content('txt')
        @editors.each { |email| doc.add_access_rule(email, 'writer') }
        @@log.debug "Google Document initialized: #{pad_id}"
        return pad_id
    end
	
	# Store the email locally
	def store()
        StripeStore.new.insert(self)
    end

    # Send email to admins notifying them of the email ID
	def send_admin_email()
	    admin_email_body = sprintf(@@config['email']['body'], @from, generate_url, @body)
        admin_email_subject = sprintf(@@config['email']['subject'], @subject)
        editors = @editors.join(',')
	    mail = Mail.new do
            from @admin
            to email_to
            subject email_subject
            body email_body
        end
        
        mail.deliver!    
	end
	
	# Generate URL for the export pages of different formats
	def generate_url
	    "https://docs.google.com/document/d/#{@pad_id}/edit?hl=en#"
    end
end
