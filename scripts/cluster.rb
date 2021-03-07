# Main Cluster Class
class ClusterShell
    def self.configure(config, settings)
    # 配置本地脚本目录变量
        script_dir = File.dirname(__FILE__)
		settings['vms'].each do |vms|
			active = vms['active'] ||= true

			if active == false
				next
			end

            if vms.include? 'name'
                config.vm.define vms['name'] do |machine|
                    machine.vm.define vms['name'] ||= 'cluster'
                    machine.vm.box = vms['box'] ||= 'peru/ubuntu-20.04-server-amd64'
                    machine.vm.hostname = vms['name'] ||= 'cluster'

                    machine.vm.provider 'virtualbox' do |vb|
                        vb.name = vms['name'] ||= 'cluster'
                        vb.cpus = vms['cpus'] ||= '1'
                        vb.memory = vms['memory'] ||= '1024'
                        vb.gui = false
                        if vms.has_key?('gui') && vms['gui']
                            vb.gui = true
                        end
                    end

                    if vms['ip'] != 'autonetwork'
                        machine.vm.network :private_network, ip: vms['ip'] ||= '192.168.10.10'
                    else
                        machine.vm.network :private_network, ip: '0.0.0.0', auto_network: true
                    end

                    if vms.has_key?('default_ssh_port')
                        machine.vm.network 'forwarded_port', guest: 22, host: vms['default_ssh_port'], auto_correct: false, id: "ssh"
                    end

                    if vms.has_key?('ports')
                        vms['ports'].each do |port|
                            machine.vm.network 'forwarded_port', guest: port['to'], host: port['send'], protocol: port['protocol'] ||= 'tcp' , auto_correct: true
                        end
                    end

                    if vms.include? 'copy'
                        vms['copy'].each do |file|
                            machine.vm.provision 'file' do |f|
                                f.source = File.expand_path(file['from'])
                                f.destination = file['to'].chomp('/') + '/' + file['from'].split('/').last
                            end
                        end
                    end

                    if vms.include? 'folders'
                        vms['folders'].each do |folder|
                            if File.exist? File.expand_path(folder['map'])
                                machine.vm.synced_folder folder['map'], folder['to']
                            else
                                machine.vm.provision 'shell' do |s|
                                    s.inline = ">&2 echo \"Unable to mount one of your folders. Please check your folders in Cluster.yaml\""
                                end
                            end
                        end
                    end

                    machine.vm.provision "shell", inline: "mkdir -p /home/vagrant/.features"
                    machine.vm.provision "shell", inline: "chown -Rf vagrant:vagrant /home/vagrant/.features"

                    machine.vm.provision 'shell' do |s|
                        s.path = script_dir + '/change-software-source.sh'
                        s.args = [settings['source'] ||= 'https://mirrors.aliyun.com/ubuntu']
                    end

                    if vms.has_key?('features')
                        vms['features'].each do |feature|
                            feature_path = script_dir + "/features/" + feature + ".sh"

                            if !File.exist? File.expand_path(feature_path)
                                machine.vm.provision "shell", inline: "echo Invalid feature: #{feature_name} \n"
                                next
                            end

                            machine.vm.provision "shell" do |s|
                                s.name = "Installing " + feature
                                s.path = feature_path
                            end
                        end
                    end

                    if vms.has_key?('services')
                        vms['services'].each do |service|
                            if service.include?('enabled')
                                service['enabled'].each do |enable_service|
                                    machine.vm.provision "shell", inline: "sudo service enable #{enable_service}"
                                    machine.vm.provision "shell", inline: "sudo service start #{enable_service}"
                                end
                            end

                            if service.include?('disabled')
                                service['disabled'].each do |disable_service|
                                    machine.vm.provision "shell", inline: "sudo service disable #{disable_service}"
                                    machine.vm.provision "shell", inline: "sudo service stop #{disable_service}"
                                end
                            end
                        end
                    end

                    if vms.include? 'proxys'
                        vms['proxys'].each do |proxy|
                        	proxys = ''
                        	proxy['sites'].each do |site|
                        	    machine.vm.provision 'shell' do |s|
                                   s.path = script_dir + "/hosts-add.sh"
                                   s.args = [site['to'], site['map']]
                                end

                                weight = site['weight'] ||= "1"
                                proxys += 'server ' + site['map'] + ' weight=' + weight + ';'
                        	end

                            machine.vm.provision 'shell' do |s|
                                s.name = 'Load balancing:' + proxys
                                s.path = script_dir + '/create-nginx.sh'
                                s.args = [proxy['map'], proxys]
                            end
                        end
                    end

                    if vms.include? 'sites'
                        machine.vm.provision 'shell' do |s|
                            s.path = script_dir + '/clear-apache.sh'
                        end

                        machine.vm.provision 'shell' do |s|
                            s.path = script_dir + '/hosts-reset.sh'
                        end

                        site_default = false

                        vms['sites'].each do |site|
                            if site_default == false and site['default'] == true
		                        default = 'true'
		                        site_default = true
	                        end

                            machine.vm.provision 'shell' do |s|
                                s.name = 'Creating Site: ' + site['map']
                                if site.include? 'params'
                                    params = '('
                                    site['params'].each do |param|
                                        params += ' [' + param['key'] + ']=' + param['value']
                                    end
                                    params += ' )'
                                end

                                if site.include? 'headers'
                                    headers = '('
                                    site['headers'].each do |header|
                                        headers += ' [' + header['key'] + ']=' + header['value']
                                    end
                                    headers += ' )'
                                end

                                if site.include? 'rewrites'
                                    rewrites = '('
                                    site['rewrites'].each do |rewrite|
                                        rewrites += ' [' + rewrite['map'] + ']=' + "'" + rewrite['to'] + "'"
                                    end
                                    rewrites += ' )'
                                    rewrites.gsub! '$', '\$'
                                end

                                s.path = script_dir + "/create-apache.sh"
                                s.args = [
                                    site['map'],                # $1
                                    site['to'],                 # $2
                                    site['port'] ||= '80',      # $3
                                    site['ssl'] ||= '443',      # $4
                                    site['php'] ||= '7.4',      # $5
                                    params ||= '',              # $6
                                    site['xhgui'] ||= '',       # $7
                                    site['exec'] ||= 'false',   # $8
                                    headers ||= '',             # $9
                                    rewrites ||= '',            # $10
                                    default ||= 'false',        # $11
                                    site['alias'] ||= '',       # $12
                                ]
                            end

                            machine.vm.provision 'shell' do |s|
                                s.path = script_dir + "/hosts-add.sh"
                                s.args = ['127.0.0.1', site['map']]
                            end

                            if site.has_key?('schedule')
                                machine.vm.provision 'shell' do |s|
                                    s.name = 'Creating Schedule'

                                    if site['schedule']
                                        s.path = script_dir + '/cron-schedule.sh'
                                        s.args = [site['map'].tr('^A-Za-z0-9', ''), site['to']]
                                    else
                                        s.inline = "sudo rm -f /etc/cron.d/$1"
                                        s.args = [site['map'].tr('^A-Za-z0-9', '')]
                                    end
                                end
                            else
                                machine.vm.provision 'shell' do |s|
                                    s.name = 'Checking for old Schedule'
                                    s.inline = "sudo rm -f /etc/cron.d/$1"
                                    s.args = [site['map'].tr('^A-Za-z0-9', '')]
                                end
                            end
                        end
                    end

                    machine.vm.provision 'shell' do |s|
                        s.name = 'Restarting Cron'
                        s.inline = 'sudo service cron restart'
                    end

                    if vms.has_key?('databases')
                        enabled_databases = Array.new
                        if vms.has_key?('features')
                            vms['features'].each do |feature|
                                enabled_databases.push feature
                            end
                        end

                        vms['databases'].each do |db|
                            if enabled_databases.include? 'mysql8'
                                machine.vm.provision 'shell' do |s|
                                    s.name = 'Creating MySQL Database: ' + db
                                    s.path = script_dir + '/create-mysql.sh'
                                    s.args = [db]
                                end
                            end
                        end
                    end

                    if vms.has_key?('backup') && vms['backup'] && (Vagrant::VERSION >= '2.1.0' || Vagrant.has_plugin?('vagrant-triggers'))
                        dir_prefix = '/vagrant/'
                        vms['databases'].each do |database|
                            ClusterShell.backup_mysql(database, "#{dir_prefix}/mysql_backup", machine)
                            ClusterShell.backup_postgres(database, "#{dir_prefix}/postgres_backup", machine)
                        end
                    end

                end
			else
				puts 'Check your .yaml file, you have no name specified'
				exit
			end
	    end
  end

  def self.backup_mysql(database, dir, config)
    now = Time.now.strftime("%Y%m%d%H%M")
    config.trigger.before :destroy do |trigger|
      trigger.warn = "Backing up mysql database #{database}..."
      trigger.run_remote = {inline: "mkdir -p #{dir}/#{now} && mysqldump --routines #{database} > #{dir}/#{now}/#{database}-#{now}.sql"}
    end
  end

  def self.backup_postgres(database, dir, config)
    now = Time.now.strftime("%Y%m%d%H%M")
    config.trigger.before :destroy do |trigger|
      trigger.warn = "Backing up postgres database #{database}..."
      trigger.run_remote = {inline: "mkdir -p #{dir}/#{now} && echo localhost:5432:#{database}:homestead:secret > ~/.pgpass && chmod 600 ~/.pgpass && pg_dump -U homestead -h localhost #{database} > #{dir}/#{now}/#{database}-#{now}.sql"}
    end
  end
end