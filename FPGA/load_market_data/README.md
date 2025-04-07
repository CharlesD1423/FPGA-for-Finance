# Instructions for loading project:

## Create a Block Memory (ROM)
- In Vivado, create a new project
- In IP Catalog, search for Block Memory Generator and double click
- In the "Basic" tab, select Single Port ROM.
- In "Port A Options", set Port A Width to 16, and Port A Depth to 1024.
- In the "Other Options" tab, select "Load Init File", and specify the location of the aapl_prices.coe file in src directory (from this repo).
- It might ask to generate output products -- hit Yes.
- I renamed it to prices_rom, so you will need to verify this in the project output.

## Load an ILA IP
- Search for ILA, or Integrated Logic Analyzer in the IP Catalog and double click.
- Set the number of Probes to 2.
- Probe0: Width = 10 (addr)
- Probe1: Width = 16 (prices)
- Click OK and generate output products.

## Add top.vhd from the src file.
- Double check that prices_rom and ila_0 match the IP core names.
  
## Run Synthesis -> Implementation -> Generate Bitstream

## Validate in Hardware
- Open Hardware Manager
- Click Open Target -> Auto Connect (Make sure FPGA is connected)
- Click Program Device
- Make sure .but and .ltx files are selected in this window, then hit OK.
- Open ILA Dashboard once programmed, and you can now view it running in memory.
