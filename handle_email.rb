require 'rubygems'
require 'logger'
require 'StripeEmail'

body = <<-eos
Lorem ipsum dolor sit amet, consectetur adipiscing elit. In mattis lectus id purus auctor at scelerisque velit tristique. Aliquam erat volutpat. Suspendisse vitae lacus lacus, non pulvinar arcu. Nam nec odio quis dui ullamcorper mollis eget vitae justo. Donec ac leo sed nunc suscipit suscipit eget non risus. Nam ac purus vel mi auctor posuere id vitae nisl. Cras in leo ac ante sagittis posuere sodales sed nisl. Aenean eget velit ut nulla sodales fringilla in sit amet sem. Praesent sodales turpis sed diam facilisis placerat. Vestibulum vestibulum turpis et turpis accumsan semper ut viverra purus. Pellentesque vulputate porttitor posuere. Phasellus et nisl neque. Mauris euismod risus ut purus dignissim consequat. Vestibulum commodo velit sed turpis congue gravida interdum elit tempus. Aliquam bibendum ante at libero consequat ornare. Vivamus ipsum nibh, molestie sit amet elementum sed, suscipit vel libero. Nulla id sapien sit amet lacus congue laoreet a ac turpis. Maecenas sit amet egestas lacus. Donec luctus dapibus elit quis aliquam.
eos

StripeEmail.new('bot@stripe.com', 'chandrasekaran.siddarth@gmail.com', 'lorem ipsum', body)
