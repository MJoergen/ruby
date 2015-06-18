require 'ffi'

module Geom
    extend FFI::Library
    #ffi_lib "C:/Users/Lucas/Desktop/rubytest/libgeom.dll"
    #DLL = File.expand_path("libgeom.dll", File.dirname(__FILE__))
	#ffi_lib "#{DLL}"
	ffi_lib "libgeom"
	attach_function :point_in_rectangle, [:float, :float, :float, :float, :float, :float], :int
    attach_function :point_side_of_line, [:float, :float, :float, :float, :float, :float], :float
    attach_function :collision_line_segment_box, [:float, :float, :float, :float, :float, :float, :float, :float], :int
    attach_function :collision_radius_to_line_segment, [:float, :float, :float, :float, :float, :float, :float], :int
    attach_function :collision_box_line_with_radius, [:float, :float, :float, :float, :float, :float, :float, :float, :float], :int
	attach_function :dist2, [:float, :float, :float, :float], :float
	attach_function :collision_circle_box, [:float, :float, :float, :float, :float, :float, :float], :int
end

