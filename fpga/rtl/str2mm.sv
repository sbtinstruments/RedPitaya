////////////////////////////////////////////////////////////////////////////////
// (c) Red Pitaya  http://www.redpitaya.com
////////////////////////////////////////////////////////////////////////////////

module str2mm #(
  type DT = logic signed [16-1:0],
  int unsigned DN = 1,
  int unsigned DL = 1<<14
)(
  // stream input
  axi4_stream_if.s str,
  // System bus
  sys_bus_if.s     bus
);

localparam int unsigned AW = $clog2(DL);

// memory
DT             buf_dat [0:DL-1];
// write port
logic          buf_wen;
logic [AW-1:0] buf_wad;

////////////////////////////////////////////////////////////////////////////////
// write
////////////////////////////////////////////////////////////////////////////////

assign buf_wen = str.TVALID & str.TREADY;

assign str.TREADY = 1;

always @(posedge str.ACLK)
if (~str.ARESETn) begin
  buf_wad <= '0;
end else if (buf_wen) begin
  if (str.TLAST)  buf_wad <= '0;
  else            buf_wad <= buf_wad + 1;
end

always @(posedge str.ACLK)
if (buf_wen) begin
   buf_dat [buf_wad] <= str.TDATA;
end

////////////////////////////////////////////////////////////////////////////////
// read
////////////////////////////////////////////////////////////////////////////////

always @(posedge bus.clk)
if (bus.ren) begin
  for (int unsigned i=0; i<2; i++) begin
    bus.rdata [16*i+:16] <= buf_dat [{bus.addr>>2,i[0]}];
  end
end

always @(posedge bus.clk)
if (~bus.rstn) begin
  bus.err <= 1'b0;
  bus.ack <= 1'b0;
end else if (bus.wen | bus.ren) begin
  bus.ack <= 1'b1;
end

endmodule: str2mm