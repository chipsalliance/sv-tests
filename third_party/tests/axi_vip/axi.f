# Compile list for axi
#project defines
+define+ID_WIDTH=16
+define+ADDR_WIDTH=64
+define+BYTE_WIDTH=32
+define+USER_WIDTH=4
#folder includes
+incdir+./modules/vip/axi/tests
+incdir+./common/sim/vip_lib/sys_uvc
+incdir+./common/sim/vip_lib/axi_uvc
+incdir+./common/sim/shared
+incdir+./modules/vip/axi
+incdir+./modules/vip/axi/env
+incdir+./modules/vip/axi/sequences
#RTL sverilog files
./common/sim/vip_lib/sys_uvc/sys_if.sv
./common/sim/vip_lib/sys_uvc/sys_uvc_pkg.sv
./common/sim/vip_lib/axi_uvc/axi_if.sv
./common/sim/vip_lib/axi_uvc/axi_agent_pkg.sv
./common/sim/shared/timescale.sv
./common/sim/shared/common_pkg.sv
./modules/vip/axi/env/axi_env_pkg.sv
./modules/vip/axi/sequences/axi_seq_pkg.sv
./modules/vip/axi/axi_tb_top.sv
./modules/vip/axi/tests/axi_test_pkg.sv
./common/sim/shared/test_initiator.sv
#Verification sverilog files
#IP files
