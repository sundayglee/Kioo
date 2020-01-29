# 1. Introduction
Kioo Media Player is based on Open Source Tools which provides different functionality to the Kioo Media Player.

Due to this, these tools must be downloaded and integrated together in order to be able to build the player successfully.

Here are the list of items required to build the player:

1. 	Qt Open source Framework with Qt Creator for easy development
2.	FFmpeg Source Code and Prebuilt Shared Libraries
3.	QtAV Source Code
4.	Kioo Media Player Source Code

	

# 2. Prerequisites

### 1. Qt Open Source Framework
Depending on your platform(Windows, Linux, MacOS, etc), you should download the Qt Open Source Framework from the following [link] (https://download.qt.io/archive/qt/5.14/5.14.0/) where Qt 5.14.0 at the time of this writing was available. 

You are not limited to use the above version, latest versions will also work.

After downloading it, install it in your computer.


### 2. FFmpeg Source Code and Pre-Built Shared Libraries
FFmpeg is the core library which is used to decode the media files. This is to say, any media file FFmpeg can decode, Kioo Media player can decode it too.

Because Kioo Media Player is built on top of QtAV framework, and QtAV framework is a wrapper of FFmpeg library, then both Source Code and Pre-Built Shared libraries depending on your platform should also be downloaded.

Latest pre-built FFmpeg library for windows and MacOs platform can be obtained from Zeranoe website [here] (https://ffmpeg.zeranoe.com/builds/).

At the Zeranoe website, the packages download system is designed pretty well. You can download the daily builds,or latest versions depending on the current available version. At the time of this writing, the latest version was 4.2.1.

Depending on your platform, download both **shared** and source code here identified as **dev** of the same version.

For linux, download the **shared** library and **source code** for **FFMpeg** from the package manager. In Ubuntu you can use aptitude package manager as follows:
> **sudo apt install ffmpeg libavcodec-dev libavformat-dev libavdevice-dev**

The above command will download all the requirements for building QtAV and Kioo Media Player.

### 3. QtAV
QtAV is the framework which Kioo Media Player is built on top of it.

This framework provides easy to use calls to the FFMpeg library, which reduces the amount of code needed for Kioo Media Player to interface with FFMpeg.

QtAV has a lot of other features and it has been design to work as plug and play replacement for Qt Framework. Check it out at its website [here] (https://www.qtav.org/)

The source code of QtAV can be obtained at its github repository [here] (https://github.com/wang-bin/QtAV)

Alternatively, Kioo Media Player has its own customized repository of QtAV which has few improvements which did not make into QtAV master branch.


### 4. Kioo Media Player
Kioo Media Player is the player itself built using QT framework. It is mainly written in QML, Javascript, and C++.

Since it utilizes FFMpeg as its media processing engine, then all the media files that can be played by FFMpeg, Kioo Media Player can play them too.

There are other features that the player incorporate but one of iconic feature is Kioo Social Platform which is a kind of Social Platform where different movie viewer can comment on the movie that is being played. 

For more information about the player, visit its website [here] (https://kiooplayer.com).

The source code for the player is obtained at its gitlab repository [here] (https://gitlab.com/kioo/kioo). 

Clone the latest source code and we are good to go.


# 3. Building Kioo Media Player using Qt Creator in Windows
Building Kioo Media Player involves the following steps:

1) Install latest Qt Framework Version, as of this writing it was Qt 5.14.
2) Copy the folders **include** and **libs** from FFMpeg dev package into Qt's **include** and **lib** directories.
3) From the **bin** folder of FFMpeg Shared package, copy all the dlls, except the executable into the Qt's **bin** folder.
4) Go to QtAV folder and open the **QtAV.pro** file using **Qt Creator**.

5) On Qt Creator, build QtAV in **debug** and **release** version of the library.

6) After building QtAV above successfully, Go to the compiled **debug** and **release** folder and find a file named **sdk_install.bat**. Run it to install QtAV library into the Qt Framework folder. In the same folder there is also **sdk_uninstal**l file that can be used to unisntall the QtAV SDK from the system.
7) Next go to Kioo Media Player Source code folder and open the file **Kioo.pro** using **Qt Creator**
8) Build the Kioo Media Player first in **debug** mode to see any errors if present and if successfully, then build its **release** version.
9) Go to the **release** version folder of Kioo Media Player; in there there will be a **release** folder and open it.
10) Delete all the files in there except the **Kioo.exe** file.
12) Running **Kioo.exe** in this folder wont work as it require some other files to be in the same directory as this file.

