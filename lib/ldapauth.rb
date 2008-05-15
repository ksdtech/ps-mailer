require 'net/ldap'
require 'yaml'
require 'plist'

class LDAPAuthConfig
  attr_accessor :host, :port, :userbase, :user, :password, 
    :userid_attribute, :uidnumber_attribute,
    :mail_attribute, 
    :groupbase, :groupid_attribute, :gidnumber_attribute,
    :groupmember_attribute, :guid_attribute, :nestedgroup_attribute
    
  def initialize(config)
    config = YAML.load(config) if !config.is_a?(Hash)
    config = config.symbolize_keys
    @host = config[:ldap_host]
    @port = config[:ldap_port] || 389
    @userbase = config[:ldap_userbase]
    @user = config[:ldap_user]
    @password = config[:ldap_password]
    @userid_attribute  = config[:ldap_userid_attribute] || 'uid'
    @uidnumber_attribute = config[:ldap_uidnumber_attribute] || 'uidnumber'
    @mail_attribute = config[:ldap_mail_attribute] || 'apple-user-mailattribute'
    @groupbase = config[:ldap_groupbase]
    @groupid_attribute = config[:ldap_groupid_attribute] || 'gid'
    @gidnumber_attribute = config[:ldap_gidnumber_attribute] || 'gidnumber'
    @groupmember_attribute = config[:ldap_groupmember_attribute] || 'memberuid'
    @guid_attribute = config[:ldap_guid_attribute] || 'apple-generateduid'
    @nestedgroup_attribute = config[:ldap_nestedgroup_attribute] || 'apple-group-nestedgroup'
  end  
end

class LDAPGroup
  attr_accessor :dn, :gid, :gidnumber
  
  def initialize(dn, gid, gidnumber, primary=true, nested=false)
    @dn = dn
    @gid = gid
    @gidnumber = gidnumber
    @primary = primary
    @nested = nested
  end
  
  def primary?
    @primary
  end
  
  def nested?
    @nested
  end
end

class LDAPUser
  attr_accessor :dn, :cn, :uid, :uidnumber, :groups, :primary_group, :apple_mail_attributes
  
  def initialize(dn, cn, uid, uidnumber)
    @dn = dn
    @cn = cn
    @uid = uid
    @uidnumber = uidnumber
    @apple_mail_attributes = nil
    @groups = { }
    @primary_group = nil
  end

  # Bind with the admin credentials and query the user dn
  # If login succeeds return an LDAPUser object
  # If login fails return false
  # options:
  #  :primary_group
  #  :member_groups (implies :primary_group)
  #  :nested_groups (implies :primary_group and :member_groups)
  #  :mail_attributes
  
  def self.authenticate(config, userid, password, options={ :member_groups => true, :nested_groups => true })
    if userid.to_s.length > 0 and password.to_s.length > 0
      uid_filter = Net::LDAP::Filter.eq( config.userid_attribute, userid )
      conn = Net::LDAP.new( :host => config.host, 
        :port => config.port, 
        :base => config.userbase, 
        :auth => { 
          :method => :simple, 
          :username => config.user, 
          :password => config.password } )
      rs = conn.bind_as(:filter => uid_filter, :password => password)
      if rs
        entry = rs.first
        u = LDAPUser.new(entry.dn, entry.cn.first, userid, 
          entry[ config.uidnumber_attribute ].first)
        if options[:mail_attributes]
          mail_plist = entry[ config.mail_attribute ].first || ''
          u.apple_mail_attributes = Plist::parse_xml(mail_plist) unless mail_plist.empty?
         end
        if options[:primary_group] || options[:member_groups] || options[:nested_groups]
          u.get_groups(conn, config, userid, entry, options)
        end
        return u
      end
    end
    return false
  end
  
  # Takes a DN and derives the name of the group from it
  # Returns name of group (in lower case)
  def get_groups(conn, config, userid, entry, options)
    primary_gid_number = entry[ config.gidnumber_attribute ]
    group_filter = Net::LDAP::Filter.eq( config.gidnumber_attribute, primary_gid_number )
    guids = [ ]
    nested = [ ]
    conn.search(:base => config.groupbase, :filter => group_filter) do |entry|
      guid = entry[ config.guid_attribute ].first
      guids.push guid
      gid = entry.cn.first
      @primary_group = LDAPGroup.new(entry.dn, gid, 
        entry[ config.gidnumber_attribute ].first)
      @groups[gid.downcase] = @primary_group
      entry[ config.nestedgroup_attribute ].each do |guid|
        nested.push guid unless nested.include? guid
      end
    end
    if options[:member_groups] || options[:nested_groups]
      member_filter = Net::LDAP::Filter.eq( config.groupmember_attribute, userid )
      conn.search(:base => config.groupbase, :filter => member_filter) do |entry|
        guid = entry[ config.guid_attribute ].first
        guids.push guid
        gid = entry.cn.first
        @groups[gid.downcase] = LDAPGroup.new(entry.dn, gid, 
          entry[ config.gidnumber_attribute ].first, false, false)
        entry[ config.nestedgroup_attribute ].each do |guid|
          nested.push guid unless nested.include? guid
        end
      end
      if options[:nested_groups]
        while nested.size > 0 do
          search_guids = nested.dup
          nested = [ ]
          nested_filter = nil
          search_guids.each do |guid|
            guid_filter = Net::LDAP::Filter.eq( config.guid_attribute, guid )
            nested_filter = nested_filter.nil? ? guid_filter : (nested_filter | guid_filter)
          end
          conn.search(:base => config.groupbase, :filter => nested_filter) do |entry|
            guid = entry[ config.guid_attribute ].first
            if !guids.include?(guid)
              guids.push guid
              gid = entry.cn.first
              @groups[gid.downcase] = LDAPGroup.new(entry.dn, gid, 
                entry[ config.gidnumber_attribute ].first, false, true)
              entry[ config.nestedgroup_attribute ].each do |guid|
                nested.push guid unless nested.include? guid
              end
            end
          end
        end
      end
    end
  end
end

