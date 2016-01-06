
property :user_name, String, name_property: true
property :password, String, required: true
property :salt, String, default: 'Q2fxUTqBPoynaN9M'
property :prefix, String, default:  'Mr.'
property :first_name, String, required: true
property :last_name, String, required: true

property :db_user, String, required: true
property :db_password, String, required: true
property :db_schema, String, required: true

load_current_value do
  cmd = "export PGPASSWORD=#{db_password}; VALUE=$(psql -d #{db_schema} -U #{db_user} -qtA -c 'select exists(select 1  from web_contact);');echo $VALUE"
  user_exists = %x( cmd )
  puts user_exits
end

action :start do
  converge_if_changed do
    psqlscript = Chef::Config[:file_cache_path] + '/first_user.psql'

    password_hash = password.crypt("$5$#{salt}")

     template psqlscript do
       source 'first_user.psql.erb'
       variables ({
         :first_user_name => "#{user_name}",
         :first_user_password => "#{}",
         :first_user_prefix => "#{prefix}",
         :first_user_first_name => "#{first_name}",
         :first_user_last_name => "#{last_name}"
         })
     end

     execute 'psql_script' do
       command "export PGPASSWORD=#{db_password}; psql -1 -f " + psqlscript +" #{db_schema} #{db_user}"
     end
   end

end
