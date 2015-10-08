import Data.Foldable
import Data.Sequence
import qualified System.Console.ANSI as S
import Rook
import Bishop
import Knight

type Board = [[Maybe Piece]]
data Piece = Piece{color::Color,player::Player}

data Color = White | Black
data Player = King | Queen | Rook | Knight | Bishop | Pawn

instance Show Color where
	show White = "White"
	show Black = "Black"

instance Eq Color where
	White == White = True
	Black == Black = True
	_ == _ = False

instance Show Player where
	show King = "King"
	show Queen = "Queen"
	show Rook = "Rook"
	show Knight = "Knight"
	show Bishop = "Bishop"
	show Pawn = "Pawn"

instance Eq Player where
	King == King = True
	Queen == Queen = True
	Rook == Rook = True
	Knight == Knight = True
	Bishop == Bishop = True
	Pawn == Pawn = True
	_ == _ = False

instance Show Piece where
	show Piece{color=White,player=King}= "\9812"
	show Piece{color=White,player=Queen} = "\9813"
	show Piece{color=White,player=Bishop} = "\9815"
	show Piece{color=White,player=Rook} = "\9814"
	show Piece{color=White,player=Knight} = "\9816"
	show Piece{color=White,player=Pawn} = "\9817"
	show Piece{color=Black,player=King} = "\9818"
	show Piece{color=Black,player=Queen} = "\9819"
	show Piece{color=Black,player=Bishop} = "\9821"
	show Piece{color=Black,player=Rook} = "\9820"
	show Piece{color=Black,player=Knight} = "\9822"
	show Piece{color=Black,player=Pawn} = "\9823"
	show _ = ""

wk = Piece{color=White,player=King}
wq = Piece{color=White,player=Queen}
wb = Piece{color=White,player=Bishop}
wr = Piece{color=White,player=Rook}
wn = Piece{color=White,player=Knight}
wp = Piece{color=White,player=Pawn}
bk = Piece{color=Black,player=King}
bq = Piece{color=Black,player=Queen}
bb = Piece{color=Black,player=Bishop}
br = Piece{color=Black,player=Rook}
bn = Piece{color=Black,player=Knight}
bp = Piece{color=Black,player=Pawn}


initialBoard :: Board
initialBoard = [[Just wr,Just wn,Just wb,Just wq,Just wk,Just wb,Just wn, Just wr],
		[Just wp,Just wp,Just wp,Just wp,Just wp,Just wp,Just wp, Just wp],
		[Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing],
		[Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing],
		[Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing],
		[Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing],
		[Just bp,Just bp,Just bp,Just bp,Just bp,Just bp,Just bp, Just bp],
		[Just br,Just bn,Just bb,Just bq,Just bk,Just bb,Just bn, Just br]]


changeBoard::Int -> Int -> Int -> Int -> Board -> Board
changeBoard x1 y1 x2 y2 a = do
		let p = (a!!x1)!!y1
		let b2 | x1 == x2  = toList $ update y1 Nothing $ fromList (toList $ update y2 p $ fromList (a!!x2))
			   | otherwise = toList $ update y2 p $ fromList (a!!x2)
		let b1 | x1 == x2  = toList $ update y1 Nothing $ fromList (toList $ update y2 p $ fromList (a!!x2))
			   | otherwise = toList $ update y1 Nothing $ fromList (a!!x1)
		let f = \x -> case () of () | x == x1 -> b1 | x == x2 -> b2 |otherwise -> a!!x
		let b = ([f 0] ++ [f 1] ++ [f 2] ++ [f 3] ++ [f 4] ++ [f 5] ++ [f 6] ++ [f 7])
		b

