<h1 align=center>MicroSnake</h1>

[![projectStatus](https://img.shields.io/badge/status-stable-green?maxAge=60)](https://www.github.com/rahul4732saini/MicroSnake)
[![License](https://img.shields.io/badge/License-MIT-green?maxAge=60)](https://github.com/rahul4732saini/MicroSnake/blob/main/LICENSE)

[![StarProject](https://img.shields.io/github/stars/rahul4732saini/MicroSnake.svg?style=social&label=Star&maxAge=60")](https://www.github.com/rahul4732saini/MicroSnake)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=social&logo=linkedin&maxAge=60)](https://www.linkedin.com/in/rahul4732saini/)

<h2 align=center>Description</h2>

**MicroSnake** is a minimal x86 Assembly based implementation of the classic snake game designed to fit in the 512-byte MBR (Master Boot Record) of the legacy BIOS systems. It is a standalone binary executable file that can be booted with the help of an external device such as a PenDrive or CD/DVD drive.

<h2 align=center>Getting Started</h2>

To enjoy this game, follow the steps below to setup and run the game on your local system.

### Prerequisites

- A legacy system based on the **x86 architecture** that supports BIOS and the MBR partitioning scheme, or an emulator such as QEMU or Bochs.

- Optionally, **NASM** (Netwide Assembler) to assemble the game. Only if you are manually building it from source code.

### Installation Options

You can obtain the game through the following methods:

1. **Cloning the GitHub Repository (Recommended)**:

    This method allows you to access the latest version of the game:

    ```bash
    git clone https://github.com/rahul4732saini/MicroSnake.git
    cd MicroSnake
    ```

2. **Downloading the Source Code as a ZIP file**:

    If you prefer not to use `Git`, download the source code directly:

    - Navigate to the repository's [main page](https://www.github.com/rahul4732saini/MicroSnake).​

    - Click on the `Code` button and select `Download ZIP`.​

    - Finally, Extract the downloaded ZIP file.

3. **Directly downloading the Executable file**:

    You can also download the executable file directly from the **Release** page on the **GitHub** repository. In this case, you can also skip the build process and run it directly using the steps mentioned [here](#running-the-game).

### Building the game

Once you have the source code, you can easily assemble it using the provided **Makefile**. Note that this would require the **make** utility to be installed on your system. Once you have it, you can simply execute the `make` command to build the game.

After the above-mentioned procedure has been successfully completed, a file named `snake.bin` will be generated in the `bin` directory comprising the executable code.

### Running the game

Broadly, you have two different options to run the game on your local system, which are briefed as follows:

1. **Use an Emulator such as QEMU or Bochs**:

    Example using **QEMU**:

    ```bash
    qemu-system-x86_64 -drive format=raw,file=bin/snake.bin
    ```

2. **Boot it using an external device such as a PenDrive or CD/DVD**:

    Example using a PenDrive:

    In order to boot the game, you would require to make the PenDrive bootable by copying the executable to its 1st sector (512-byte) or MBR. This step can be performed by using a tool such as `dd`, an example of which is shown as follows:

    ```bash
    dd if=bin/snake.bin of=<destination-device> bs=512 count=1 conv=notrunc
    ```

    Replace the `destination-device` with the path to the device file based on the Operating System.

    Once written to the MBR, the device can be used to boot the game.

## Legals

This project is distributed under the MIT License. Refer to [LICENSE](./LICENSE) for more details.

## Call for Contributions

This project always welcomes your precious expertise and enthusiasm! The project relies on its community's wisdom and intelligence to investigate bugs and contribute code. We always appreciate improvements and contributions to this project.
