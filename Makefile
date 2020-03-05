.PHONY: binary image

binary:
	ruby build/binary.rb

image: binary
	ruby build/image.rb
