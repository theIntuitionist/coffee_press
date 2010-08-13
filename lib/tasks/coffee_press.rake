namespace :coffee do

  desc 'compile coffescript on save'
  task :press do

    read_file = lambda do |file_name| 
      file = File.new(file_name, "r")
      out = ""
      while (line = file.gets)
        out += line
      end
      file.close
      out
    end    

    read_error = lambda{ read_file.call('tmp/coffee.error') }



    out = 'starting compiler'
    loop do
      system('clear')
      puts out 
      out = "Compiling #{Time.now.to_s} \n"
      Dir.new('app/scripts/').each do |file_name|
        compiled_path = "public/javascripts/.#{file_name.gsub('.coffee','')}.compiled.js"
        js_path       = "public/javascripts/#{file_name.gsub('.coffee', '')}.js"

        if file_name.to_s.match(/.*coffee$/)
            # compile to scratch compiled js file
            system("coffee -p app/scripts/#{file_name} 2> tmp/coffee.error > #{compiled_path}")
            
            # only copy over to actual location if file differ (so that browser debugging won't be reset)
            if read_file.call(js_path) != read_file.call(compiled_path)
              system("cp #{compiled_path} #{js_path}")
              puts "wrote #{file_name} \n"
            end

            error_msg = (read_error.call || '').strip
            if error_msg.length > 0
              out += "  -- #{file_name} \n"
              out += "  -- errors: #{error_msg} \n"
              out += " \n"
              error_msg = error_msg.gsub(/\n/, '\n').gsub(/\\n/, '\n') # escape but put new lines back
              js_error_msg = "alert(\"#{error_msg}\")"
              js_file = file_name.gsub('coffee', 'js')
              if js_error_msg != read_file.call("public/javascripts/#{js_file}")  
                File.open("public/javascripts/#{js_file}", 'w') do |f| 
                  f.write(js_error_msg); f.close 
                end 
              end
              `rm tmp/coffee.error`
            end
        end
      end
      sleep 1
    end
  end

end
