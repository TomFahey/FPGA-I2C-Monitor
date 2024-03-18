# FPGA I2C Monitor

This verilog design implements a simple I2C bus monitor/sniffer, intended to
passively listen to transactions on a connected I2C bus and read them out
over UART.

The main motivation for developing this FPGA-targeted implementation, was the limited ability of microcontroller-based solutions to reliably record transactions when the I2C clock rate is faster than around 200KHz.

## I2C->UART representation

![alt text](Table.svg)

In order to provide a meaningful representation of the various I2C delimiters, such as the Start and Stop conditions, Ack/Nack etc. the convention shown in the figure above was adopted, whereby:

* I2C Start => ASCII STX (0x02) 
* I2C Stop => ASCII ETX (0x03) 
* I2C ACK => ASCII ACK (0x06) 
* I2C NACK => ASCII NAK (0x15) 

For the purposes of easier readability, ASCII spaces (0x20) are inserted between the I2C delimiters, with a line feed (0xA) placed after each Stop condition.

To simplify the state machine used to parse the I2C transactions, the Read/<u>Write</u> bit that follows the 7-bit device address value is not parsed separately from the preceding 7-bits and thus will change the displayed device address value during a Read operation; this is not much of a problem as long as the device address only uses the lower 4-bits, however for addresses larger than 0xF, this will have to be separately accounted for.

10-bit I2C addresses are not supported, again to keep things simple.

## Usage

The design was succesfully tested with an Intel DE-10 Nano and Tang Nano 9K, recording the I2C transactions between a PC and CY4534 USB-C Power Delivery dev board, with the I2C bus operating at around 300KHz. Faster clocks should be possible (depending on the clock speed of the FPGA used), although I haven't tested that myself. With the default parameters, the implementation footprint on a Nano 9K came to approximately 200 LUTs and 100FFs.

There a few parameters that should be adjusted, according to your intended usecase:

 * `BAUD_RATE` in `uart_tx.v` should be set to the desired baud rate you wish to use for the UART output
 * `CLOCK_RATE` in `uart_tx.v` should be set to the main clock frequency of the FPGA device being used.
 * The default value for the FIFO depth is 256 bytes, specified by the `DEPTH` parameter in `fifo.v` (a minimal I2C message will take up about 20 ASCII characters/bytes). You may want to increase this value in the event that the UART baud rate isn't sufficient to keep up with the messages coming in on the I2C bus.






 