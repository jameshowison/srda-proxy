class NotreDameSfController < ApplicationController
  wsdl_service_name 'NotreDameSf'
  web_service_scaffold :invoke
  
  def make_query(nd_username,nd_password, schema, select, from, where, fix_xml)
    begin
      agent = SfNotreDameAgent.new(nd_username, nd_password)
    rescue Mechanize::ResponseCodeError => e
      raise ArgumentError.new("Username/Password incorrect")
    end
    
    return agent.query(:schema => schema, :from => from, :select => select, :where => where, :fix_xml => fix_xml)
  end
  
end