move::[String] -> Board -> Bool -> IO()
move x b chance = do
		let a1 = (read (x!!0)::Int)
	 	let a2 = (read (x!!1)::Int)
	 	let a3 = (read (x!!2)::Int)
	 	let a4 = (read (x!!3)::Int)
	 	let inRange = a1 >= 0 && a1 <= 7 && a2 >= 0 && a2 <= 7 && a3 >= 0 && a3 <= 7 && a4 >= 0 && a4 <= 7

	 	if inRange && (a1,a2) /= (a3,a4)
	 		then do
	 			let initial_empty = (convert ((b!!a1)!!a2)) == " "
	 			if (not initial_empty)
	 				then do
	 					let col1 = color $ (\(Just x) -> x) ((b!!a1)!!a2)
	 					let final_empty = (convert ((b!!a3)!!a4)) == " "
	 					let col2 | final_empty = if col1 == White then Black else White
	 						 	 | otherwise   = color $ (\(Just x) -> x) ((b!!a3)!!a4)
	 					let play1 = player $ (\(Just x) -> x) ((b!!a1)!!a2)
	 					let valid_move | play1 == Rook = Rook.validPath a1 a2 a3 a4 b
	 								   | play1 == Bishop = Bishop.validPath a1 a2 a3 a4 b
										 | play1 == Knight = Knight.validPath a1 a2 a3 a4 b
	 								   | otherwise = True
					 	if ((chance == True && col1 == White) || (chance == False && col1 == Black)) && col1 /= col2 && valid_move
					 		then do
					 			let board = changeBoard a1 a2 a3 a4 b
					 			let board' = (map.map) convert board
					 			let print' n  t | n == 7     =  prints ((board'!!n)) t
		         							        | otherwise = do
											prints ((board'!!n)) t
											print' (n+1) (not t)
					 			print' 0 True
					 			if (not chance) == True then putStrLn "White to play" else  putStrLn "Black to play"
					 			c <- getLine
					 			let x = (words $ c)
					 			move x board (not chance)
					 		else do
					 			putStrLn "Invalid Input - Play again"
					 			c <- getLine
					 			let x = (words $ c)
					 			move x b (chance)
	 				else do
	 					putStrLn "Invalid Input - Play again"
						c <- getLine
						let x = (words $ c)
						move x b (chance)
	 		else do
		 		putStrLn "Invalid Input - Play again"
				c <- getLine
				let x = (words $ c)
				move x b (chance)

convert::Maybe Piece -> String
convert (Just x) = show x
convert Nothing = " "

prints::[String] -> Bool -> IO()
prints a t = do
	if t == True
		then do
			S.setSGR [S.SetColor S.Foreground S.Dull S.Black]
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!0)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!1)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!2)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!3)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!4)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!5)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!6)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!7)++" ")
			S.setSGR [S.Reset]
			putStr "\n"
		else do
			S.setSGR [S.SetColor S.Foreground S.Dull S.Black]
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!0)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!1)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!2)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!3)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!4)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!5)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.Black]
			putStr (" "++(a!!6)++" ")
			S.setSGR [S.SetColor S.Background S.Vivid S.White]
			putStr (" "++(a!!7)++" ")
			S.setSGR [S.Reset]
			putStr "\n"


main::IO()
main = do
	 let board' = (map.map) convert initialBoard
	 let print' n  t | n == 7     =  prints ((board'!!n)) t
		         | otherwise = do
					prints ((board'!!n)) t
					print' (n+1) (not t)
	 print' 0 True
	 putStrLn "White to play"
	 c <- getLine
	 let x = (words $ c)
	 -- True -> White to play, False -> Black to play
	 let chance = True
	 let a1 = (read (x!!0)::Int)
	 let a2 = (read (x!!1)::Int)
	 let a3 = (read (x!!2)::Int)
	 let a4 = (read (x!!3)::Int)
	 let inRange = a1 >= 0 && a1 <= 7 && a2 >= 0 && a2 <= 7 && a3 >= 0 && a3 <= 7 && a4 >= 0 && a4 <= 7

	 if inRange && (a1,a2) /= (a3,a4)
	 	then do
	 		let initial_empty = (convert ((initialBoard!!a1)!!a2)) == " "
	 		if (not initial_empty)
	 			then do
	 				let col1 = color $ (\(Just x) -> x) ((initialBoard!!a1)!!a2)
	 				let final_empty = (convert ((initialBoard!!a3)!!a4)) == " "
	 				let col2 | final_empty = Black
	 						 | otherwise   = color $ (\(Just x) -> x) ((initialBoard!!a3)!!a4)
	 				let play1 = player $ (\(Just x) -> x) ((initialBoard!!a1)!!a2)
	 				let valid_move | play1 == Rook = Rook.validPath a1 a2 a3 a4 initialBoard
	 							   | play1 == Bishop = Bishop.validPath a1 a2 a3 a4 initialBoard
									 | play1 == Knight = Knight.validPath a1 a2 a3 a4 initialBoard
	 							   | otherwise = True
			 		if( chance == True && col1 == White && col2 == Black && valid_move)
			 			then do
			 				let board = changeBoard a1 a2 a3 a4 initialBoard
					 		let board' = (map.map) convert board
					 		let print' n  t | n == 7     =  prints ((board'!!n)) t
					 			        | otherwise = do
					 			  		prints ((board'!!n)) t
					 			  		print' (n+1) (not t)
					 		print' 0 True
					 		if (not chance) == True then putStrLn "White to play" else  putStrLn "Black to play"
					 		c <- getLine
					 		let x = (words $ c)
					 		move x board (not chance)
					 	else do
					 		putStrLn "Invalid Input - Play again"
					 		c <- getLine
					 		let x = (words $ c)
					 		move x initialBoard (chance)
	 			else do
	 				putStrLn "Invalid Input - Play again"
					c <- getLine
					let x = (words $ c)
					move x initialBoard (chance)
		else do
			putStrLn "Invalid Input - Play again"
			c <- getLine
			let x = (words $ c)
			move x initialBoard (chance)

	 --c <- getLine
	 --let x = (words $ c)
	 --move x board
