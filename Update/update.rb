# encoding: utf-8
# ==============================================================================
# GitHub 自动更新
# ------------------------------------------------------------------------------
# Author: guoxiaomi
# ==============================================================================
require "win32api" if not defined? Win32API

module GitHub_Update
  Owner = "你的Github用户名"
  Repo = "你的仓库名"
  Version = "版本号（v开头）"
end

module GitHub_Update
  Folder = "Update"
  if !FileTest.exist?("#{Folder}/dl")
    Dir.mkdir("#{Folder}/dl")
  end

  Release_Url = "https://api.github.com/repos/#{Owner}/#{Repo}/releases/latest"
  Patch_Url = "https://github.com/#{Owner}/#{Repo}/compare/__OLD__...__NEW__.patch"
  Release_Path = "#{Folder}/dl/latest_release.json"
  Patch_Path = "#{Folder}/dl/__OLD__...__NEW__.patch"

  URLDownloadToFile = Win32API.new("Urlmon", "URLDownloadToFile", "ippii", "i")

  module_function

  def version
    @old_tag = Version
    begin
      URLDownloadToFile.call(0, Release_Url, Release_Path, 0, 0)
      ret = File.read(Release_Path).force_encoding("utf-8")
      @new_tag = ret.scan(/"tag_name":\s*"(.+?)"/)[0][0]
    rescue
      @new_tag = @old_tag
    end
    return @old_tag, @new_tag
  end

  def update
    return if @old_tag == @new_tag
    File.open("#{Folder}/dl/update.cmd", "w") do |f|
      f.puts update_cmd
    end
    exec("start #{Folder}\\dl\\update.cmd")
  end

  def update_cmd
    cmd = ""
    cmd += "set PATH=.\\#{Folder};%PATH%\n"
    cmd += "aria2c --allow-overwrite -o #{Patch_Path} #{Patch_Url}\n"
    cmd += "git-apply #{Patch_Path}\n"
    cmd += "start game.exe\n"
    cmd += "exit\n"
    return cmd.gsub("__OLD__", @old_tag).gsub("__NEW__", @new_tag)
  end
end
