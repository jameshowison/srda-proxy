class NotreDameSfApi < ActionWebService::API::Base
  # This, along with a patch #7077, deals with the fact that 
  # Taverna sets an empty SOAP_ACTION HTTP header     
  # http://dev.rubyonrails.org/attachment/ticket/7077/
  class_inheritable_option :require_soap_action_header, false

  api_method  :make_query,              
              :expects => [ { :nd_username => :string }, 
                            { :nd_password => :string }, 
                            { :schema => :string },
                            { :select => :string },
                            { :from => :string },
                            { :where => :string},
                            { :fix_xml => :boolean } ],
              :returns => [ { :results => :string } ]

end