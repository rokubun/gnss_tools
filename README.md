
This Docker contains a basic set of tools for GNSS data processing

The tools included in the image are:
- RTKLib 2.4.3
- Hatanaka compression/decompression tools for Rinex files
- Unavco `teqc` tool to process Rinex v2 files
- GFZ's `gfzrnx` tool to process Rinex v2 and v3 files

The advantage of using a containerized set of tools is twofold:
- Traceability of the installed versions
- Can be executed in multiple platforms (Windows, MacOSX, Linux, ...) without
  worrying to install software everytime
- Include the image in other services.

# Usage examples

After pulling the image from the registry you can, for instance:

- Use `teqc` to process a Rinex v2 file to obtain only the phase and code of
  the L1 frequency. The file is located in the current directory

    `docker run -ti -v ${PWD}:/tmp rokubun/gnss_tools teqc -O.obs L1C1 /tmp/inbd1570.18o`

  This commands `run`s a command of the `gnss_tools` image. In this case the 
  command is `teqc` (`teqc -O.obs L1C1 /tmp/inbd1570.18o`). The command
  operates in a file that is located in the `/tmp` folder of the container. 
  Therefore, we mount the current directory (`${PWD}`) of the host machine in
  the temporal folder of the container to make it available. The command
  spits the results to standard output.

- Use RTKLIB to stream the data from an NTRIP caster to a file (`str2str`). We first
  launch the container mounting a folder in the host machine (for instance
  the current working directory, i.e. `${PWD]`):

  Launch the container (interactive session with the bash prompt, ready
  to accept commands within the container)
  
    `docker run -ti -v ${PWD}:/tmp rokubun/gnss_tools`

  Within the container, start the str2str server to stream data from 
  an NTRIP caster to a file (we assume the mountpoint of the caster is
  using RTCM 3 format
  
    `str2str -in ntrip://<username>:<password>@<xx.xx.xx.xx>:<ppp>/<mount>#rtcm3 -out file:///tmp/test.rtcm3#rtcm3`

  In this command `<username>` and `<password>` are your credentials to the caster.
  `<xx.xx.xx.xx>` is the caster IP address (or, alternatively, caster URL),
  `<ppp>` is the caster port number (usually 2101) and `<mount>` is the 
  mountpoint you want to use. For more information please access the `str2str`
  help page

  In a similar way, other RTKLib tools such as `convbin`, `rnx2rtkp`, `rtkrcv`, ...
  can be used in a similar fashion


