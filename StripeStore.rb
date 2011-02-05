require 'pstore'
require 'StripeEmail'

class StripeStore
    @@log = Logger.new('stripe_email.log')
    def delete(email)
        @stripe_store.delete(email.subject)
    end
    
    def insert(email)
        raise "Invalid argument to initialize: StripeEmail expected" unless email.class.to_s == "StripeEmail"
        @@log.debug "Received an insert query: #{email.from} -> #{email.to} [#{email.subject}]"
        @stripe_store.transaction do
            @stripe_store[email.subject] = email
        end
    end
    
    def initialize
        @@log.debug('Initializing pstore.')
        @stripe_store = PStore.new("stripe.store")
    end
    
    def emails
        @stripe_store.transaction { return @stripe_store.roots }
    end

    def get_email(subject) 
        @stripe_store.transaction { return @stripe_store[subject] }
    end
end
