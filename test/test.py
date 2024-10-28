# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer
from cocotbext.uart import UartSink


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 50 ns (20 MHz)
    clock = Clock(dut.clk, 50, units="ns")
    cocotb.start_soon(clock.start())

    uart_sink = UartSink(dut.uart_tx, baud=115200, bits=8)

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test the UART debug interface")

    # Wait for 600 us for the UART data to be sent
    await Timer(600, units="us")

    data = uart_sink.read_nowait(6)
    dut._log.info(f"UART Data: {data}")
    assert data == b"0000\r\n"
