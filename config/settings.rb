module Peas
  # Synchronise API version with CLI version (controversial. may need to revisit this decision)
  VERSION = File.read(File.expand_path("../../cli/VERSION", __FILE__)).strip

  # The most recent version of Docker against which Peas has been tested.
  # Remember to change the version in the DOCKERFILE too.
  DOCKER_VERSION = '1.3.0'

  # Location of Docker socket, used by Remote API
  DOCKER_SOCKET = 'unix:///var/run/docker.sock'

  # Figure out if we're running inside a docker container.
  DIND = begin
    !File.open('/proc/self/cgroup').read.match(/docker/).nil?
  end

  GIT_USER = Peas::DIND ? 'git' : 'peas'

  # Peas base path for temp files
  TMP_BASE = '/tmp/peas'

  # Path to tar repos into before sending to buildstep
  TMP_TARS = "#{TMP_BASE}/tars"

  # Path to receive repos for deploying
  APP_REPOS_PATH = DIND ? "/home/git" : "#{TMP_BASE}/repos"

  # See self.domain() for more info
  # 'vcap.me' is managed by Cloud Foundry and has wildcard resolution to 127.0.0.1
  CONTROLLER_DOMAIN = ENV['PEAS_HOST'] || 'vcap.me'

  # The publicly accessible address for the pod. Only relevant if we're running as a pod of course
  POD_HOST = ENV['DIND_HOST'] || 'localhost'

  # Port on which the messaging server runs
  SWITCHBOARD_PORT = ENV['SWITCHBOARD_PORT'] || 9345

  # Port for the proxy server
  PROXY_PORT = ENV['PEAS_PROXY_PORT'] || '80'

  # Port for the Peas API. Possibly conflicts with value from Settings model, 'peas.domain'
  API_PORT = ENV['PEAS_API_PORT'] || '443'

  # Root path of the project on the host filesystem
  ROOT_PATH = File.join(File.dirname(__FILE__), "../")

  # SSL key
  SSL_KEY_PATH = "#{ROOT_PATH}/contrib/ssl-keys/server.key"
  SSL_KEY = OpenSSL::PKey::RSA.new File.read(SSL_KEY_PATH)

  # SSL certificate
  SSL_CERT_PATH = "#{ROOT_PATH}/contrib/ssl-keys/server.crt"
  SSL_CERT = OpenSSL::X509::Certificate.new File.read(SSL_CERT_PATH)

  # Alias for ROOT_PATH
  def self.root
    ROOT_PATH
  end

  # Environment, normally one of: 'production', 'development', 'test'
  def self.environment
    ENV['PEAS_ENV'] || 'production'
  end

  # Used for lots of things.
  # 1) REST API
  # 2) SWITCHBOARD
  # 3) MongoDB (so pods can also access the DB)
  # 4) By builder to create the FQDN for an app; eg http://mycoolapp.peasserver.com
  # Note that only 4) is effected by changing the :domain key in the Setting model
  def self.domain
    uri = Setting.retrieve 'peas.domain'
    # Ensure URI begins with a protocol to enable parsing
    uri = "https://#{uri}" unless uri[/\Ahttp:\/\//] || uri[/\Ahttps:\/\//]
    parsed = URI.parse uri
    # Make sure there's no port at the end
    "https://#{parsed.host}"
  end

  # Returns only the host part of the Peas domain. Eg; 'vcap.me' from http://vcap.me:4000
  def self.host
    URI.parse(Peas.domain).host
  end

  def self.switchboard_server_uri
    "#{Peas.host}:#{SWITCHBOARD_PORT}"
  end

  # Unless otherwise stated, Peas will function in a standalone state of being both the controller and a pod.
  # Is this instance of Peas functioning as a controller?
  def self.controller?
    ENV['PEAS_CONTROLLER'] == 'false' ? false : true
  end

  # Is this instance of Peas functioning as a pod?
  def self.pod?
    ENV['PEAS_POD'] == 'false' ? false : true
  end

  # Introspect the lib/services folder to find the available classes that allow the management
  # of services like redis, memcached, etc
  def self.available_services
    Peas::Services.constants.select { |c|
      constant = Peas::Services.const_get(c)
      constant.is_a?(Class) && constant != Peas::Services::ServicesBase
    }.map { |s|
      s.to_s.downcase
    }
  end

  # Available services that also have an admin connection URI set
  def self.enabled_services
    Peas.available_services.select { |service|
      Setting.where(key: "#{service}.uri").count == 1
    }
  end

  def self.logger
    output = Peas.environment == 'test' ? '/dev/null' : STDOUT
    @logger ||= Logger.new output
  end
end
