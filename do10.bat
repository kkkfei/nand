 
lua .\JackAnalyzer.lua .\10\ArrayTest\Main.jack
call D:\book\cs\system\Nand2tetris\Software\nand2tetris\tools\TextComparer.bat 10/ArrayTest/MainT.xml 10/ArrayTest/MainT_m.xml

lua .\JackAnalyzer.lua .\10\ExpressionLessSquare\Main.jack .\10\ExpressionLessSquare\Square.jack .\10\ExpressionLessSquare\SquareGame.jack
call D:\book\cs\system\Nand2tetris\Software\nand2tetris\tools\TextComparer.bat 10\ExpressionLessSquare\MainT.xml 10\ExpressionLessSquare\MainT_m.xml
call D:\book\cs\system\Nand2tetris\Software\nand2tetris\tools\TextComparer.bat 10\ExpressionLessSquare\SquareT.xml 10\ExpressionLessSquare\SquareT_m.xml
call D:\book\cs\system\Nand2tetris\Software\nand2tetris\tools\TextComparer.bat 10\ExpressionLessSquare\SquareGameT.xml 10\ExpressionLessSquare\SquareGameT_m.xml

lua .\JackAnalyzer.lua .\10\Square\Main.jack .\10\Square\Square.jack .\10\Square\SquareGame.jack
call D:\book\cs\system\Nand2tetris\Software\nand2tetris\tools\TextComparer.bat 10\Square\MainT.xml 10\Square\MainT_m.xml
call D:\book\cs\system\Nand2tetris\Software\nand2tetris\tools\TextComparer.bat 10\Square\SquareT.xml 10\Square\SquareT_m.xml
call D:\book\cs\system\Nand2tetris\Software\nand2tetris\tools\TextComparer.bat 10\Square\SquareGameT.xml 10\Square\SquareGameT_m.xml
