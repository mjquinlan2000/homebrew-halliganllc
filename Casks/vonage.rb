cask "vonage" do
  version :latest
  sha256 :no_check

  language "en", default: true do
    "en_US"
  end

  url "https://vbc-downloads.vonage.com/mac/VonageBusinessSetup.dmg", 
    user_agent: :fake, 
    verified: "vbc-downloads.vonage.com/"

  name "Vonage Business"
  desc "Vonage Business Desktop Application"
  homepage "https://www.vonage.com/"

  container type: :naked

  preflight do
    mount_point = staged_path/"mount"
    
    dmg = staged_path/"VonageBusinessSetup.dmg"
    
    # 1. Force-decompress even though suffix is .dmg
    system_command "/usr/bin/gunzip",
                   args: ["-S", ".dmg", dmg.to_s]

    # gunzip strips the suffix; add it back so hdiutil is happy
    system_command "/bin/mv",
                   args: [staged_path/"VonageBusinessSetup", dmg.to_s]

    # 2. Mount the now-real DMG
    system_command "/usr/bin/hdiutil",
                   args: ["attach", "-mountpoint", mount_point, "-nobrowse", dmg.to_s]

    # Move the app to the staging directory. Vonage sucks
    system_command "/usr/bin/ditto",
               args: ["#{mount_point}/Vonage Business.app",
                      staged_path/"Vonage Business.app"]
end
  
  app "Vonage Business.app"

  postflight do
    mount_point = staged_path/"mount"

    # detach the volume (ignore errors if it’s already gone)
    system_command "/usr/bin/hdiutil",
                   args: ["detach", mount_point], must_succeed: false
  end

  auto_updates true
  

  zap trash: [
    "~/Library/Application Support/Vonage Business",
    "~/Library/Preferences/com.vonage.vbc.plist"
  ]
end
