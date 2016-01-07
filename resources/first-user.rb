
resource_name :spacewalk_admin

property :login, String, name_property: true
property :password, String, required: true
property :salt, String, default: 'Q2fxUTqBPoynaN9M'
property :prefix, String, required: true
property :first_name, String, required: true
property :last_name, String, required: true
property :db_user, String, required: true
property :db_password, String, required: true
property :db_schema, String, required: true
property :user_exists, String, default: "t" # Used for the idempotent check should not be used in recipes

#
# For the idempotent check we are only looking to see if there is a row in web_contact.
# We only want to create the first user and if there is a row in web_contact it has already been done
# We don't monitor the values like first name for changes.
load_current_value do |new_resource|
  # Must provide "current" values for all the required properties or it will throw an error that required properties are blank
  # It must be done before anything else too, cheat and just use values from the new resource and we have new_resource available
  # new_resource is being passed in because we need the db user etc to run the query check

  login = new_resource.login
  password = new_resource.password
  prefix = new_resource.prefix
  first_name = new_resource.first_name
  last_name = new_resource.last_name
  db_user = new_resource.db_user
  db_password = new_resource.db_password
  db_schema = new_resource.db_schema

  cmd = "export PGPASSWORD=#{new_resource.db_password}; VALUE=$(psql -d #{new_resource.db_schema} -U #{new_resource.db_user} -qtA -c 'select exists(select 1  from web_contact);');echo $VALUE"
  user_exists = %x( #{cmd} )
end

action :start do
  converge_if_changed :user_exists do
    psqlscript = Chef::Config[:file_cache_path] + '/first_user.psql'

    # Web UI appears to store a salted sha256 hash of the password
    password_hash = password.crypt("$5$#{salt}")

     template psqlscript do
       source 'first_user.psql.erb'
       owner 'root'
       group 'root'
       mode '0600'
       variables ({
         :first_user_login => "#{login}",
         :first_user_password => "#{password_hash}",
         :first_user_prefix => "#{prefix}",
         :first_user_first_name => "#{first_name}",
         :first_user_last_name => "#{last_name}"
         })
     end

     execute 'psql_script' do
       command "export PGPASSWORD=#{db_password}; psql -1 -f " + psqlscript +" #{db_schema} #{db_user}"
     end

     # Don't leave the file with the password hash lying around
     file psqlscript do
       action :delete
     end

  end
end
