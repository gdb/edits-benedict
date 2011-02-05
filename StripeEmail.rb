['rubygems', 'gdocs4ruby', 'logger', 'mail', 'StripeStore'].each { |r| require r }

# Class StripeEmail
# Stores data using pstore, initializes pad, and can be used to query pad
class StripeEmail
    @@log = Logger.new('stripe_email.log')

	attr_accessor :from, :to, :subject, :body, :admin
	attr_reader :pad_id, :last_modified, :content, :created_at

    def query_pad
        doc = GDocs4Ruby::Document.find(@service, { :id => @pad_id })
        @content = doc.get_content('txt')
        @last_modified = doc.updated
    end

    # Initialize class variables and populate etherpad
	def initialize(from, to, subject, body)
        @created_at = Time.new
        @from, @to, @subject, @body = from, to, subject, body
	    @admin = 'chandrasekaran.siddarth@gmail.com'
	    @editors = ['chandrasekaran.siddarth@gmail.com']
        @service = GDocs4Ruby::Service.new()
        @service.authenticate('siddarth.bot@gmail.com', '') 
	    @pad_id = initialize_pad()
	    store()
	    send_admin_email()
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
	
	# Store in a pstore
	def store()
        StripeStore.new.insert(self)
    end

	def send_admin_email()
	    email_body = "This is an email review request from #{@from}. Please make any changes at #{generate_url}\n\n."
        email_subject = "[EMAIL REVIEW] #{@subject}"
        email_to = @editors.join(',')
	    mail = Mail.new do
            from 'bot@stripe.com'
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