13) To get these files, go to Qt framework folder and open its corresponding architecture depending on the build architecture you choose from above. Assuming you build for 64 bit windows, then open the mingw73_64 folder, remember mingw73 means the version of mingw is 7.3. The 64 means 64 bit.

14) Copy the folders **lib**, **plugins** and **qml** into the Kioo Media Player **release** folder. This is a folder with **Kioo.exe**. Its a lot of files, but we will reduce them a bit later.

15) Next, open the bin directory in the Qt **mingw** folder of the same architecture, in here i selected 64 bit.

16) Search for **.dll** files in the windows explorer search function to filter out only the **dlls** in the **bin** directory as we wont need any executable in there.

17) Copy all the **.dl**l from the bin folder into the **release** folder of Kioo Media Player. This is the folder with **Kioo.exe**

18) Run **Kioo.exe** in the release folder, Kioo Media Player will open successfully.

19) For now we can run **Kioo.exe** from the folder but still there are a lot of files we do not require in there.

20) Close the Kioo.exe window.

21) Make sure Qt Creator is closed and go to your Qt install directory, mine was at **C:\Qt** and change the folder name to anything else like **C:\Qt123**.

22) Go to Kioo Media Player **release** folder(the folder with Kioo.exe) and run **Kioo.exe** again. This time do not close it.

23) Filter out all **.dll** files by searching for .dll on the window file explorer of the same Kioo Media Player release folder.

24) With Kioo.exe still opened, select all .dll which where found on previous step and delete them all. Skip any file that prompt that the file is in use by another program. These are the one we require to be left in the Kioo.exe folder.

25) We can further reduce the size of the folder by going into the qml folder in the release folder of Kioo media player(The folder with Kioo.exe) and delete folders like QtBluetooth, QtGamepad, QtLocation, QtNfc, QtRemoteObjects, QtTest and QtWebChannel. These are  not required by Kioo Media Player for correct working of the player.

26) Rename back the Qt directory to its original name. From **C:\Qt123** to **C:\Qt**.

26) Lastly, use an executable builder like InnoSetup to build an executable for the player. A sample script for InnoSetup is available in the Kioo Media Player source code folder.


# 4. Building Kioo Media Player using Qt Creator in Linux

Building Kioo Media Player in Linux is a simple task since the library can be downloaded easily.

1) Install latest Qt Framework Version, as of this writing it was Qt 5.14.

2) Go to QtAV folder and open the **QtAV.pro** file using **Qt Creator**.

3) On Qt Creator, build QtAV in **debug** and **release** version of the library.

4) After building QtAV above successfully, Go to the compiled **debug** and **release** folder and find a file named **sdk_install.sh**. Run it to install QtAV library into the Qt Framework folder. In the same folder there is also **sdk_uninstall.sh** file that can be used to unisntall the QtAV SDK from the system.

5) Next go to Kioo Media Player Source code folder and open the file **Kioo.pro** using **Qt Creator**

6) Build the Kioo Media Player first in **debug** mode to see any errors if present and if successfully, then build its **release** version.

7) Go to the **release** version folder of Kioo Media Player; in there there will be a **release** folder and open it.

8) Delete all the files in there except the **Kioo** file.

9) Run **Kioo** in the release folder, Kioo Media Player will open successfully.

10) For now we can run **Kioo** from the folder but still there are a lot of files we do not require in there.

11) If you want to install Kioo Media Player or distribute it to other system, a prebuilt executable should be created for that particular linux flavor. Unfortunately as of this writting, no method has been provided yet on how to create a distribution executable for Linux operating systems.