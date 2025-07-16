{-# LANGUAGE ForeignFunctionInterface #-}
-- Going to need all of these imports as far as I can tell, and what looks like
-- a preprocessor directive above.
import Data.Vector
import Data.Char
import Foreign
import Foreign.Ptr
import Foreign.C
import Foreign.C.String
import Foreign.C.Types
import Control.Concurrent.STM

-- Syntax for binding to a C header file...
-- foreign import ccall "<header filename> <function name w/in header file>"
foreign import ccall "FFIrandom.h randDouble"
    randDouble :: IO CDouble

foreign import ccall "FFIrandom.h randInt"
    randInt :: IO CInt

foreign import ccall "FFIrandom.h randFloat"
    randFloat :: IO CFloat

foreign import ccall "FFIrandom.h xorCipher"
    c_xorcipher :: Ptr CChar -> CInt -> Ptr CChar

plaintext :: String
plaintext = "Hi, this is the plaintext!"

simpleXORCipher :: Vector Char -> CInt -> Vector Char
simpleXORCipher input 0 = input
simpleXORCipher input key =
    let
        keyToArr = intToVec sz key
        sz = sizeOf key
        in case Data.Vector.length input < sz of
            True -> charXOR input keyToArr
            False -> charXOR (Data.Vector.take sz input) keyToArr Data.Vector.++ simpleXORCipher (Data.Vector.drop sz input) key

intToVec :: Int -> CInt -> Vector Char
intToVec n i = case n of
    0 -> Data.Vector.empty
    x ->
        let
            lowerbytes = i .&. 0xFF
            upperbytes = i - lowerbytes
            lowerToChar = chr (fromIntegral lowerbytes)
            in intToVec (n-1) (upperbytes `div` 256) Data.Vector.++ singleton lowerToChar


charXOR :: Vector Char -> Vector Char -> Vector Char
charXOR cVec keyVec = case Data.Vector.length cVec of
    0 -> Data.Vector.empty
    x ->
        let
            c = ord (Data.Vector.head cVec)
            k = ord (Data.Vector.head keyVec)
            resInt = c `xor` k
            res = chr resInt
            in singleton res Data.Vector.++ charXOR (Data.Vector.drop 1 cVec) (Data.Vector.drop 1 keyVec)

main = do
    strptr <- newCString plaintext
    cxorstr <- peekCString (c_xorcipher strptr 3)
    putStrLn "Testing: simpleXORCipher (fromList plaintext) 3 == fromList cxorstr"
    putStrLn (show (simpleXORCipher (fromList plaintext) 3 == fromList cxorstr))

-- BE CAREFUL: sizeOf for Int and Int32 are way different (this took a fuck ton of debugging!)
simpleXORCipher' :: String -> Int32 -> String
simpleXORCipher' input 0 = input
simpleXORCipher' input key =
    let
        keyToArr = toList (intToVec sz (fromIntegral key))
        sz = sizeOf key
        in case Prelude.length input < sz of
            True -> charXOR' input keyToArr
            False -> charXOR' (Prelude.take sz input) keyToArr Prelude.++ simpleXORCipher' (Prelude.drop sz input) key

charXOR' :: String -> String -> String
charXOR' cStr keyStr = case cStr of
    [] -> []
    x:rest ->
        let
            c = ord x
            k = ord (Prelude.head keyStr)
            resInt = c `xor` k
            res = chr resInt
            in [res] Prelude.++ charXOR' rest (Prelude.tail keyStr)