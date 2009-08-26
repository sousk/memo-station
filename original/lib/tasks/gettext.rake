require "gettext/utils"

task :update_po do
  GetText.update_pofiles("memo_station", Dir.glob("app/**/*.{rb,rhtml}"), "memo_station 1.0.0")
end

task :make_mo do
  GetText.create_mofiles(true, "po", "locale")
end
