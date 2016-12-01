records = Dir.glob("app/assets/images/carriers/larger/*")
NonStupidDigestAssets.whitelist += records.map {|el| el.gsub("app/assets/images/", "")}