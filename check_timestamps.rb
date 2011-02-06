require 'rubygems'
require 'gdocs4ruby'
require 'logger'
require 'mail'
require 'StripeStore'

store = StripeStore.new
store.emails.each { |e|
    log = Logger.new('stripe_email.log')
    email = store.get_email(e)

    # Update values
    email.query_pad
    log.debug "Checking timestamps for email from #{email.from} to #{email.to} with subject #{email.subject}"

    current_time = Time.new
    last_modified = email.last_modified
    created_at = email.created_at

    # See if it's been created at least an hour ago
    next if current_time - created_at < 3600
    log.debug "Checking last modified."
    
    # See if it was last updated at least a while ago
    next if current_time - last_modified < 60

    # Set up email
    content = email.content
    mail = Mail.new do
        from 'gdb@stripe.com'
        to 'chandrasekaran.siddarth@gmail.com'
        body content
        subject email.subject
    end
    email_string = mail.to_s

    cmd = "/etc/postfix/filter -f gdb+1@stripe.com chandrasekaran.siddarth@gmail.com <<EOF
        #{email_string}"
    log.debug "Sending email"
    p cmd
    exec(cmd)
    StripeStore.delete('email.subject')
}
