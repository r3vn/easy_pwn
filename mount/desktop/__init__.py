import subprocess

def check():
	bashCommand = "echo testoutputbash"

	process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
	output, error = process.communicate()

	return output