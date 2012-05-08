#!/usr/bin/ruby

# Encrypted note
# requires ruby 1.8.7 with openssl support
# Start adding your note to the end of the file after the __END__ 

require 'openssl'

ALGO = 'AES256'

data = DATA.read.split("\n")
cipher = OpenSSL::Cipher.new ALGO

def get_password()
	puts "enter password: "
	system 'stty -echo'
	pass = gets
	system 'stty echo'
	OpenSSL::Digest::SHA512.new(pass.chomp).digest
end

if data[0] == '!!enc_note'
	# decrypt
	puts "Decrypting"
	cipher.send :decrypt
	cipher.key = get_password
	message = cipher.update(data[1]) << cipher.final
	puts "Encrypted message:\n\n"
	puts message
	exit
end

# encrypt the note
orig = File.read(__FILE__).split("\n")
eof = 0
orig.each_with_index {|l,i| eof = i if l == "__END__" }
out_data = orig.slice(0..eof)
out_data[eof+1] = "!!enc_note"

# encrypt the string w/ a password
puts "Encrypting.."
cipher.send :encrypt
cipher.key = get_password
out_data[eof+2] = cipher.update(data.join("\n")) << cipher.final

File.open(__FILE__,'w') do |f|
	f.write(out_data.join("\n"))
end

__END__
to be encrypted