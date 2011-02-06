require 'pstore'
require 'StripeEmail'

class StripeStore
    # Config
    @@config = YAML.load(File.open('/var/stripe/edits-benedict/edits-benedict-cred.conf'))
    log_file = @@config['log']
    @@log = Logger.new(log_file)

    # Delete from pstore
    def delete(email)
        email_subject = email.subject
        @@log.debug "About to delete email with subject: #{email_subject}"
        @stripe_store.transaction {  @stripe_store.delete(email_subject) }
    end
   
    # Insert into pstore
    def insert(email)
        raise "Invalid argument to initialize: StripeEmail expected" unless email.class.to_s == "StripeEmail"
        @@log.debug "Received an insert query: #{email.mail.from} -> #{email.mail.to} [#{email.mail.subject}]"
        @stripe_store.transaction do
            @stripe_store[email.mail.subject] = email
        end
    end
    
    def initialize
        @@log.debug('Initializing pstore.')
        @stripe_store = PStore.new("stripe.store")
    end

    # Get all emails currently stored
    def emails
        @stripe_store.transaction { return @stripe_store.roots }
    end

    # Get a specific email based on subject
    def get_email(subject) 
        @stripe_store.transaction { return @stripe_store[subject] }
    end
end
