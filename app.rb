require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/activerecord'
require 'json'

class App < Sinatra::Base

  register Sinatra::ActiveRecordExtension
  register Sinatra::Namespace

  set :show_exceptions, :after_handler
  set :bind, '0.0.0.0'
  set :port, 4321

  DOKKU_ROOT = '/home/dokku'
  AUTHORIZED_KEYS = DOKKU_ROOT + '/.ssh/authorized_keys'

  before do
    halt 401, {'Content-Type' => 'text/plain'}, 'Missing user' if request.env["HTTP_USER"].nil?
    content_type 'application/json'
    if request.media_type == 'application/json'
      body = request.body.read
      unless body.empty?
        @body = JSON.parse(body)
      end
    end
  end

  not_found do
    'Not Found'
  end

  error 400 do
    'Bad Request'
  end

  error 403 do
    'Access Forbidden'
  end

  namespace '/keys' do
    post '' do
      halt 400 if @body.nil? or @body['public_key'].nil?
      public_key = @body['public_key']
      response = {:public_key => public_key}
      key = `grep '#{public_key}' #{AUTHORIZED_KEYS} | grep FINGERPRINT= | grep NAME=`
      unless $?.exitstatus == 0
        response[:id] = SecureRandom.uuid
        response[:fingerprint] = `echo -n "#{public_key}" | sshcommand acl-add dokku #{id}`
        unless $?.exitstatus == 0
          halt 500
        end
      else
        response[:id] = /NAME=([^ ]*)/.match(key)[1]
        response[:fingerprint] = /FINGERPRINT=([^ ]*)/.match(key)[1]
      end
      response.to_json
    end

    delete '/:keyId' do
      id = params[:keyId]
      key = `grep 'NAME=#{id} ' #{AUTHORIZED_KEYS}`
      response = {}
      if $?.exitstatus == 0
        response[:id] = id;
        response[:fingerprint] = /FINGERPRINT=([^ ]*)/.match(key)[1]
        response[:public_key] = /command="[^"]*"[^ ]* (.*)$/.match(key)[1]
        `sshcommand acl-remove dokku #{id}`
        unless $?.exitstatus == 0
          halt 500
        end
      end
      response.to_json
    end

    get '/:keyId' do
      id = params[:keyId]
      key = `grep 'NAME=#{id} ' #{AUTHORIZED_KEYS}`
      response = {}
      if $?.exitstatus == 0
        response[:id] = id;
        response[:fingerprint] = /FINGERPRINT=([^ ]*)/.match(key)[1]
        response[:public_key] = /command="[^"]*"[^ ]* (.*)$/.match(key)[1]
      end
      response.to_json
    end

    get '' do
      keys = `grep 'command="' #{AUTHORIZED_KEYS} | grep FINGERPRINT= | grep NAME=`
      keys.split("\n").map do |key|
        {
            :id => /NAME=([^ ]*)/.match(key)[1],
            :public_key => /command="[^"]*"[^ ]* (.*)$/.match(key)[1],
            :fingerprint => /FINGERPRINT=([^ ]*)/.match(key)[1]
        }
      end.to_json
    end
  end

  namespace '/apps' do
    get '' do
      `dokku apps | tail -n +2`.split("\n").map {|name| {:name => name}}.to_json
    end

    post '' do
      halt 400 if @body.nil? or @body['name'].nil?
      app = @body['name']
      `dokku apps:create "#{app}"`
      halt 500 unless $?.exitstatus == 0
      {:name => app}.to_json
    end

    get '/:appName' do
      app = params[:appName]
      url = `dokku url "#{app}"`
      response = {}
      if $?.exitstatus == 0
        containerPath = DOKKU_ROOT + "/#{app}/CONTAINER"
        ipPath = DOKKU_ROOT + "/#{app}/IP"
        portPath = DOKKU_ROOT + "/#{app}/PORT"
        response[:id] = File.open(containerPath).readlines.join[0...12] if File.exists?(containerPath)
        response[:ip] = File.open(ipPath).readlines.join.strip! if File.exists?(ipPath)
        response[:port] = File.open(portPath).readlines.join.strip! if File.exists?(portPath)
        response[:url] = url.strip! || url
      end
      response.to_json
    end

    delete '/:appName' do
      `dokku apps:destroy "#{params[:appName]}" << EOF\n#{params[:appName]}\nEOF`
      halt 500 unless $?.exitstatus == 0
      {:name => params[:appName]}.to_json
    end

    post '/:appName/deploy' do
      `dokku deploy "#{params[:appName]}"`
      halt 500 unless $?.exitstatus == 0
      {:name => params[:appName]}.to_json
    end

    get '/:appName/config' do
      app = params[:appName]
      config = {}
      `dokku config #{app} | tail -n +2`.split("\n").map do |var|
        key = /([^:]+):/.match(var)[1] if /[^:]+:/ =~ var
        unless key.nil?
          config[key] = /[^:]+:[ ]*(.*)$/.match(var)[1]
        end
      end
      config.to_json
    end

    post '/:appName/config' do
      config = {}
      unless @body.nil?
        @body.each do |k, v|
          if /^[a-zA-Z0-9_]+$/ =~ k
            `dokku config:set "#{params[:appName]}" #{k}="#{v}"`
            config[k] = v if $?.exitstatus == 0;
          end
        end
      end
      config.to_json
    end

    delete '/:appName/config/:key' do
      response = {}
      if /^[a-zA-Z0-9_]+$/ =~ params[:key]
        `dokku config:unset "#{params[:appName]}" #{params[:key]}`
        response[:key] = params[:key] if $?.exitstatus == 0
      end
      response.to_json
    end

    get '/:appName/domains' do
      `dokku domains "#{params[:appName]}" | tail -n +2`.split("\n").map {|domain| {:domain => domain}}.to_json
    end

    get '/:appName/logs' do
      content_type 'text/plain'
      app = params[:appName]
      lines = 100
      lines = params[:lines].to_i unless params[:lines].nil? or params[:lines].to_i == 0
      `dokku logs "#{app}" 2>&1 | tail -n #{lines}`
    end

  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
