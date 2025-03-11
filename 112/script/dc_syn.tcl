set top LASER

#Read All Files
#read_file -autoread -top ${top} -recursive {../src} -library ${top}
read_file -format verilog  ../src/${top}.v
current_design [get_designs ${top}]
link

#Setting Clock Constraints
source -echo -verbose ../script/${top}.sdc
check_design
set high_fanout_net_threshold 0
uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
#set_max_area 0
#Synthesis all design
compile -map_effort high -area_effort high
#compile -map_effort high -area_effort high -inc
compile_ultra

write -format ddc -hierarchy -output "${top}_syn.ddc"
write_file -format verilog -hierarchy -output ../syn/${top}_syn.v
write_sdf -version 2.0 -context verilog  ../syn/${top}_syn.sdf
write_sdc -version 2.0 ${top}.sdc
report_area > area.log
report_timing > timing.log
report_qor > ${top}_syn.qor
