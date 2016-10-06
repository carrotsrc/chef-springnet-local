
service 'php-fpm' do
    action :stop
end

user node[:netnode][:user] do
    action :remove
end

group node[:netnode][:user] do
    action :remove
end

file '/etc/php-fpm.d/'<< node[:netnode][:user] << '.conf' do
    action :delete
end

service 'php-fpm' do
    action :start
end

link '/etc/nginx/sites-enabled/'<< node[:netnode][:sub] << '.zni.lan.conf' do
    action :delete
end

file '/etc/nginx/sites-available/'<< node[:netnode][:sub] << '.zni.lan.conf' do
    action :delete
end



directory '/home/'<< node[:netnode][:user] do
    action :delete
    recursive true
    only_if{node[:netnode][:user] != ""}
end


ruby_block 'rem_host' do
    block do
	    line = '127.0.0.1 ' << node[:netnode][:sub] << '.zni.lan'
	    file = Chef::Util::FileEdit.new('/etc/hosts')
	    file.search_file_delete_line(/#{line}/)
	    file.write_file
    end
end

ruby_block 'rem_subdomain_listing' do
    block do
	    line = node[:netnode][:sub] << '.zni.lan,/home/'<< node[:netnode][:user] << '/www/public_html'
	    file = Chef::Util::FileEdit.new('/etc/nginx/subdomain.listing')
	    file.search_file_delete_line(/#{line}/)
	    file.write_file
    end
end

service 'nginx' do
    action :restart
end
