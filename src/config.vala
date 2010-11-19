/*
 * config.vala
 *
 * Copyright (c) 2010 Eduardo Niehues
 * Distributed under the New BSD License; see ../LICENSE for details.
 */
using Gee;
namespace XSIRC {
	public class ConfigManager : Object {
		public HashMap<string,HashMap<string,string>> config = new HashMap<string,HashMap<string,string>>();
		private KeyFile raw_file = new KeyFile();
		public bool loaded_config = false;
		
		public ConfigManager() {
			config["core"] = new HashMap<string,string>();
			// Some default config options
			config["core"]["nickname"]    = Environment.get_user_name();
			config["core"]["username"]    = Environment.get_user_name();
			config["core"]["realname"]    = Environment.get_user_name();
			config["core"]["quit_msg"]    = "Leaving";
			config["core"]["web_browser"] = "firefox %s";
			config["core"]["font"]        = "Monospace 10";
			config["core"]["timestamp_format"] = "[%H:%M:%S]";
			config["core"]["away_msg"]    = "Away";
			config["core"]["log_date_format"] = "%F";
			config["core"]["log"]         = "true";
			
			if(FileUtils.test(Environment.get_user_config_dir()+"/xsirc/xsirc.conf",FileTest.EXISTS)) {
				try {
					raw_file.load_from_file(Environment.get_user_config_dir()+"/xsirc/xsirc.conf",KeyFileFlags.KEEP_COMMENTS);
					loaded_config = true;
				} catch(KeyFileError e) {
					stderr.printf("Could not parse config file, using defaults\n");
				} catch(FileError e) {
					stderr.printf("Could not open config file\n");
				}
			}
			load_strings(config["core"],"XSIRC",{"nickname","username","realname","quit_msg","web_browser","font","timestamp_format","away_msg","log_date_format","log"});
			
		}
		
		private void load_strings(HashMap<string,string> hash_map,string section,string[] keys) {
			foreach(string key in keys) {
				try {
					if(raw_file.has_key(section,key)) {
						hash_map[key] = raw_file.get_string(section,key);
					}
				} catch(KeyFileError e) {
					stderr.printf("Could not get key %s in group %s\n",key,section);
				}
			}
		}
		
		private void save_strings(HashMap<string,string> map,string section) {
			foreach(string key in map.keys) {
				raw_file.set_string(section,key,map[key]);
			}
		}
		
		public void save_settings() {
			save_strings(config["core"],"XSIRC");
			try {
				FileUtils.set_contents(Environment.get_user_config_dir()+"/xsirc/xsirc.conf",raw_file.to_data());
			} catch(Error e) {
				stderr.printf("Error saving settings: %s\n",e.message);
			}
		}
	}
}
