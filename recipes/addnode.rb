user node[:netnode][:user] do
    action :create
    home '/home/' << node[:netnode][:user]
end

group node[:netnode][:user] do
    action :modify
    members node[:netnode][:user]
    append true
end

execute 'change-home-permission' do
    command 'chmod 755 /home/' << node[:netnode][:user]
end

directory '/home/' << node[:netnode][:user] << '/www' do 
    action :create
    mode '0755'
    owner node[:netnode][:user]
    group node[:netnode][:user]
end

directory '/home/' << node[:netnode][:user] << '/www/public_html' do 
    action :create
    mode '0755'
    owner node[:netnode][:user]
    group node[:netnode][:user]
end

template '/etc/nginx/sites-available/'<< node[:netnode][:sub] << '.zni.lan.conf' do
    source 'nginx.conf.erb'
end

template '/home/'<< node[:netnode][:user] << '/www/public_html/index.php' do
   source 'index.php.erb'
end

template '/etc/php-fpm.d/'<< node[:netnode][:user] << '.conf' do
    source 'php-fpm.conf.erb'
end

ruby_block 'add_host' do
    block do
	    line = '127.0.0.1 ' << node[:netnode][:sub] << '.zni.lan'
	    file = Chef::Util::FileEdit.new('/etc/hosts')
	    file.insert_line_if_no_match(/#{line}/, line)
	    file.write_file
    end
end


link '/etc/nginx/sites-enabled/'<< node[:netnode][:sub] << '.zni.lan.conf' do
    to '/etc/nginx/sites-available/'<< node[:netnode][:sub] << '.zni.lan.conf' 
end



execute 'unpack-php-node' do
    cwd '/home/'<< node[:netnode][:user] << '/www/public_html'
    command 'tar -xf /home/cfg/Releases/SpringDvs/php.web.node/php.web.node_'<< node[:netnode][:version] << '.tgz --owner ' << node[:netnode][:user]
end

include_recipe 'springnet::autoconfig'

execute 'set-selinux-context' do
    cwd '/home/'<< node[:netnode][:user]
    command 'chcon -Rv --type=httpd_sys_rw_content_t www'
    #command 'chcon -Rv --type=httpd_sys_content_t www'
end

execute 'set-owner' do
    cwd '/home/'<< node[:netnode][:user]
    command 'chown -R '<< node[:netnode][:user] << ' *'
end

execute 'set-group' do
    cwd '/home/'<< node[:netnode][:user]
    command 'chgrp -R '<< node[:netnode][:user] << ' *'
end


ruby_block 'add_subdomain_listing' do
    block do
	    line = node[:netnode][:sub] << '.zni.lan,/home/'<< node[:netnode][:user] << '/www/public_html'
	    file = Chef::Util::FileEdit.new('/etc/nginx/subdomain.listing')
	    file.insert_line_if_no_match(/#{line}/, line)
	    file.write_file
    end
end

service 'nginx' do
    action :restart
end

service 'php-fpm' do
    action :restart
end
