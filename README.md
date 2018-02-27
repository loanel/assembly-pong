## assembly-pong
# Installation guide:
The easiest way to run the game is using the dosbox operating system. Newer versions of windows will not run the game properly.
1. Install dosbox : https://www.dosbox.com/
2. Download MASM and linker

3. Copy the contents of repository into the masm and link directory

4. Mount the directory in dosbox

5. Assembly the pong.asm file: 
> masm pong.asm

6. Link the resulting .obj file: 
> link pong.asm

7. Run the game
