.PHONY: binary image

image:
	ruby build/image.rb

binary:
	ruby build/binary.rb
