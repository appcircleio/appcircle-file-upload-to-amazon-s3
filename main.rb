require 'open3'
require 'os'
require 'shellwords'

def get_env_variable(key)
	return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

ac_aws_access_key_id = get_env_variable("AWS_ACCESS_KEY_ID") || abort('Missing aws access key id.')
ac_aws_secret_access_key = get_env_variable("AWS_SECRET_ACCESS_KEY") || abort('Missing aws secret key.')
ac_aws_bucket_name = get_env_variable("AWS_BUCKET_NAME") || abort('Missing bucket name.')
ac_input_file_path = get_env_variable("AC_INPUT_FILE_PATH") || abort('Missing the file path to be uploaded.')
ac_aws_bucket_region = get_env_variable("AWS_BUCKET_REGION") || "us-east-1"
ac_aws_target_dir = get_env_variable("AWS_TARGET_DIR")
ac_aws_endpoint_url = get_env_variable("AWS_ENDPOINT_URL_S3")
ac_aws_cli_base_url = (get_env_variable("AC_AWS_CLI_BASE_URL") || "https://awscli.amazonaws.com").chomp("/")
abort('AC_AWS_CLI_BASE_URL must start with http:// or https://') unless ac_aws_cli_base_url.match?(%r{\Ahttps?://})

AWS_CLI_FILE_FOR_LINUX = "awscli-exe-linux-x86_64.zip"
AWS_CLI_FILE_FOR_MACOS = "AWSCLIV2.pkg"
# Team ID of the Developer ID Installer certificate that signs the AWS CLI macOS package
AWS_CLI_SIGNING_TEAM_ID = "94KV3E626L"

def run_command(command)
    puts "@@[command] #{command}"
    unless system(command)
      exit $?.exitstatus
    end
end

# The base URL may point to an artifact proxy, so the package is installed only if AWS signed it.
def verify_pkg_signature(pkg_path)
	output, status = Open3.capture2e("pkgutil", "--check-signature", pkg_path)
	unless status.success? && output.match?(/^\s*1\. Developer ID Installer: .*\(#{AWS_CLI_SIGNING_TEAM_ID}\)$/)
		puts output
		abort("#{pkg_path} is not signed by the AWS CLI publisher (team ID #{AWS_CLI_SIGNING_TEAM_ID}).")
	end
	puts "Package signature verified (team ID #{AWS_CLI_SIGNING_TEAM_ID})"
end

def install_aws_cli(base_url)
	system("aws --version")
	if $?.success?
		return
	end

	if OS.mac?
		run_command("curl -fsSL --retry 3 #{Shellwords.escape("#{base_url}/#{AWS_CLI_FILE_FOR_MACOS}")} -o \"AWSCLIV2.pkg\"")
		verify_pkg_signature("AWSCLIV2.pkg")
		run_command("sudo installer -pkg AWSCLIV2.pkg -target /")
	else
		run_command("curl -fsSL --retry 3 #{Shellwords.escape("#{base_url}/#{AWS_CLI_FILE_FOR_LINUX}")} -o \"awscliv2.zip\"")
		run_command("unzip awscliv2.zip && ./aws/install")
	end
end

install_aws_cli(ac_aws_cli_base_url)
if(ac_aws_target_dir.nil?)
	ac_aws_target_dir = Time.now.utc.strftime("%Y%m%d%H%M%S")
end

aws3_upload_url = "s3://#{ac_aws_bucket_name}/#{ac_aws_target_dir}/"
upload_command = "aws s3 cp #{ac_input_file_path} #{aws3_upload_url} --region #{Shellwords.escape(ac_aws_bucket_region)}"
# Passed explicitly as well, since AWS CLI reads AWS_ENDPOINT_URL_S3 from the environment only from 2.13 on
upload_command += " --endpoint-url #{Shellwords.escape(ac_aws_endpoint_url)}" unless ac_aws_endpoint_url.nil?

if Dir.exist?("#{ac_input_file_path}")
	upload_command += " --recursive"
end

run_command(upload_command)

#Write Environment Variable
open(ENV['AC_ENV_FILE_PATH'], 'a') { |f|
  f.puts "AC_AWS_UPLOAD_URL=#{aws3_upload_url}"
}

exit 0