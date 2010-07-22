class SfNotreDameAgent
    
  def initialize(user, pass)
    require 'mechanize'
    require "rexml/document"
    require "pp"
  
    # needed to get results below
    @user = user
    
    @agent = Mechanize.new
    
    url = "http://srda.cse.nd.edu/mediawiki/index.php?title=Special:Userlogin"   

    login_page = @agent.get(url)
      
    login_page.form_with(:name => 'userlogin') do |f|
      f['wpName'] = @user
      f['wpPassword'] = pass
    end.submit
    
    @query_page = @agent.get("http://srda.cse.nd.edu/cgi-bin/form.pl")
    
    if @query_page.body.match(/Login error:/)
      raise Figet("User/Password incorrect.")
    end
    
    # Only one on the page
    @query_form = @query_page.forms.first
    
    @query_form["useparator"] = "XML"
  end
  
  # args[:select] etc.
  # parses xml and returns results as a hash
  def query(args)  
   # pp args
    # fix the from element to use the right schema
    if (! args[:from].match(/schema\./) ) then
      args[:from] = args[:schema] + "." + args[:from]
    else 
      args[:from].gsub!(/schema\./, args[:schema] + ".")
    end
    
    args[:select].gsub!(/schema\./, args[:schema] + ".")
    args[:where].gsub!(/schema\./, args[:schema] + ".")
    
    #pp "Running query\n #{args.to_yaml}"
    
    @query_form["uitems"] = args[:select]
    @query_form["utables"] = args[:from]
    @query_form["uwhere"] = args[:where]
    
    results_page = @agent.submit(@query_form)
    
    # An error page has the error message in <pre> tags
    if match = results_page.body.match(/There was an error in your query:<br\/>(.*?)<\/p>/) 
      raise ArgumentError, "SRDA returned an error for query:\n#{args.to_yaml}.  Error was:\n#{match.captures.first}"
    else
      # A success now get the results.
      results = @agent.get("http://srda.cse.nd.edu/qresult/#{@user}/#{@user}.xml")
    end
    
    # Set an appropriate charset
     # Users table sends back latin1 while artifacts.details is utf8
     # That's obviously retarded, but there's no way to get the charset
     # perl has Encode::Detect and Encode::Guess
     # and 
     # https://svn.physiomeproject.org/svn/physiome/
     # sites/cellml_bugzilla/trunk/contrib/recode.pl
     
     # If it ain't utf8 then we gotta hope it is latin1 (ISO-8859-1)
     charset = if results.body.isutf8 then "utf-8" else "ISO-8859-1" end
     
     xml = "<?xml version='1.0' encoding='#{charset}'?>\n" + results.body
     
     # If the call has requested fixed xml (<records><record>)
     if args[:fix_xml]     
       doc = REXML::Document.new(xml)
       rows = doc.elements.to_a( "//row" )
       return self.rows_to_hash(rows).to_xml
     else
       return xml
     end
  end
  
  protected
  def rows_to_hash(rows)
      return rows.collect do |r|
       h = Hash.from_xml(r.to_s)
       h = h["row"] # remove rows container
       h.each {|k,v| h[k] = "" unless v} # deal with empty keys <details />
       h.values.each {|v| v.gsub!(/(^"|"$)/, "")} # remove extra ""
       h
      end
  end

end