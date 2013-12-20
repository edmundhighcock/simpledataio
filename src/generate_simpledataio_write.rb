
class Generator
	def initialize(type, dimsize)
		@dimsize = dimsize
		@type = type
		if dimsize==0
		  @dimension = ""
		else
			@dimension = ", dimension(#{([":"]*dimsize).join(",")}) "
		end
	end
	def procedure_name
		"write_variable_#{@type.gsub(' ', '_')}_#{@dimsize}"
	end
	def function_string
		string = <<EOF
 subroutine #{procedure_name}(sfile, variable_name, val)
   use netcdf
	 use simpledataio
   type(sdatio_file), intent(in) :: sfile
   character(*), intent(in) :: variable_name
   #{@type}, intent(in)#{@dimension} :: val
   integer, dimension(:), allocatable :: starts, counts
   integer :: fileid, varid, status, n

   call number_of_unlimited_dimensions(sfile, variable_name, n)
   allocate(starts(n+#@dimsize))
   allocate(counts(n+#@dimsize))
   call netcdf_inputs(sfile, variable_name, fileid, varid, starts, counts)
   status =  nf90_put_var(fileid, varid+1, #{@dimsize == 0 ? "(/val/)" : "val"}, start=starts, count=counts)
   if (.not. status .eq. 0) write (*,*) 'Error writing variable: ', variable_name, ', ',  nf90_strerror(status)


 end subroutine #{procedure_name}
EOF
  end

end

generators = []
['real', 'double precision', 'integer', 'character'].each do |type|
	(0..6).each do |dimsize|
		generators.push Generator.new(type, dimsize)
	end
end

string = <<EOF

module simpledataio_write

interface write_variable
#{generators.map{|g| "  module procedure " + g.procedure_name}.join("\n")}
end interface write_variable

contains

#{generators.map{|g| g.function_string}.join("\n")}

end module simpledataio_write

EOF


puts string
