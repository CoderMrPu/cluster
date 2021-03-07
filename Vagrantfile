# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
expandPath = File.expand_path(File.dirname(__FILE__))
yamlPath = expandPath + "/Cluster.yaml"
require expandPath + "/scripts/cluster.rb"

Vagrant.configure("2") do |config|
    if File.exist? yamlPath then
        settings = YAML::load(File.read(yamlPath))
    else
        abort "Cluster.yaml file not found in #{expandPath}"
    end

    ClusterShell.configure(config, settings)
end
