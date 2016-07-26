Puppet::Type.type(:package).provide(:brew,
                                    :parent => :brewcommon,
                                    :source => :brewcommon) do
  desc 'Package management using HomeBrew on OS X'

  has_feature :install_options

  def install
    name = install_name
    output = execute([command(:brew), :install, name, *install_options])

    if output =~ /Searching taps/
      raise Puppet::ExecutionFailure, "Could not find package #{name}"
    end

    if output =~ /sha256 checksum/
      mismatched = output.match(/Already downloaded: (.*)/).captures
      fix_checksum(mismatched)
    end
  end

  def uninstall
    execute([command(:brew), :uninstall, @resource[:name]])
  end

  def update
    execute([command(:brew), :upgrade, @resource[:name]])
  end

  def self.package_list(options={})
    begin
      if name = options[:justme]
        result = execute([command(:brew), :list, '--versions', name])
      else
        result = execute([command(:brew), :list, '--versions'])
      end

      if result.split.first == 'Warning:' or result.split.first == 'Error:'
        lines = []
      else
        lines = result.lines
      end

      list = lines.map {|line| name_version_split(line)}
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list packages: #{detail}"
    end

    if options[:justme]
      return list.shift
    else
      return list
    end
  end

  def self.name_version_split(line)
    if line =~ (/^(\S+)\s+(.+)/)
      {
        :name     => $1,
        :ensure   => $2,
        :provider => :brew
      }
    else
      Puppet.warning "Could not match #{line}"
      nil
    end
  end
end
