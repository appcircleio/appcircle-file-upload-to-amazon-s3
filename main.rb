require 'open3'
require 'os'

def get_env_variable(key)
	return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

ac_aws_access_key_id = get_env_variable("AWS_ACCESS_KEY_ID") || abort('Missing aws access key id.')
ac_aws_secret_access_key = get_env_variable("AWS_SECRET_ACCESS_KEY") || abort('Missing aws secret key.')
ac_aws_bucket_name = get_env_variable("AWS_BUCKET_NAME") || abort('Missing bucket name.')
ac_input_file_path = get_env_variable("AC_INPUT_FILE_PATH") || abort('Missing the file path to be uploaded.')
ac_aws_bucket_region = get_env_variable("AWS_BUCKET_REGION") || "us-east-1"

def run_command(command)
    puts "@@[command] #{command}"
    unless system(command)
      exit $?.exitstatus
    end
end

AWS_DOWNLOAD_URL_FOR_LINUX = "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
AWS_DOWNLOAD_URL_FOR_MACOS = "https://awscli.amazonaws.com/AWSCLIV2.pkg"

if OS.mac?
	run_command("curl #{AWS_DOWNLOAD_URL_FOR_MACOS} -o \"AWSCLIV2.pkg\"")
	run_command("sudo installer -pkg AWSCLIV2.pkg -target /")
else
	run_command("curl #{AWS_DOWNLOAD_URL_FOR_LINUX} -o \"awscliv2.zip\"")
	run_command("unzip awscliv2.zip && ./aws/install")
end

timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
aws3_upload_url = "s3://#{ac_aws_bucket_name}/#{timestamp}"
run_command("aws s3 cp #{ac_input_file_path} #{aws3_upload_url}")

#Write Environment Variable
open(ENV['AC_ENV_FILE_PATH'], 'a') { |f|
  f.puts "AC_AWS_UPLOAD_URL=#{aws3_upload_url}"
}

exit 0